# Environnement graphique et audio : X11, GNOME et PipeWire.
{ config, pkgs, ... }:

{
  # X11 + GNOME.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
