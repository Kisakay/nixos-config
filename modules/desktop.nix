# Environnement graphique et audio : X11, GNOME, COSMIC et PipeWire.
{ config, pkgs, ... }:

{
  # X11 + GDM (choix de la session au login : GNOME ou COSMIC).
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.displayManager.gdm.enable = true;

  # Bureaux disponibles.
  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = true;

  # GNOME : apps de base, keyring et dconf.
  services.gnome.core-apps.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

  # COSMIC : portail Wayland, scheduler System76 et variables de session.
  services.system76-scheduler.enable = true;
  programs.seahorse.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
    ];
    config.common = {
      default = "cosmic";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    COSMIC_DATA_CONTROL_ENABLED = 1;
  };

  # Clavier.
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };
  console.useXkbConfig = true;

  # Polices (Nerd Fonts pour les icônes de fastfetch, etc.).
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Audio via PipeWire (PulseAudio désactivé).
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
