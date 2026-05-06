{
  inputs = {
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
      pelican,
      nixos-local,
      qxchat-src,
      zen-browser,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations."computer" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            disabledModules = [ "${pelican}/pelican/panel/module.nix" ];
            imports = [ ./pelican/panel/module.nix ];
          }

          pelican.nixosModules.default
          { nixpkgs.overlays = [ pelican.overlays.default ]; }

          # QxChat (module + package overlay)
          {
            imports = [ "${qxchat-src}/nix/module.nix" ];
            nixpkgs.overlays = [
              (final: prev: {
                qxchat = prev.callPackage "${qxchat-src}/nix/qxchat.nix" { };
              })
            ];
            programs.qxchat.enable = true;
          }

          # Zen Browser setup
          {
            environment.systemPackages = [
              zen-browser.packages.${system}.default
            ];
          }

          ./configuration.nix
          "${nixos-local}/wireguard/wg0-secrets.nix"
        ];
      };
    };
}
