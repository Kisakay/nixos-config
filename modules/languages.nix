{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      pandas
      requests
      rpy2
    ]))
    nodejs
    bun
    rustc
    cargo
  ];
}
