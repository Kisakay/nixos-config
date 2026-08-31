# Matériel : impression (imprimante Brother MFC-L2750DW).
{ config, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-mfcl2750dw ];
  };
}
