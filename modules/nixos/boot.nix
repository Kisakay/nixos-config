{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    # v4l2loopback / snd-aloop ne sont PAS chargés au boot :
    # ils créaient des transactions sound.target destructives à chaque
    # extinction ("Transaction for sound.target/start is destructive").
    kernelModules = [ ];
    kernelParams = [
      # Ryzen 5700X (Vermeer) : pstate actif explicite, driver amd-pstate-epp
      # déjà actif (vérifié via scaling_driver).
      "amd_pstate=active"
    ];
    blacklistedKernelModules = [ "sp5100_tco" ];

    extraModulePackages = [ ];

    kernel.sysctl."net.ipv4.ip_forward" = 1;
  };

  # Évite qu'un service récalcitrant bloque l'extinction indéfiniment
  # (le symptôme : écran figé sur les kernel logs, poweroff jamais atteint).
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "20s";
    DefaultTimeoutAbortSec = "20s";
  };
}
