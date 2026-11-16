# WordCraft — traitement de texte (https://github.com/storytold/wordcraft).
# Utilise l'AppImage officielle précompilée : aucune compilation Rust.
# Mise à jour : changer `version` et `hash` (SHA256SUMS.txt de la release,
# converti avec `nix hash convert --hash-algo sha256 --to sri <hex>`).
{ pkgs, ... }:

let
  pname = "wordcraft";
  version = "0.18.1";

  src = pkgs.fetchurl {
    url = "https://github.com/storytold/wordcraft/releases/download/v${version}/wordcraft-${version}-linux-x86_64.AppImage";
    hash = "sha256-u8XBWwbUQDz9WllHW9+SZKScK88fktEjMRtQqdzjyIg=";
  };

  extracted = pkgs.appimageTools.extractType2 { inherit pname version src; };

  wordcraft = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    # Raccourci menu, icônes et types MIME (ouvrir les .docx, .odt…).
    extraInstallCommands = ''
      mkdir -p $out/share
      cp -r ${extracted}/usr/share/applications $out/share/
      cp -r ${extracted}/usr/share/icons $out/share/
      cp -r ${extracted}/usr/share/mime $out/share/
      cp -r ${extracted}/usr/share/metainfo $out/share/
    '';
  };
in
{
  environment.systemPackages = [ wordcraft ];
}
