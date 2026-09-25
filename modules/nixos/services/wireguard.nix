{ pkgs, ... }:

let
  vpn = import /etc/wg0.nix;
in
{

  networking.nat.enable = true;

  networking.wireguard = {
    interfaces.wg0 = {
        ips = vpn.fbx.ips;
        listenPort = 14912;

        privateKey = vpn.fbx.privateKey;

        peers = [
          {
            publicKey = vpn.fbx.publicKey;

            allowedIPs = vpn.fbx.allowedIPs;
            endpoint = vpn.fbx.endpoint;

            persistentKeepalive = 25;
          }
        ];
    };
  };
}
