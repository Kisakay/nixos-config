# Matériel : impression (imprimante Brother MFC-L2750DW).
{ config, pkgs, ... }:

{
  # Python
  environment.systemPackages = with pkgs; [
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pandas
        requests
        rpy2
      ]
    ))
  ];
  # NodeJS/Bun
  environment.systemPackages = with pkgs; [
    nodejs
    bun
  ];
  # Rust
  environment.systemPackages = with pkgs; [
    rust
    cargo
  ];
}
