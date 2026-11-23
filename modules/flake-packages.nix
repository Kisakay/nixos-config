# Modules issus des inputs du flake : QxChat, Zen Browser et GitHub ReDesktop.
{ inputs, pkgs, ... }:

{
  imports = [ "${inputs.qxchat-src}/nix/module.nix" ];

  nixpkgs.overlays = [
    (final: prev: {
      qxchat = prev.callPackage "${inputs.qxchat-src}/nix/qxchat.nix" { };
    })
  ];

  programs.qxchat.enable = true;

  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # GitHub ReDesktop (https://regit.v.bzh), remplace github-desktop.
  programs.github-redesktop.enable = true;
}
