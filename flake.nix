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
  };

  outputs =
    {
      nixpkgs,
      pelican,
      nixos-local,
      qxchat-src,
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

          ./configuration.nix
          "${nixos-local}/wireguard/wg0-secrets.nix"
        ];
      };
    };
}
