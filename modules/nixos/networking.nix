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

  hardware.bluetooth.enable = false;

  environment.systemPackages = [
    pkgs.util-linux
  ];

  systemd.services.disable-wifi = {
    description = "Disable Wi-Fi via rfkill";
    wantedBy = [ "multi-user.target" ];
    after = [ "NetworkManager.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block wifi";
      RemainAfterExit = true;
    };
  };

  systemd.services.disable-bluetooth = {
    description = "Disable Bluetooth via rfkill";
    wantedBy = [ "multi-user.target" ];
    after = [ "bluetooth.service" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth";
      RemainAfterExit = true;
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = true;

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

    ports = [
      22
    ];

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      ChallengeResponseAuthentication = false;

      # SSH forwarding
      AllowTcpForwarding = "yes";
      AllowAgentForwarding = "yes";
      X11Forwarding = false;
      GatewayPorts = "no";
    };
  };
}
