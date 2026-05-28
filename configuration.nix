# Step 2: Apply Configuration# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # My Current Username
  myUsername = "kisakay";
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages;
    kernelModules = [
      "ip_tables"
      "iptable_nat"
      "wireguard"
      "snd-aloop"
      "v4l2loopback"
      "amdgpu"
      "kernelModules"
    ];
    kernelParams = [ "usbcore.autosuspend=-1" ];
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=3 video_nr=0,1 card_label="DroidCam","OBS Cam" exclusive_caps=1
  '';
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  security.polkit.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      mesa
      libva
      libva-utils
    ];
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

  services.timesyncd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.fprintd.enable = true;
  #   services.fprintd.tod.enable = true
  services.fwupd.enable = true;

  services.xserver.enable = true;

  # Ly Greeter
  services.displayManager.ly.enable = true;

  # i3 WM
  services.displayManager.defaultSession = "none+i3";
  # ---- I3 PART ----
  services.xserver.windowManager.i3.enable = true;

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;

  services.xserver.windowManager.i3.extraPackages = with pkgs; [
    dmenu
    i3status
    i3lock
  ];

  #   ---- END OF I3 PART ----

  # Select internationalisation properties.

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

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    alsa.enable = true;

    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.enable = true; # AJOUTER
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${myUsername} = {
    isNormalUser = true;
    description = "Anaïs Saraiva";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "video"
      "render"
      "plugdev"
      "docker"
    ];
  };

  users.users.vesktopbox = {
    isNormalUser = true;
    description = "Distrobox hors VPN";

    extraGroups = [
      "networkmanager"
      "video"
      "render"
      "audio"
    ];
  };

  programs.dconf.enable = true;
  xdg.mime.enable = true;

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ myUsername ];
  virtualisation.spiceUSBRedirection.enable = true;

  security.pam.services.ly.enableGnomeKeyring = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true; # enable copy and paste between host and guest

  # PELICAN.DEV PANEL
  services.pelican.panel = {
    enable = true;
    app = {
      url = "http://127.0.0.1";
      keyFile = "/etc/nixos/app.key";
    };
    database.host = "127.0.0.1";
    database.port = 5432;
    database.name = "pelican";
    database.user = "pelican-panel";
    database.passwordFile = "/etc/nixos/.password";
    mail.mailer = "log";
  };

  services.pelican.wings = {
    enable = true;
    openFirewall = false;
    uuid = "121994bf-f7be-40c6-99da-8b11be74c9b7";
    rootDir = "/var/lib/pelican";
    remote = "http://127.0.0.1";
    tokenIdFile = "/etc/nixos-local/pelican/wings-token-id";
    tokenFile = "/etc/nixos-local/pelican/wings-token";
    api.port = 8080;
    api.uploadLimit = 4096;
    api.ssl.enable = false;
    system.sftp.port = 2022;
  };

  # docker part
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

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
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxi
    libxrandr
    libxtst
    libxfixes
    libxcb
    libxrender
    alsa-lib
    atk
    # atk-bridge
    cups
    libdrm
    libgbm
    expat
    libxkbcommon
    freetype
    libxxf86vm
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

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    GIT_EXEC_PATH = "${pkgs.gitFull}/libexec/git-core";
    XDG_CURRENT_DESKTOP = "i3";
    GIT_SSH_COMMAND = "ssh";
  };

  environment.systemPackages = with pkgs; [
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

    # vscode
    vscodium
    steam
    prismlauncher
    # bottles
    windterm
    dbeaver-bin
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
    nixfmt
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
    networkmanagerapplet
    distrobox
    # session-desktop
    postgresql
    libreoffice-fresh # or libreoffice-still if you prefer
    hunspell
    hunspellDicts.fr-moderne # Modern French dictionary
    speedtest-cli
    geogebra
    gimp
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
    file

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
    # mullvad-vpn

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

    easyeffects
    gitFull
    git-lfs

    #Claude
    claude-code
    claude-monitor
    claude-agent-acp
    claude-mergetool
    claude-code-router
    # custom part
    system-config-printer
    rembg

    # rust lang
    rustc
    cargo
    rustfmt
    clippy

    # rtc
    coturn

    # rofi
    zed-editor

    # DEV
    android-studio-tools
    android-studio

    vnstat
    qtox

    (discord.override {
      withOpenASAR = true; # can do this here too
      withVencord = true;
    })

    # I3 PART
    rofi
    picom
    dunst
    feh
    pavucontrol
    xclip
    wmctrl
    rofi
    picom
    dunst
    feh
    plank
    nitrogen
    mpvpaper
    xwinwrap
    mpv
    alacritty
    flameshot
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    xdotool
    copyq
    rofimoji
    pamixer
    jq
    xdpyinfo
    clipman
    xcape
    xmodmap
    playerctl
    wmctrl
    #noto-font-emoji # emoji font
    rofimoji # emoji picker via Rofi
    emote # emoji GTK selector
    rofi # application launcher
    xwininfo
    glava

    iwgtk
    twemoji-color-font
    libnotify
    i3status
    i3blocks
    xdotool
    stalonetray

    # MESSENGER
    session-desktop

    # Thermal Managment
    radeontop

    # virt-manager related
    dnsmasq
    # tpm 2.0 for virt-manager
    swtpm

    kdePackages.breeze
    bibata-cursors
    sl

    git-credential-manager
    nautilus

    desktop-file-utils
    gnome-disk-utility
  ];

  services.vnstat.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  services.hardware.bolt.enable = true;

  services.xserver.excludePackages = with pkgs; [
    xterm
  ];

  services.tor.settings = {
    UseBridges = true;
    ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
    Bridge = "obfs4 IP:ORPort [fingerprint]";
  };

  environment.variables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.curl.dev}/lib/pkgconfig";
    LIBRARY_PATH = "${pkgs.openssl.out}/lib:${pkgs.curl.out}/lib";
    C_INCLUDE_PATH = "${pkgs.openssl.dev}/include:${pkgs.curl.dev}/include";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    # NIXOS_OZONE_WL = "1"; # Force Wayland pour les apps Electron
    # ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    RUSTICL_ENABLE = "radeonsi";
    MESA_SHADER_CACHE_MAX_SIZE = "10G";
    MESA_SHADER_CACHE_DIR = "/home/${myUsername}/.cache/mesa_shader_cache";
    __GL_SHADER_DISK_CACHE = "1";

    XCURSOR_THEME = "Breeze";
    XCURSOR_SIZE = "24";
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

  # services.mullvad-vpn.enable = true;

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

    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.hack
    nerd-fonts.symbols-only
    noto-fonts-color-emoji

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
    enable = true;
    settings = {
      PasswordAuthentication = false; # recommandé
      PermitRootLogin = "no";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall = true; # Open ports in the firewall for steam server
    };
  };

  systemd.services.pm2 = {
    enable = true;
    description = "PM2 process manager";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "forking";
      User = myUsername;
      Environment = [
        "HOME=/home/${myUsername}"
        "PM2_HOME=/home/${myUsername}/.pm2"
      ];

      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.pm2}/bin/pm2 resurrect && sleep 1'";
      ExecStop = "${pkgs.pm2}/bin/pm2 kill";

      RemainAfterExit = "yes";

      Restart = "on-failure";
      RestartSec = "10s";
      WorkingDirectory = "/home/${myUsername}";
    };
  };

  services.logind.settings.Login = {
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitch = "ignore";
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";
  };

  services = {
    # FLATPAK
    flatpak.enable = true;

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

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;

  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    8000
    3000
    3001
    3871
    25565
  ];
  networking.firewall.allowedUDPPorts = [
    53
    51820
  ];

  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
