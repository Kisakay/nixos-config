{ pkgs, ... }:

let
  # PhotoClair : galerie et tri local de photos (dépôt UserNonFriendly/PhotoClair).
  # Le code est lu directement dans le dépôt local : une modification de
  # PhotoClair ne demande pas de reconstruire le système.
  src = "/home/kisakay/Documents/Code/GitHub/PhotoClair";

  python = pkgs.python3.withPackages (
    ps: with ps; [
      tkinter
      pillow
      pillow-heif
      hachoir
      pystray
      pygobject3
      send2trash
      pyzipper
      piexif
    ]
  );

  # wrapGAppsHook3 fournit les typelibs GTK/AppIndicator : sans eux, pas
  # d'icône dans la zone de notification de COSMIC.
  photoclair = pkgs.stdenv.mkDerivation {
    pname = "photoclair";
    version = "2.0.0";
    dontUnpack = true;
    nativeBuildInputs = [
      pkgs.wrapGAppsHook3
      pkgs.gobject-introspection
    ];
    buildInputs = [
      pkgs.gtk3
      pkgs.libayatana-appindicator
    ];
    installPhase = ''
      makeWrapper ${python}/bin/python3 $out/bin/photoclair \
        --add-flags "-m photoclair.app" \
        --prefix PYTHONPATH : ${src} \
        --suffix PATH : /run/current-system/sw/bin
    '';
  };

  desktopItem = pkgs.makeDesktopItem {
    name = "photoclair";
    desktopName = "PhotoClair";
    comment = "Visionner, dédupliquer et classer les photos";
    exec = "photoclair";
    icon = "folder-pictures";
    categories = [
      "Graphics"
      "Utility"
    ];
  };
in
{
  # Démarrage à l'ouverture de session : voir session-autostart.nix.
  environment.systemPackages = [
    photoclair
    desktopItem
  ];
}
