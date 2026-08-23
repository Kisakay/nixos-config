{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "computer";

  system.stateVersion = "26.11";
}
