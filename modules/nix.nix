# Configuration de Nix et de nixpkgs.
{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  documentation.dev.enable = true;
  documentation.man.enable = true;
}
