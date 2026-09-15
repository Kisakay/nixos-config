# VPN WireGuard (toujours actif). Les valeurs sensibles viennent de secrets.nix.
{
  secrets,
  ...
}:

let
  wg0 = builtins.elemAt secrets.wireguard 0;
  wg1 = builtins.elemAt secrets.wireguard 1;
in
{
  networking.wireguard.interfaces.wg0 = {
    ips = wg0.address;
    mtu = wg0.mtu;
    privateKey = wg0.privateKey;

    peers = [
      {
        publicKey = wg0.publicKey;
        presharedKey = wg0.presharedKey;
        endpoint = wg0.endpoint;

        allowedIPs = wg0.allowedIPs;

        persistentKeepalive = wg0.persistentKeepalive;
      }
    ];
  };

  networking.wireguard.interfaces.wg1 = {
    ips = wg1.address;
    mtu = wg1.mtu;
    privateKey = wg1.privateKey;

    peers = [
      {
        publicKey = wg1.publicKey;
        presharedKey = wg1.presharedKey;
        endpoint = wg1.endpoint;

        allowedIPs = wg1.allowedIPs;

        persistentKeepalive = wg1.persistentKeepalive;
      }
    ];
  };

}
