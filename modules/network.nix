# Réseau : nom d'hôte, NetworkManager, Wi-Fi et pare-feu.
{ config, pkgs, ... }:

{
  networking.hostName = "fw12";
  networking.wireless.enable = true; # Support Wi-Fi via wpa_supplicant.

  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
}
