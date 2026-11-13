{
  imports = [
    ./boot.nix
    ./clear-autostart.nix
    ./session-autostart.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./security.nix
    ./shell.nix
    ./users.nix

    ./desktop
    ./development
    ./hardware
    ./packages
    ./programs
    ./services
    ./virtualisation
  ];
}
