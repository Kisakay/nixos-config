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

  # NOTE : aucun `rfkill block wifi` au boot (ça coupait le wifi à chaque
  # démarrage et le sortait de KDE/NetworkManager). Le wifi reste géré par
  # NetworkManager ; le bluetooth est désactivé via hardware.bluetooth.

  # CalDigit TS4 : la NIC Intel (8086:5502, driver igc) est derrière un
  # tunnel PCIe Thunderbolt. Au boot, le kernel la touche AVANT la fin de
  # l'autorisation bolt ("D3cold to D0 failed, PCIe link lost, detached").
  # On la maintient sous tension et on refait un rescan PCI après bolt.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x5502", ATTR{power/control}="on"
  '';

  systemd.services.thunderbolt-pci-rescan = {
    description = "Rescan PCI après autorisation Thunderbolt (CalDigit TS4)";
    wantedBy = [ "multi-user.target" ];
    after = [
      "bolt.service"
      "NetworkManager.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      ${pkgs.coreutils}/bin/sleep 8
      ${pkgs.util-linux}/bin/rfkill unblock wifi || true
      if ! ${pkgs.coreutils}/bin/ls /sys/class/net/ | ${pkgs.gnugrep}/bin/grep -qE '^(enp|eth|eno|wlp)'; then
        echo 1 > /sys/bus/pci/rescan
        ${pkgs.coreutils}/bin/sleep 3
      fi
      ${pkgs.networkmanager}/bin/nmcli radio wifi on || true
    '';
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
      11434
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
