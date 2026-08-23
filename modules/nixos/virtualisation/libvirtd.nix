{ pkgs, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "start";
      onShutdown = "shutdown";

      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };

    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    dnsmasq
    virtiofsd
  ];
}
