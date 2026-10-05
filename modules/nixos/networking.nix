{ pkgs, ... }:

{
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];

    # wg0 est géré par systemd-networkd/wireguard-tools (natif NixOS),
    # PAS par NetworkManager : sinon NM peut le down au bout d'un moment.
    # enp4s0 + br0 sont gérés en natif NixOS pour le bridge libvirt,
    # PAS par NetworkManager : sinon conflit entre les deux.
    unmanaged = [
      "interface-name:wg0"
      "interface-name:enp4s0"
      "interface-name:br0"
    ];
  };

  # Bridge natif pour les VMs libvirt (enp4s0 esclave, IP statique sur br0).
  # NetworkManager ne touche ni enp4s0 ni br0 (voir unmanaged ci-dessus).
  networking = {
    useDHCP = false;
    bridges."br0".interfaces = [ "enp4s0" ];
    interfaces."enp4s0".useDHCP = false;
    interfaces."br0" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.2.200";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "192.168.2.1";
    nameservers = [
      "192.168.2.1"
      "fd56:ea31:7745:10::1"
    ];
    domain = "lan";
  };

  # B550M AORUS ELITE : pas de Wi-Fi ni Bluetooth embarqués,
  # pas de rfkill à forcer (no-op sur tour).
  hardware.bluetooth.enable = false;

  environment.systemPackages = [
    pkgs.util-linux
  ];

  networking.firewall = {
    enable = false;
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
      51105
    ];
    allowedUDPPorts = [
      53
      51820
      51105
	];

    trustedInterfaces = [
      "virbr0"
      "br0"
    ];
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
