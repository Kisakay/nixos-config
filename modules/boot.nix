# Démarrage : bootloader, noyau et déverrouillage LUKS.
{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Noyau le plus récent.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Partition swap chiffrée (voir aussi swapDevices dans hardware-configuration.nix).
  boot.initrd.luks.devices."luks-1c9181b1-f574-4464-84f5-383abd1f2c51".device =
    "/dev/disk/by-uuid/1c9181b1-f574-4464-84f5-383abd1f2c51";
}
