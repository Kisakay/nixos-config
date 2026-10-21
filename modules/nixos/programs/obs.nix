{ pkgs, ... }:

{
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = false;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-backgroundremoval
      droidcam-obs
      # obs-shaderfilter
      advanced-scene-switcher
    ];
  };
}
