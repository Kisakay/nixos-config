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

  programs.seahorse.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
      # Isolation COSMIC (Wayland) / i3 (X11) : chaque session utilise son
      # portail, le sélecteur de fichiers ne casse plus sous i3.
      xdg-desktop-portal-gtk
    ];

    config = {
      cosmic.default = "cosmic";
      i3.default = "gtk";
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
