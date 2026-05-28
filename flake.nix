{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pelican.url = "github:Hythera/nix-pelican";

    nixos-local = {
      url = "path:/etc/nixos-local";
      flake = false;
    };

    qxchat-src = {
      url = "git+https://github.com/lqxp/app.git?ref=main&submodules=1";
      flake = false;
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixos-local,
      qxchat-src,
      zen-browser,
      pelican,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations."computer" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Pelican: packages overlay only, no upstream modules
          { nixpkgs.overlays = [ pelican.overlays.default ]; }

          # Pelican: both modules from your local copies
          {
            imports = [
              ./pelican/panel/module.nix
              ./pelican/wings/module.nix
            ];
          }

          # QxChat
          {
            imports = [ "${qxchat-src}/nix/module.nix" ];
            nixpkgs.overlays = [
              (final: prev: {
                qxchat = prev.callPackage "${qxchat-src}/nix/qxchat.nix" { };
              })
            ];
            programs.qxchat.enable = true;
          }

          # Zen Browser
          {
            environment.systemPackages = [
              zen-browser.packages.${system}.default
            ];
          }

          ./configuration.nix
        ];
      };
    };
}
