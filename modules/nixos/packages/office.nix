{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    libreoffice-stable
    geogebra

    hunspell
    hunspellDicts.fr-moderne
    python313Packages.grammalecte

    xlsx2csv
  ];
}
