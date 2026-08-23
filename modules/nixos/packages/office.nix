{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-fresh
    onlyoffice-desktopeditors
    geogebra

    hunspell
    hunspellDicts.fr-moderne
    python313Packages.grammalecte

    xlsx2csv
  ];
}
