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
    remmina

    obs-studio
    steam
    # Nix Inteligience
    nixfmt
    nil
    sshfs
    nixd

    # Edit
    obsidian

    # Shell et terminal
    zsh
    windterm
    fastfetch
    onefetch
    ffmpeg
    file

    # Applications
    vlc
    thunderbird
    krita
    discord
    # dorion
    chromium
    wine

    # BTS SIO
    libreoffice-qt-stable
    vscodium
    hunspellDicts.fr-moderne # Dictionnaire français moderne
    gimp
    xournalpp
    libinput

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

    # Utils
    acpi
    windterm
    cisco-packet-tracer_9
    tree
    # Logiciel d'édition de texte
    onlyoffice-desktopeditors
    sushi
    cosmic-viewer
    cosmic-ext-calculator

    kdePackages.kdeconnect-kde
    kdePackages.filelight

    prismlauncher
    php
    gnome-disk-utility
    tidal-hifi
    flameshot
    signal-desktop
  ];
}
