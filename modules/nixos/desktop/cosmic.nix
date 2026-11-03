{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;
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

  programs.seahorse.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
      xdg-desktop-portal-gtk
    ];

    config = {
      cosmic.default = "cosmic";
      common.default = "*";
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    COSMIC_DATA_CONTROL_ENABLED = 1;
  };

  environment.systemPackages = with pkgs; [
  ];
  services.system76-scheduler.enable = true;
}
