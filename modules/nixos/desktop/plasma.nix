{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      # Évite le verrouillage sur une session vide après logout
      defaultSession = "plasma";
    };

    desktopManager.plasma6.enable = true;
  };

  programs = {
    dconf.enable = true;
    # Intégration Qt / KDE : sélecteur de fichiers, porte-monnaie, etc.
    kde-pim.enable = false;
  };

  # Plasma 6 gère déjà xdg-desktop-portal-kde automatiquement,
  # on garde juste le portal activé sans forcer le backend.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      kdePackages.xdg-desktop-portal-kde
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  environment.systemPackages = with pkgs; [
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.filelight
    kdePackages.kolourpaint
    kdePackages.ksshaskpass
    kdePackages.kwallet-pam
    kdePackages.plasma-systemmonitor
    kdePackages.sddm-kcm
    kdePackages.partitionmanager
    haruna
  ];

  # power-profiles-daemon (défini dans hardware/framework.nix) est le
  # daemon recommandé pour Framework 13 AMD + KDE. Pas de system76-scheduler.
}
