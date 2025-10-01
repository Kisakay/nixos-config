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
    kernelModules = [ "ip_tables" "iptable_nat" ];
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      mesa.drivers
      vulkan-loader
      vulkan-validation-layers
      vulkan-tools
      mesa.opencl
      rocmPackages.clr.icd
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.fprintd.enable = true;
  services.fwupd.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  services.udev.extraRules = ''
    # HyperX Cloud II Wireless (HP Vendor 0x03f0, Product 0x018b)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="018b", MODE="0666"
  '';

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kisakay = {
    isNormalUser = true;
    description = "Anaïs Saraiva";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "kisakay" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

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
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./davinci-resolve-paid.nix { })
    (import /etc/nixos/pkgs/paladrill { inherit pkgs; })

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    vlc
    obs-studio
    htop
    wine
    git
    github-desktop
    vscode
    steam
    prismlauncher
    bottles
    windterm
    dbeaver-bin
    vesktop
    mullvad-vpn
    docker
    entr
    element-desktop
    telegram-desktop
    lunar-client
    signal-desktop
    mumble
    thunderbird
    spotify
    virt-manager
    libsForQt5.kdenlive
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
    dolphin-emu
    libretro.citra
    fastfetch
    flatpak
    yt-dlp
    go
    ffmpeg
    comic-relief
    direnv
    nixfmt
    kdePackages.kolourpaint
    easyeffects
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
    session-desktop
    postgresql
    libreoffice-fresh # or libreoffice-still if you prefer
    hunspell
    hunspellDicts.fr-moderne # Modern French dictionary
    emacs
    speedtest-cli
    geogebra
    gimp
    ollama
    nss
    ntfs3g
    jetbrains.idea-community
    maven
    sqlite # lib32-sqlite → Nix doesn’t split 32/64-bit; use `pkgsi686Linux.sqlite` if needed
    openssl # lib32-openssl → similarly, use `pkgsi686Linux.openssl` for 32-bit
    nlohmann_json
    libhandy
    libsodium
    spdlog
    freerdp
    postman
    windsurf
    python313Packages.grammalecte
    vulkan-tools
    geogebra
    cmake
    pkg-config
    gcc
    nmap
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
  # services.openssh.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remoteplay
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for steam server
    };
  };

  systemd.user.services.pm2 = {
    description = "PM2 process manager";
    after = [ "network.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart =
        "/home/kisakay/.bun/install/global/node_modules/pm2/bin/pm2 resurrect";
      ExecReload =
        "/home/kisakay/.bun/install/global/node_modules/pm2/bin/pm2 reload all";
      ExecStop =
        "/home/kisakay/.bun/install/global/node_modules/pm2/bin/pm2 kill";
      Restart = "on-failure";
      Environment = [
        "PATH=/home/kisakay/.bun/bin:${builtins.getEnv "PATH"}"
        "PM2_HOME=/home/kisakay/.pm2"
      ];
    };
  };

  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b" ];
  };
  services = { flatpak.enable = true; };

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

  networking.firewall.enable = false;
  networking.firewall.allowPing = true;

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}

