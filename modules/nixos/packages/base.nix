{ pkgs, ... }:

{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    neovim
    tmux
    screen

    htop
    btop
    fastfetch
    onefetch
    tree
    ripgrep
    jq

    gitFull
    gh
    git-credential-manager

    zsh
    lsof
    procs
    killall
    sl
    cmatrix

    curl
    wget
    file
    zip
    unzip
    unrar
    p7zip
    squashfsTools

    usbutils
    ntfs3g
    smartmontools

    appimage-run
    fuse
  ];
}
