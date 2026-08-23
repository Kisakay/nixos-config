{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "v4l2loopback"
      "snd-aloop"
    ];
    kernelParams = [ "usbcore.autosuspend=-1" ];

    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 card_label="OBS Cam" exclusive_caps=1
    '';

    kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
}
