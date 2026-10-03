{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-mfcl2750dw ];
  };

  environment.systemPackages = [ pkgs.system-config-printer ];
}
