{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-stable
    onlyoffice-desktopeditors
    geogebra

    hunspell
    hunspellDicts.fr-moderne
    python313Packages.grammalecte

    xlsx2csv
  ];
}
