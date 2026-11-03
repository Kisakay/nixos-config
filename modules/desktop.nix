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

  # Fix partage d'écran : le portail COSMIC envoie create_frame avant d'avoir
  # détruit la frame précédente -> cosmic-comp le déconnecte (protocol error
  # ext_image_copy_capture_session_v1) et le flux PipeWire meurt au bout de ~2 s.
  # Patch upstream pas encore mergé : https://github.com/pop-os/cosmic-protocols/pull/95
  # À retirer quand xdg-desktop-portal-cosmic embarquera le fix.
  nixpkgs.overlays = [
    (final: prev: {
      xdg-desktop-portal-cosmic = prev.xdg-desktop-portal-cosmic.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          patch -p1 -d "$(echo "$cargoDepsCopy"/source-git-*/cosmic-client-toolkit-*)" \
            < ${./patches/cosmic-screencopy-destroy-frame-first.patch}
        '';
      });
    })
  ];

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

  programs.nix-ld.enable = true;
}
