{ pkgs, ... }:

let
  System = import ../../../hosts/computer/username.nix;
in
{
  # RX 7600 XT (Navi 33, RDNA3, gfx1102) — GPU unique (le 5700X n'a pas d'iGPU).
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      mesa
      libva
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
    ];
  };

  # ROCm volontairement absent : mal supporté sur gfx1102, et ollama +
  # llama-cpp tournent déjà en Vulkan (RADV), le bon backend pour RDNA3.
  services.lact.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    RUSTICL_ENABLE = "radeonsi";

    MESA_SHADER_CACHE_MAX_SIZE = "10G";
    MESA_SHADER_CACHE_DIR = "/home/${System.Username}/.cache/mesa_shader_cache";
    __GL_SHADER_DISK_CACHE = "1";
  };

  environment.systemPackages = with pkgs; [
    lact
    libva-utils
    radeontop
    vulkan-tools
  ];
}
