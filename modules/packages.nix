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

    steam
    # Nix Inteligience
    nixfmt
    nil
    sshfs
    nixd

    # Edit
    obsidian
    anydesk
    # Shell et terminal
    zsh
    windterm
    fastfetch
    onefetch
    ffmpeg
    file

    telegram-desktop

    # Applications
    vlc
    thunderbird
    krita

    # Discord est fourni par le mod Nightcord (voir flake-packages.nix)

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
    # cisco-packet-tracer_9 # désactivé : requiert un .deb manuel (nix-store --add-fixed) et casse le build après flake update
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
    # tidal-hifi : force XWayland (fenêtre blanche en Wayland natif sur COSMIC).
    (symlinkJoin {
      name = "tidal-hifi-wrapped";
      paths = [ tidal-hifi ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/tidal-hifi \
          --add-flags "--ozone-platform=x11"
      '';
    })
    signal-desktop
  ];
}
