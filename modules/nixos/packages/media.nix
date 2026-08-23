{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vlc
    audacious
    audacious-plugins

    yt-dlp
    ffmpeg
    melt
    gimp
    audacity
    easyeffects

    pulseaudioFull
    pavucontrol
    qpwgraph
    gnome-sound-recorder

    scrcpy
    droidcam
    android-tools
    v4l-utils

    vulkan-tools
    radeontop
  ];
}
