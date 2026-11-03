{ pkgs, lib, ... }:

let
  acheron = pkgs.stdenv.mkDerivation {
    pname = "acheron";
    version = "unstable-2026-10-09";

    src = pkgs.fetchgit {
      url = "https://github.com/ouwou/acheron.git";
      rev = "e5337a5f3b2ca2978dbf48bbbe124e3a62926591";
      hash = "sha256-7YJA8ZriAC/olfCeWw7B9YqEk40+Gbq4GtBMUBEhYSY=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      cmake
      ninja
      pkg-config
      qt6.wrapQtAppsHook
      qt6.qttools
    ];

    buildInputs = with pkgs; [
      qt6.qtbase
      qt6.qtsvg
      qt6.qtimageformats
      curl-impersonate
      openssl
      zlib
      libsodium
      opus
      libsecret
      nlohmann_json
      libpulseaudio
      alsa-lib
      libjack2
    ];

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
      "-DUSE_VCPKG=OFF"
      "-DBUILD_TESTS=OFF"
      "-DENABLE_VOICE=ON"
      "-DENABLE_RNNOISE=OFF"
      "-DENABLE_FFMPEG=OFF"
      "-DENABLE_LOTTIE=OFF"
      "-DALLOW_PLAIN_CURL=OFF"
      "-DCURL_INCLUDE_DIR=${pkgs.curl-impersonate.dev}/include"
      "-DCURL_LIBRARY=${pkgs.curl-impersonate}/lib/libcurl-impersonate.so"
    ];

    qtWrapperArgs = [
      "--prefix"
      "LD_LIBRARY_PATH"
      ":"
      (lib.makeLibraryPath [
        pkgs.libpulseaudio
        pkgs.alsa-lib
        pkgs.libjack2
      ])
    ];

    installPhase = ''
      runHook preInstall
      cmake --install . --prefix "$out"
      install -Dm644 ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
        "$out/bin/certs/cacert.pem"
      runHook postInstall
    '';

    meta = {
      description = "Native Qt Discord client with voice support";
      homepage = "https://github.com/ouwou/acheron";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "acheron";
    };
  };
in
{
  environment.systemPackages = [ acheron ];
}
