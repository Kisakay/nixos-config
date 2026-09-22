{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-still
    onlyoffice-desktopeditors
    geogebra

    hunspell
    hunspellDicts.fr-moderne
    python313Packages.grammalecte

    xlsx2csv
  ];
}
