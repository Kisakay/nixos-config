# VPN WireGuard (toujours actif). Les valeurs sensibles viennent de secrets.nix.
{
  secrets,
  ...
}:

let
  wg1 = builtins.elemAt secrets.wireguard 0;

in
{
  networking.wg-quick.interfaces = {
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
  };

  networking.networkmanager.unmanaged = [
    "interface-name:wg1"
    "interface-name:wg2"
  ];
}
