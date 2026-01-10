{ stdenv, fetchurl ? null, lib, audacious }:

stdenv.mkDerivation rec {
  pname = "audacious-discord-rpc";
  version = "1.0";

  # Si vous avez le .so localement :
  src = ./discord-rpc.so;  # ou utilisez fetchurl si hébergé en ligne

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/audacious/General
    cp $src $out/lib/audacious/General/discord-rpc.so
  '';

  meta = with lib; {
    description = "Discord Rich Presence plugin for Audacious";
    homepage = "https://github.com/onegen-dev/audacious-discord-rpc";
    license = licenses.mit;  # vérifiez la licence réelle
    platforms = platforms.linux;
  };
}