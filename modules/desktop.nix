# Environnement graphique et audio : X11, GNOME, COSMIC et PipeWire.
{ config, pkgs, ... }:

{
  # X11 + GDM (choix de la session au login : GNOME ou COSMIC).
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  # Bureaux disponibles.
  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = true;

  # GNOME : apps de base, keyring et dconf.
  services.gnome.core-apps.enable = true;
  services.gnome.gnome-keyring.enable = true;
  programs.dconf.enable = true;

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
