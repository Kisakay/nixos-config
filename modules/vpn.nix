# VPN WireGuard (toujours actif). Les valeurs sensibles viennent de secrets.nix.
{
  secrets,
  ...
}:

let
  wg0 = builtins.elemAt secrets.wireguard 0;
  wg1 = builtins.elemAt secrets.wireguard 1;
  wg2 = builtins.elemAt secrets.wireguard 2;

in
{
  networking.wg-quick.interfaces = {
    wg0 = {
      address = wg0.address;
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

    wg1 = {
      address = wg1.address;
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

    wg2 = {
      address = wg2.address;
      mtu = wg2.mtu;
      privateKey = wg2.privateKey;

      peers = [
        {
          publicKey = wg2.publicKey;
          presharedKey = wg2.presharedKey;
          endpoint = wg2.endpoint;

          allowedIPs = wg2.allowedIPs;

          persistentKeepalive = wg2.persistentKeepalive;
        }
      ];
    };
  };
}
