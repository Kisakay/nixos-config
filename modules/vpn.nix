# VPN WireGuard (toujours actif). Les valeurs sensibles viennent de secrets.nix.
{
  config,
  pkgs,
  secrets,
  ...
}:

let
  wg1 = builtins.elemAt secrets.wireguard 1;
in
{
  # networking.wireguard.interfaces.wg0 = {
  #   ips = [ secrets.wireguard.address ];
  #   mtu = secrets.wireguard.mtu;
  #   privateKeyFile = secrets.wireguard.privateKeyFile;

  #   peers = [
  #     {
  #       publicKey = secrets.wireguard.publicKey;
  #       presharedKey = secrets.wireguard.presharedKey;
  #       endpoint = secrets.wireguard.endpoint;
  #       allowedIPs = secrets.wireguard.allowedIPs;

  #       # Maintient le tunnel actif derrière un NAT.
  #       persistentKeepalive = secrets.wireguard.persistentKeepalive;
  #     }
  #   ];
  # };

  networking.wireguard.interfaces.wg1 = {
    ips = [
      wg1.address
    ];
    mtu = wg1.mtu;
    privateKeyFile = wg1.privateKeyFile;

    peers = [
      {
        publicKey = wg1.publicKey;
        presharedKey = wg1.presharedKey;
        endpoint = wg1.endpoint;
        allowedIPs = wg1.allowedIPs;

        # Maintient le tunnel actif derrière un NAT.
        persistentKeepalive = wg1.persistentKeepalive;
      }
    ];
  };
}
