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

    privateKey = "<private key here>";
    presharedKey = "<pre shared key here>";
  };
}
