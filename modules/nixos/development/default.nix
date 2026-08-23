{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;

    libraries = with pkgs; [
      glib
      gtk3
      libffi
      cairo
      pango
      nspr
      nss
      dbus
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxi
      libxrandr
      libxtst
      libxfixes
      libxcb
      libxrender
      alsa-lib
      atk
      cups
      libdrm
      libgbm
      expat
      libxkbcommon
      freetype
      libxxf86vm
      libGL
      fontconfig
      liberation_ttf
      dejavu_fonts
    ];
  };

  programs.ccache.enable = true;
  services.lorri.enable = true;

  documentation = {
    dev.enable = true;
    man.enable = true;
  };

  environment.sessionVariables = {
    GIT_EXEC_PATH = "${pkgs.gitFull}/libexec/git-core";
    GIT_SSH_COMMAND = "ssh";

    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.curl.dev}/lib/pkgconfig";
    LIBRARY_PATH = "${pkgs.openssl.out}/lib:${pkgs.curl.out}/lib";
    C_INCLUDE_PATH = "${pkgs.openssl.dev}/include:${pkgs.curl.dev}/include";
  };

  programs.bash.shellInit = ''
    export CFLAGS="-I${pkgs.openssl.dev}/include -I${pkgs.curl.dev}/include"
    export LDFLAGS="-L${pkgs.openssl.out}/lib -L${pkgs.curl.out}/lib"
  '';
}
