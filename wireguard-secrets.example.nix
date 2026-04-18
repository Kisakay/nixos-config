{
  my.wireguard.wg0 = {
    enable = true;

    serverIp = "";
    serverPort = "";

    wg0AddressV4 = "";
    wg0AddressV6 = "";

    dns1 = "1.1.1.1";
    dns2 = "1.0.0.1";

    publicKey = "";

    allowedIPs = [
      "0.0.0.0/0"
      "::/0"
    ];

    persistentKeepalive = 25;

    privateKeyFile = /etc/nixos-local/wireguard/privateKeyFile_wg0.key;
    presharedKeyFile = /etc/nixos-local/wireguard/presharedKeyFile_wg0.key;
  };
}
