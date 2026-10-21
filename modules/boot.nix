# Démarrage : bootloader, noyau et déverrouillage LUKS.
{ config, pkgs, ... }:

{
  boot = {
    # Bootloader systemd-boot
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    # Noyau le plus récent
    kernelPackages = pkgs.linuxPackages_latest;

    initrd.luks.devices."luks-1c9181b1-f574-4464-84f5-383abd1f2c51".device =
      "/dev/disk/by-uuid/1c9181b1-f574-4464-84f5-383abd1f2c51";

    # Plymouth
    plymouth = {
      enable = true;
      theme = "spinner";
    };

    # Démarrage silencieux
    consoleLogLevel = 3;
    initrd.verbose = false;

    kernelParams = [
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
