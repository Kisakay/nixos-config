{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    desktopManager.cosmic.enable = true;
    displayManager.cosmic-greeter.enable = true;

    gnome = {
      core-apps.enable = true;
      gnome-keyring.enable = true;
    };
  };

  programs.seahorse.enable = true;
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;

    extraPortals = with pkgs; [
      xdg-desktop-portal-cosmic
    ];

    config.common.default = "*";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
