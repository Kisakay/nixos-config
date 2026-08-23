{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscodium
    zed-editor
    postman
    dbeaver-bin
    direnv
    nixfmt
    distrobox
    prettier
    entr

    nodejs
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.wheel
    python3Packages.hid
    go
    rustup
    clippy
    zig
    jdk21
    maven

    gcc
    clang
    cmake
    gnumake
    meson
    ninja
    pkg-config
    autoconf
    automake
    libtool
    nasm
    gpp

    gdb
    valgrind
    strace
    ltrace
    bpftrace
    linuxPackages.bpftrace
    perf
    linuxPackages.perf
    bcc

    openssl
    openssl.dev
    curl.dev
    zlib
    zlib.dev
    libxml2
    libxml2.dev
    libxtst
    libssh
    libssh2
    nghttp2
    c-ares
    glibc
    glibc.dev
    stdenv.cc.libc
    nss
    libxcrypt-legacy
    hidapi
    nlohmann_json
    libhandy
    libsodium
    spdlog
    gobject-introspection
    libgtop
    icu
    sqlite

    sqlitebrowser
    eclipses.eclipse-java
    pm2
  ];
}
