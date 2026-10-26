{ pkgs, lib, ... }:

let
  acheron = pkgs.stdenv.mkDerivation {
    pname = "acheron";
    version = "unstable";

    src = /home/kisa/Applications/acheron;

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

      # Audio : dynamic loading for miniaudio
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

    installPhase = ''
      runHook preInstall
      cmake --install . --prefix "$out"
      install -Dm644 ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt \
        "$out/bin/certs/cacert.pem"
      runHook postInstall
    '';

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
  };
in
{
  environment.systemPackages = [ acheron ];
}
