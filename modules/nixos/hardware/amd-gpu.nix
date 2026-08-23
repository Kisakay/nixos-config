{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [
      mesa
      libva
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    RUSTICL_ENABLE = "radeonsi";

    MESA_SHADER_CACHE_MAX_SIZE = "10G";
    MESA_SHADER_CACHE_DIR = "/home/kisakay/.cache/mesa_shader_cache";
    __GL_SHADER_DISK_CACHE = "1";
  };

  environment.systemPackages = with pkgs; [
    libva-utils
    radeontop
    vulkan-tools
  ];
}
