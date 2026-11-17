{ pkgs, ... }:

{

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # VeeMeeter (https://veemeter.v.bzh), remplace pulsemeeter.
  programs.veemeeter.enable = true;

  # Cosmic Advanced Player (https://cosmic-advanced-player.v.bzh), lecteur de musique natif COSMIC.
  programs.cosmic-advanced-player.enable = true;

  environment.systemPackages = with pkgs; [
    qpwgraph
    pavucontrol
    easyeffects
    lsp-plugins
  ];

}
