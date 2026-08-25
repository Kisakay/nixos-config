{ inputs, pkgs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ]
  ++ (with pkgs; [
    chromium
    tor-browser
    brave
  ]);
}
