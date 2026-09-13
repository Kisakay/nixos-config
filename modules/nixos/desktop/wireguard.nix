{ pkgs, ... }:

let
  Creds = import /etc/wg1000.nix;
in
{
  networking.wg-quick.interfaces.wg100 = {
    address = Creds.wireguard.anais.address;
    dns = Creds.wireguard.anais.dns;
    privateKey = Creds.wireguard.anais.privateKey;

    peers = [
      {
        publicKey = Creds.wireguard.anais.publicKey;
        presharedKey = Creds.wireguard.anais.presharedKey;
        endpoint = Creds.wireguard.anais.endpoint;
        allowedIPs = Creds.wireguard.anais.allowedIPs;
        persistentKeepalive = Creds.wireguard.anais.persistentKeepalive;
      }
    ];
  };
}
