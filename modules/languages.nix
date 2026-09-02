{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # python
    (python3.withPackages (
      python-pkgs: with python-pkgs; [
        pandas
        requests
        rpy2
      ]
    ))

    # bun / nodejs
    nodejs
    bun
    prettier
    # Rust
    rust-analyzer
    rustc
    cargo
  ];
}
