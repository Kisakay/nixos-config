{ config, pkgs, ... }:

{

  # programs.steam = {
  #   enable = true;
  # };

  # programs.gamemode.enable = true;

  # programs.gamescope = {
  #   enable = true;
  #   enableWsi = true;
  #   capSysNice = false;
  # };

  environment.systemPackages = with pkgs; [
    steam-run
  ];

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
