{ config, lib, pkgs, ... }:

{
  users.users.kisa.extraGroups = [ "libvirtd" ];

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}