{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    thunderbird
    telegram-desktop
    signal-desktop
    element-desktop
    discord
    mumble
    github-desktop

    anydesk
    remmina
    rustdesk
    freerdp

    filezilla
    deluge-gtk
    wine

    prismlauncher
    lunar-client

    networkmanagerapplet
    kdePackages.kolourpaint
    kdePackages.filelight
    gnome-disk-utility
    desktop-file-utils
  ];
}
