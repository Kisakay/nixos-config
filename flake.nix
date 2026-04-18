{
  inputs = {
    pelican.url = "github:Hythera/nix-pelican";
  };

  outputs = { nixpkgs, home-manager, pelican, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations."computer" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        pelican.nixosModules.default
        { nixpkgs.overlays = [ pelican.overlays.default ]; }
        ./configuration.nix
      ];
    };
  };
}