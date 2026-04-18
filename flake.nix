{
  inputs = {
    pelican.url = "github:Hythera/nix-pelican";
    nixos-local.url = "path:/etc/nixos-local";
  };

  outputs = { nixpkgs, home-manager, pelican, nixos-local, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations."computer" = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        pelican.nixosModules.default
        { nixpkgs.overlays = [ pelican.overlays.default ]; }
        ./configuration.nix
        (nixos-local + /wireguard/wg0-secrets.nix)
      ];
    };
  };
}