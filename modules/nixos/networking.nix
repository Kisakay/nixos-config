{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];

    wifi = {
      powersave = false;
      scanRandMacAddress = false;
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = false;

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
    ];
    allowedUDPPorts = [
      53
      51820
    ];

    trustedInterfaces = [ "virbr0" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
