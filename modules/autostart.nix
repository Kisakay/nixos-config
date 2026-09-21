{ ... }:

{
  system.activationScripts.disableAutostart = {
    text = ''
      rm -f /home/kisa/.config/autostart/*
    '';
    deps = [ ];
  };
}
