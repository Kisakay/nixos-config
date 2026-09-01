{ config, lib, pkgs, ... }:

{
  users.users.kisa.extraGroups = [ "libvirtd" ];

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
