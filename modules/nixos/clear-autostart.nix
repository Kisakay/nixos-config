{ ... }:

let
  System = import ../../hosts/computer/username.nix
{
  system.activationScripts.disableAutostart = {
    text = ''
      rm -f /home/${System.Username}/.config/autostart/*
    '';
    deps = [];
  };
}
