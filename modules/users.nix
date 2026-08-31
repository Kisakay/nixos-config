# Utilisateurs.
{ config, pkgs, ... }:

{
  users.users."kisa" = {
    isNormalUser = true;
    description = "kisa";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdlZG9IMuAZ5bFDGBsO7dMDLOqDG/vWJ0NPC8WMzbpo anaissaraiva@hotmail.com"
    ];
  };
}
