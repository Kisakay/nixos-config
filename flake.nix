{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    qxchat-src = {
      url = "git+https://github.com/lqxp/app.git?ref=main&submodules=1";
      flake = false;
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    { nixpkgs, nix-flatpak, ... }@inputs:
    let
      system = "x86_64-linux";
      secrets = import /etc/nixos/secrets.nix;
    in
    {
      nixosConfigurations."framework-laptop-12" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs secrets; };
        modules = [
          ./hosts/framework-laptop-12
          nix-flatpak.nixosModules.nix-flatpak
        ];
      };
    };
}
