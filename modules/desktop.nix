# Environnement graphique et audio : COSMIC + PipeWire.
{ config, pkgs, ... }:

{
  # Bureau COSMIC uniquement.
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Ordonnanceur System76 pour COSMIC.
  services.system76-scheduler.enable = true;

  # Gestionnaire de mots de passe / clés.
  programs.seahorse.enable = true;

  # Portails XDG pour COSMIC.
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

  # Variables de session COSMIC / Wayland.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    COSMIC_DATA_CONTROL_ENABLED = "1";
  };

  # Clavier.
  # COSMIC étant Wayland, cette configuration reste utile
  # pour les paramètres clavier du système.
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };
  console.useXkbConfig = true;

  # Nerd Font.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Audio via PipeWire.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
