{ config, lib, pkgs, ... }:

let
  cfg = config.my.wireguard.wg0;
in {
  options.my.wireguard.wg0 = {
    enable = lib.mkEnableOption "wg0 WireGuard profile";

    serverIp = lib.mkOption {
      type = lib.types.str;
    };

    serverPort = lib.mkOption {
      type = lib.types.port;
    };

    wg0AddressV4 = lib.mkOption {
      type = lib.types.str;
    };

    wg0AddressV6 = lib.mkOption {
      type = lib.types.str;
    };

    dns1 = lib.mkOption {
      type = lib.types.str;
    };

    dns2 = lib.mkOption {
      type = lib.types.str;
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
    };

    allowedIPs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "0.0.0.0/0"
        "::/0"
      ];
    };

    persistentKeepalive = lib.mkOption {
      type = lib.types.int;
      default = 25;
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.path;
    };

    presharedKeyFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."wg-quick-wg0" = {
      after = [
        "NetworkManager.service"
        "NetworkManager-wait-online.service"
        "network-online.target"
        "time-sync.target"
        "systemd-timesyncd.service"
      ];

      wants = [
        "NetworkManager.service"
        "NetworkManager-wait-online.service"
        "systemd-timesyncd.service"
        "time-sync.target"
      ];

      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "10s";
      };

      startLimitIntervalSec = 0;
    };

    networking.wg-quick.interfaces.wg0 = {
      address = [
        cfg.wg0AddressV4
        cfg.wg0AddressV6
      ];

      dns = [
        cfg.dns1
        cfg.dns2
      ];

      privateKeyFile = toString cfg.privateKeyFile;

      peers = [
        {
          publicKey = cfg.publicKey;
          presharedKeyFile = toString cfg.presharedKeyFile;
          endpoint = "${cfg.serverIp}:${toString cfg.serverPort}";
          allowedIPs = cfg.allowedIPs;
          persistentKeepalive = cfg.persistentKeepalive;
        }
      ];

      preUp = ''
        set -euo pipefail

        STATE_DIR=/run/wg-wan
        STATE_ENV="$STATE_DIR/env"
        STATE_ROUTES="$STATE_DIR/lan_routes"

        ${pkgs.coreutils}/bin/mkdir -p "$STATE_DIR"
        : > "$STATE_ENV"
        : > "$STATE_ROUTES"

        for i in $(seq 1 60); do
          if ${pkgs.networkmanager}/bin/nm-online -q; then
            break
          fi
          sleep 1
        done

        ENDPOINT_HOST="$(${pkgs.coreutils}/bin/printf '%s\n' "${cfg.serverIp}:${toString cfg.serverPort}" | ${pkgs.gnused}/bin/sed 's/:[^:]*$//')"

        if ${pkgs.gnugrep}/bin/grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' <<< "$ENDPOINT_HOST"; then
          ENDPOINT_IP="$ENDPOINT_HOST"
        else
          ENDPOINT_IP=""
          for i in $(seq 1 30); do
            ENDPOINT_IP="$(${pkgs.glibc}/bin/getent ahostsv4 "$ENDPOINT_HOST" | ${pkgs.gawk}/bin/awk 'NR==1 {print $1}')"
            if [ -n "$ENDPOINT_IP" ]; then
              break
            fi
            sleep 1
          done
        fi

        if [ -z "$ENDPOINT_IP" ]; then
          echo "wg0 preUp: impossible de résoudre l'endpoint WireGuard" >&2
          exit 1
        fi

        ROUTE_LINE=""
        GW_IF=""
        GW_IP=""

        for i in $(seq 1 30); do
          ROUTE_LINE="$(${pkgs.iproute2}/bin/ip -4 route get "$ENDPOINT_IP" 2>/dev/null | ${pkgs.coreutils}/bin/head -1 || true)"
          GW_IF="$(echo "$ROUTE_LINE" | ${pkgs.gawk}/bin/awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | ${pkgs.coreutils}/bin/head -1)"
          GW_IP="$(echo "$ROUTE_LINE" | ${pkgs.gawk}/bin/awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}' | ${pkgs.coreutils}/bin/head -1)"

          if [ -n "$GW_IF" ]; then
            break
          fi
          sleep 1
        done

        if [ -z "$GW_IF" ]; then
          echo "wg0 preUp: aucune interface upstream valide trouvée avant activation du tunnel" >&2
          exit 1
        fi

        ${pkgs.iproute2}/bin/ip route show table main dev "$GW_IF" \
          | ${pkgs.gnugrep}/bin/grep -v '^default' \
          | ${pkgs.gawk}/bin/awk '{print $1}' \
          | ${pkgs.gnugrep}/bin/grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$' \
          > "$STATE_ROUTES" || true

        {
          echo "GW_IF=$GW_IF"
          echo "GW_IP=$GW_IP"
        } > "$STATE_ENV"

        ${pkgs.coreutils}/bin/chmod 700 "$STATE_DIR"
        ${pkgs.coreutils}/bin/chmod 600 "$STATE_ENV" "$STATE_ROUTES"
      '';

      postUp = ''
        set -euo pipefail

        STATE_DIR=/run/wg-wan
        STATE_ENV="$STATE_DIR/env"
        STATE_ROUTES="$STATE_DIR/lan_routes"

        if [ ! -f "$STATE_ENV" ]; then
          echo "wg0 postUp: fichier d'état absent: $STATE_ENV" >&2
          exit 1
        fi

        . "$STATE_ENV"

        if [ -z "$GW_IF" ]; then
          echo "wg0 postUp: GW_IF absent dans $STATE_ENV" >&2
          exit 1
        fi

        MARK="$(${pkgs.wireguard-tools}/bin/wg show wg0 fwmark 2>/dev/null || true)"

        if [ -z "$MARK" ] || [ "$MARK" = "off" ]; then
          MARK="0x64"
          echo "wg0 postUp: fallback fwmark -> $MARK"
        else
          echo "wg0 postUp: detected fwmark -> $MARK"
        fi

        ${pkgs.nftables}/bin/nft delete table inet killswitch 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 0x64 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route flush table 100 2>/dev/null || true

        ${pkgs.nftables}/bin/nft -f - <<EOF
        table inet killswitch {
          chain output {
            type filter hook output priority -1;
            policy drop;

            oif "lo" accept
            oif "wg0" accept
            meta mark $MARK accept
            udp dport { 67, 68 } accept
            ip daddr 224.0.0.0/4 accept
            ip daddr 255.255.255.255 accept
            ip6 daddr ff00::/8 accept
          }

          chain input {
            type filter hook input priority -1;
            policy drop;

            iif "lo" accept
            iif "wg0" accept
            ct state established,related accept
            udp sport { 67, 68 } accept
            ip saddr 224.0.0.0/4 accept
            ip saddr 255.255.255.255 accept
            ip6 saddr ff00::/8 accept
          }
        }
        EOF

        if [ -f "$STATE_ROUTES" ]; then
          while IFS= read -r route; do
            [ -z "$route" ] && continue
            ${pkgs.nftables}/bin/nft add rule inet killswitch output ip daddr "$route" accept || true
            ${pkgs.nftables}/bin/nft add rule inet killswitch input ip saddr "$route" accept || true
          done < "$STATE_ROUTES"
        fi

        if [ -n "$GW_IP" ]; then
          ${pkgs.iproute2}/bin/ip route add default via "$GW_IP" dev "$GW_IF" table 100 || true
        else
          ${pkgs.iproute2}/bin/ip route add default dev "$GW_IF" table 100 || true
        fi

        ${pkgs.nftables}/bin/nft add rule inet killswitch output udp dport 27005-27030 meta mark set 0x64 accept || true
        ${pkgs.nftables}/bin/nft add rule inet killswitch output tcp dport 27015-27030 meta mark set 0x64 accept || true
        ${pkgs.nftables}/bin/nft add rule inet killswitch input udp sport 27005-27030 accept || true
        ${pkgs.nftables}/bin/nft add rule inet killswitch input tcp sport 27015-27030 accept || true

        ${pkgs.iproute2}/bin/ip rule add fwmark 0x64 table 100 priority 50 || true
      '';

      postDown = ''
        ${pkgs.nftables}/bin/nft delete table inet killswitch 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip rule del fwmark 0x64 table 100 2>/dev/null || true
        ${pkgs.iproute2}/bin/ip route flush table 100 2>/dev/null || true
        ${pkgs.coreutils}/bin/rm -rf /run/wg-wan
      '';
    };
  };
}