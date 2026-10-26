{ config, pkgs, ... }:

{
  # OBS ÇA PUE LA MERDE
  # programs.obs-studio = {
  #   enable = true;

  #   # Intel UHD Graphics : pas de CUDA nécessaire.
  #   package = pkgs.obs-studio;

  #   plugins = with pkgs.obs-studio-plugins; [
  #     # Capture Wayland / PipeWire
  #     obs-pipewire-audio-capture

  #     # Capture Vulkan (facultatif, utile pour certaines applications)
  #     obs-vkcapture

  #     # Sources et filtres GStreamer
  #     obs-gstreamer
  #   ];
  # };
  programs.gpu-screen-recorder = {
    enable = true;
    ui.enable = true; # For overlay
  };

}
