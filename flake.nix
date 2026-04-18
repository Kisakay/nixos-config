# flake.nix
{
  inputs = {
    pelican.url = "github:Hythera/nix-pelican";
    ...
  };
  outputs = {
    nixpkgs,
    home-manager,
    pelican,
  }: let
    system = "...";
    pkgs = nixpkgs.legacyPackages.${system};
    in {
      nixosConfigurations."..." = nixpkgs.lib.nixosSystem {
        system = "...";
        modules = [
          pelican.nixosModules.default # enable the NixOS moduel
          { nixpkgs.overlays = [ pelican.overlays.default ]; }
          ...
        ];
      };
    }
}