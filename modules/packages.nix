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
    vlc
    thunderbird
    krita
    discord
    wine

    # BTS SIO
    libreoffice-stable
    vscodium
    hunspellDicts.fr-moderne # Dictionnaire français moderne
    gimp
    geogebra
    nmap
    kdePackages.kolourpaint
    zed-editor

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
