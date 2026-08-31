# VPN WireGuard (toujours actif). Les valeurs sensibles viennent de secrets.nix.
{ config, pkgs, secrets, ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ secrets.wireguard.address ];
    mtu = secrets.wireguard.mtu;
    privateKeyFile = secrets.wireguard.privateKeyFile;

    peers = [
      {
        publicKey = secrets.wireguard.publicKey;
        endpoint = secrets.wireguard.endpoint;
        allowedIPs = secrets.wireguard.allowedIPs;
        # Maintient le tunnel actif derrière un NAT.
        persistentKeepalive = secrets.wireguard.persistentKeepalive;
      }
    ];
  };

  # DNS fourni par le VPN.
  networking.nameservers = [ secrets.wireguard.dns ];
}
