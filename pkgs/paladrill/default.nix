{ pkgs ? import <nixpkgs> {} }:

let
  appimage = ./PalaDrill-setup-2.2.0.AppImage;
  icon = ./LoadingSeal.png;
in

pkgs.appimageTools.wrapType2 {
  pname = "paladrill";
  version = "2.1.0";
  src = appimage;

  extraInstallCommands = ''
    # Icône
    install -Dm644 ${icon} \
      $out/share/icons/hicolor/256x256/apps/paladrill.png

    # .desktop
    mkdir -p $out/share/applications
    cat > $out/share/applications/paladrill.desktop <<EOF
[Desktop Entry]
Name=PalaDrill
Exec=paladrill %U
Terminal=false
Type=Application
Icon=paladrill
Categories=Utility;
EOF
  '';
}
