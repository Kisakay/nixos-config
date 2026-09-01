# Paquets installés dans le profil système.
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Utilitaires système
    vim
    wget
    unzip
    zip
    killall
    htop
    btop
    gitFull
    direnv
    nixfmt

    # Shell et terminal
    zsh
    windterm
    fastfetch
    onefetch
    ffmpeg

    # Applications
    rnote
    vlc
    thunderbird
    krita
    discord
    wine

    # Extensions GNOME
    gnome-extension-manager
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.caffeine
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.desktop-cube
    gnomeExtensions.force-quit
    gnomeExtensions.ip-finder
    gnomeExtensions.just-perfection
    gnomeExtensions.runcat
    gnomeExtensions.appindicator
    gnomeExtensions.customize-clock-on-lock-screen
    gnomeExtensions.emoji-copy
    gnomeExtensions.user-themes
    gnomeExtensions.vscode-workspaces-gnome
    gnomeExtensions.media-controls
    gnomeExtensions.dash-to-panel
    gnomeExtensions.desktop-clock
    gnomeExtensions.window-desaturation
    gnomeExtensions.add-to-desktop

    # BTS SIO
    libreoffice-stable
    vscodium
    hunspellDicts.fr-moderne # Dictionnaire français moderne
    gimp
    geogebra
    nmap
    kdePackages.kolourpaint

    # Bibliothèques et outils
    sqlite
    python313Packages.grammalecte
    nss
    ntfs3g
    unrar
    p7zip
    xlsx2csv
    github-desktop
  ];
}
