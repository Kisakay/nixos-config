# Configuration de la machine « framework-laptop-12 ».
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # Version de l'état du système. Ne pas modifier sans lire la documentation
  # de cette option (man configuration.nix ou https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05";
}
