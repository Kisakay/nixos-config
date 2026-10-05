{ pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.fwupd.enable = true;

  # Tour desktop Ryzen : power-profiles-daemon suffit (profils balanced/
  # performance exposés à COSMIC). PAS system76-power : conçu pour les
  # laptops System76, il spamme "does not have switchable graphics"
  # sur une tour mono-GPU discrète.
  hardware.system76.power-daemon.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = true;

  # Pas de logind/sleep/upower overrides : ce sont des défauts laptop
  # (ignore lid, AllowSuspend=no). Sur tour on garde les défauts NixOS
  # (suspend/poweroff normaux).

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];
}
