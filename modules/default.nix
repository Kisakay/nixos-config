# Agrégation de tous les modules de configuration.
{
  imports = [
    ./boot.nix
    ./desktop.nix
    ./flake-packages.nix
    ./hardware.nix
    ./locale.nix
    ./network.nix
    ./nix.nix
    ./packages.nix
    ./programs.nix
    ./ssh.nix
    ./users.nix
    ./vpn.nix
  ];
}
