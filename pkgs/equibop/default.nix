{ pkgs ? import <nixpkgs> {} }:

let
  appimage = ./Equibop-3.0.9.AppImage;
  icon = ./icon.png;
in

pkgs.appimageTools.wrapType2 {
  pname = "equibop";
  version = "3.0.9";
  src = appimage;

  extraInstallCommands = ''
    # Icône
    install -Dm644 ${icon} \
      $out/share/icons/hicolor/256x256/apps/equibop.png

    # .desktop
    mkdir -p $out/share/applications
    cat > $out/share/applications/equibop.desktop <<EOF
[Desktop Entry]
Name=Equibop
Exec=equibop %U
Terminal=false
Type=Application
Icon=equibop
Categories=Utility;
EOF
  '';
}
