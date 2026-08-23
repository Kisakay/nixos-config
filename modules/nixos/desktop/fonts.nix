{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    corefonts
    comic-mono
    comic-relief

    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji-blob-bin
    noto-fonts-lgc-plus
    noto-fonts-color-emoji

    liberation_ttf
    dejavu_fonts
    fira-code
    font-awesome
    libertine
    unifont

    nerd-fonts.fira-code
    nerd-fonts.iosevka
    nerd-fonts.hack
    nerd-fonts.symbols-only

    bibata-cursors
    kdePackages.breeze
  ];
}
