{
  inputs = {
    pelican.url = "github:Hythera/nix-pelican";

    nixos-local = {
      url = "path:/etc/nixos-local";
      flake = false;
    };
  };

  outputs = { nixpkgs, pelican, nixos-local, ... }: let
    system = "x86_64-linux";
  in {
    nixosConfigurations."computer" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        pelican.nixosModules.default
        { nixpkgs.overlays = [ pelican.overlays.default ]; }
        ./configuration.nix
        "${nixos-local}/wireguard/wg0-secrets.nix"
      ];
    };
  };
}