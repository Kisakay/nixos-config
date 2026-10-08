# Matériel : Intel iGPU (Framework Laptop 12, i3-1315U Raptor Lake-U) + impression.
{ config, pkgs, ... }:

{
  # Firmware non-libre obligatoire pour i915 / GuC / HuC.
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Accélération graphique : sans ça, Electron/Chromium/Wayland
  # tombent en SwiftShader -> écran blanc, artefacts, freeze.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD, le bon driver VA-API pour Raptor Lake
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime # OpenCL, aide Chromium/Electron/Tauri
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # PSR = source n°1 des freeze/artefacts sur les iGPU Intel portables.
  # GuC à 2 = HuC+GuC pour la vidéo, sans le Soumission GuC encore instable.
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.enable_guc=2"
  ];

  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-mfcl2750dw ];
  };
}
