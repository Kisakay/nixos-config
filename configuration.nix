# Step 2: Apply Configuration# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  environment.variables = { RUSTICL_ENABLE = "radeonsi"; };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules =
      [ "ip_tables" "iptable_nat" "wireguard" "snd-aloop" "v4l2loopback" "button.lid_init_state=open" ];
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=3 video_nr=0,1 card_label="DroidCam","OBS Cam" exclusive_caps=1
  '';

  security.polkit.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [ mesa libva libva-utils ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "computer"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.fprintd.enable = true;
  #   services.fprintd.tod.enable = true
  services.fwupd.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # will fix gnome pam
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Select internationalisation properties.

  services.udev.extraRules = ''
    # HyperX Cloud II Wireless (HP Vendor 0x03f0, Product 0x018b)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="018b", MODE="0666"

    # DroidCam V4L2
    SUBSYSTEM=="video4linux", ATTR{name}=="DroidCam", MODE="0666", GROUP="video"
  '';

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Use same config for linux console
  console.useXkbConfig = true;

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  # Configure console keymap
  # console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-mfcl2750dw ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.enable = true; # AJOUTER
  };

  

  hardware.openrazer.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kisakay = {
    isNormalUser = true;
    description = "Anaïs Saraiva";
    extraGroups =
      [ "networkmanager" "wheel" "docker" "libvirtd" "video" "plugdev" "openrazer" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "kisakay" ];
  virtualisation.spiceUSBRedirection.enable = true;

  virtualisation = {

    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";
    };
  };
  services.spice-webdavd.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  virtualisation.docker = {
    enable = true;
    # storageDriver = "btrfs";
    # disk on ext4
  };

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    glib
    gtk3
    libffi
    cairo
    pango
    nspr
    nss
    dbus
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXi
    xorg.libXrandr
    xorg.libXtst
    xorg.libXfixes
    xorg.libxcb
    xorg.libXrender
    alsa-lib
    atk
    # atk-bridge
    cups
    libdrm
    libgbm
    expat
    libxkbcommon
    freetype
    xorg.libXxf86vm
    libGL
    fontconfig
    liberation_ttf
    dejavu_fonts
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-backgroundremoval
      droidcam-obs

      obs-shaderfilter
      advanced-scene-switcher
    ];
  };

  environment.sessionVariables = { LIBVA_DRIVER_NAME = "radeonsi"; };

  environment.systemPackages = with pkgs; [
    # (import ./pkgs/paladrill { inherit pkgs; })

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vlc
    audacious
    droidcam
    android-tools
    v4l-utils

    htop
    btop
    wine
    git
    github-desktop
    # vscode
    vscodium
    steam
    prismlauncher
    bottles
    windterm
    dbeaver-bin
    docker
    entr
    element-desktop
    telegram-desktop
    lunar-client
    signal-desktop
    mumble
    thunderbird
    virt-manager
    # kdePackages.kdenlive
    melt
    gnome-extension-manager
    gnome-tweaks
    libgtop
    gobject-introspection
    filezilla
    zip
    unzip
    curl
    wget
    comic-mono
    nodejs
    zsh
    anydesk
    fastfetch
    onefetch
    flatpak
    yt-dlp
    go
    ffmpeg
    comic-relief
    direnv
    nixfmt-classic
    nixfmt-rfc-style
    kdePackages.kolourpaint
    libxcrypt-legacy
    curl
    fuse
    appimage-run
    killall
    hidapi
    python3
    python3Packages.pip
    python3Packages.hid
    libusb1
    udev
    # Add other dependencies you might need
    python3Packages.setuptools
    python3Packages.wheel
    distrobox
    networkmanagerapplet
    distrobox
    session-desktop
    postgresql
    libreoffice-fresh # or libreoffice-still if you prefer
    hunspell
    hunspellDicts.fr-moderne # Modern French dictionary
    speedtest-cli
    geogebra
    gimp
    ollama
    nss
    ntfs3g
    # jetbrains.idea-community
    maven
    sqlite # lib32-sqlite → Nix doesn’t split 32/64-bit; use `pkgsi686Linux.sqlite` if needed
    openssl # lib32-openssl → similarly, use `pkgsi686Linux.openssl` for 32-bit
    nlohmann_json
    libhandy
    libsodium
    spdlog
    freerdp
    postman
    # windsurf
    python313Packages.grammalecte
    vulkan-tools
    geogebra
    cmake
    pkg-config
    gcc
    nmap
    # spotify

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
    gnomeExtensions.media-controls
    gnomeExtensions.add-to-desktop
    fprintd
    libfprint
    usbutils
    kdePackages.filelight
    onlyoffice-desktopeditors
    acpi
    screen
    tmux
    neovim
    # rpi-imager
    sqlitebrowser
    pulseaudio
    pulseaudioFull

    gnumake
    openssl
    pkg-config

    gcc
    clang
    cmake
    gnumake
    meson
    ninja
    pkg-config
    autoconf
    automake
    libtool

    # Bibliothèques de développement
    openssl
    openssl.dev
    curl
    curl.dev
    zlib
    zlib.dev
    libxml2
    libxml2.dev

    # Bibliothèques réseau
    libssh
    libssh2
    nghttp2
    c-ares

    # Bibliothèques système
    glibc
    glibc.dev
    stdenv.cc.libc

    # Outils de débogage
    gdb
    valgrind
    strace
    ltrace

    # CAMERA WITH USB OVER MY OPPO RENO 13 PRO
    libusb1

    # pour maddie cte folle
    nasm
    gpp

    # crypto mes couilles
    # exodus
    dig
    squashfsTools
    pm2

    unrar

    # tpm 2.0 for virt-manager 
    swtpm

    deezer-enhanced
    lm_sensors

    audacity

    pavucontrol
    qpwgraph

    tree
    p7zip
    smartmontools
    ripgrep
    eclipses.eclipse-java
    xlsx2csv
    cmatrix
    deluge-gtk
    mullvad-vpn

    discordchatexporter-cli

    # .NET related packages
    icu
    jdk21

    chromium

    libva-utils
    wireguard-tools

    tor-browser
    # equibop
    scrcpy

    vesktop
    (discord.override {
      withOpenASAR = true; # can do this here too
      withVencord = true;
      withTTS = true;
    })

    easyeffects
    gnome-sound-recorder

    openrazer-daemon
  ];

  services.tor.settings = {
    UseBridges = true;
    ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
    Bridge = "obfs4 IP:ORPort [fingerprint]";
  };

  environment.variables = {
    PKG_CONFIG_PATH =
      "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.curl.dev}/lib/pkgconfig";
    LIBRARY_PATH = "${pkgs.openssl.out}/lib:${pkgs.curl.out}/lib";
    C_INCLUDE_PATH = "${pkgs.openssl.dev}/include:${pkgs.curl.dev}/include";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    NIXOS_OZONE_WL = "1"; # Force Wayland pour les apps Electron
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Configuration pour les shells de développement
  programs.bash.shellInit = ''
    export CFLAGS="-I${pkgs.openssl.dev}/include -I${pkgs.curl.dev}/include"
    export LDFLAGS="-L${pkgs.openssl.out}/lib -L${pkgs.curl.out}/lib"
  '';

  programs.zsh = {
    enable = true;
    shellInit = ''
      export CFLAGS="-I${pkgs.openssl.dev}/include -I${pkgs.curl.dev}/include"
      export LDFLAGS="-L${pkgs.openssl.out}/lib -L${pkgs.curl.out}/lib"
    '';
  };

  # Activer ccache pour accélérer les compilations
  programs.ccache.enable = true;

  services.mullvad-vpn.enable = true;

  # Documentation de développement
  documentation.dev.enable = true;
  documentation.man.enable = true;

  # Services utiles pour le développement
  services.lorri.enable = true; # Pour direnv et nix-shell

  fonts.packages = with pkgs; [
    # I WANT COMIC SANS MS
    corefonts
    # AND JETBRAIN MONOS PLS
    jetbrains-mono

    # thanks claude
    # Polices pour un support Unicode complet
    noto-fonts
    noto-fonts-cjk-sans # Caractères chinois, japonais, coréens
    noto-fonts-emoji-blob-bin # Emojis
    noto-fonts-lgc-plus # Symboles supplémentaires
    liberation_ttf
    fira-code
    dejavu_fonts
    font-awesome # Icônes

    # Symboles mathématiques et techniques
    unifont

    # Polices spécialisées (optionnel)
    libertine
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = true; # recommandé
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for steam server
    };
  };

  systemd.services.pm2 = {
    enable = true;
    description = "PM2 process manager";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "forking";
      User = "kisakay";
      Environment = [ "HOME=/home/kisakay" "PM2_HOME=/home/kisakay/.pm2" ];

      ExecStart =
        "${pkgs.bash}/bin/bash -c '${pkgs.nodePackages_latest.pm2}/bin/pm2 resurrect && sleep 1'";
      ExecStop = "${pkgs.nodePackages_latest.pm2}/bin/pm2 kill";

      RemainAfterExit = "yes";

      Restart = "on-failure";
      RestartSec = "10s";
      WorkingDirectory = "/home/kisakay";
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitch = "ignore";
  };

  services = {
    # FLATPAK
    flatpak.enable = true;

    # OLLAMA
    ollama = {
      enable = true;
      # Optional: preload models, see https://ollama.com/library
      loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b" ];
    };

    # POSTGRESQL
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;

      initialScript = pkgs.writeText "init.sql" ''
        CREATE DATABASE mydb;
        CREATE USER myuser WITH PASSWORD 'mypassword';
        GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;

        \\c mydb

        GRANT USAGE, CREATE ON SCHEMA public TO myuser;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
          GRANT ALL ON TABLES TO myuser;
      '';
    };

  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      type = "ibus";
      enable = true;
      ibus.engines = with pkgs.ibus-engines; [ ];
    };
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "securityType" = "user";
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "public" = {
        "path" = "/mnt/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };
      "private" = {
        "path" = "/mnt/Shares/Private";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "username";
        "force group" = "groupname";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [ 22 80 443 8000 3000 3001 3871 25565 ];
  networking.firewall.allowedUDPPorts = [ 53 51820 ];
}
