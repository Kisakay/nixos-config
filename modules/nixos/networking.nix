{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];

    # wg0 est géré par systemd-networkd/wireguard-tools (natif NixOS),
    # PAS par NetworkManager : sinon NM peut le down au bout d'un moment.
    # enp4s0 + br0 sont gérés en natif NixOS pour le bridge libvirt,
    # PAS par NetworkManager : sinon conflit entre les deux.
    unmanaged = [
      "interface-name:wg0"
      "interface-name:enp4s0"
      "interface-name:br0"
    ];

    wifi = {
      powersave = false;
      scanRandMacAddress = false;
    };
  };

  # Bridge natif pour les VMs libvirt (enp4s0 esclave, IP statique sur br0).
  # NetworkManager ne touche ni enp4s0 ni br0 (voir unmanaged ci-dessus).
  networking = {
    useDHCP = false;
    bridges."br0".interfaces = [ "enp4s0" ];
    interfaces."enp4s0".useDHCP = false;
    interfaces."br0" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.2.200";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.2.1";
    nameservers = [
      "192.168.2.1"
      "fd56:ea31:7745:10::1"
    ];
    domain = "lan";
  };

  hardware.bluetooth.enable = false;

  environment.systemPackages = [
    pkgs.util-linux
  ];

  systemd.services.disable-wifi = {
    description = "Disable Wi-Fi via rfkill";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block wifi";
      RemainAfterExit = true;
    };
  };

  systemd.services.disable-bluetooth = {
    description = "Disable Bluetooth via rfkill";
    wantedBy = [ "multi-user.target" ];
    after = [ "bluetooth.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth";
      RemainAfterExit = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;

    allowedTCPPorts = [
      22
      80
      443
      3000
      3001
      3871
      4560
      8000
      25565
      11434
    ];
    allowedUDPPorts = [
      53
      51820
    ];

    trustedInterfaces = [
      "virbr0"
      "br0"
    ];
  };

  services.openssh = {
    enable = true;

    ports = [
      22
    ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;

      # SSH forwarding
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "yes";
      X11Forwarding = false;
      GatewayPorts = "no";
    };
  };
}
