{ pkgs, inputs, ... }:

{
  # Overlay plein écran façon ShadowPlay (Alt+Z), au lieu de l'ancienne UI GTK
  programs.gpu-screen-recorder = {
    enable = true;
    ui.enable = true;
  };

  environment.systemPackages = with pkgs; [
    thunderbird
    telegram-desktop
    signal-desktop
    element-desktop

    # mumble
    github-desktop

    # anydesk
    remmina
    # rustdesk
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

    inputs.tidaLuna.packages.${stdenv.hostPlatform.system}.default
  ];
}
