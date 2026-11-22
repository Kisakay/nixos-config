{
  description = "kisakay's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    qxchat-src = {
      url = "git+https://github.com/lqxp/app.git?ref=main&submodules=1";
      flake = false;
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TEMP pin (2026-11-22): efdfea5 locks @inrixia/helpers@3.22.0, rejected by pnpm minimumReleaseAge. Unpin in a few days.
    tidaLuna.url = "github:Inrixia/TidaLuna/e1a2358b7cfe27e50130c1ef6e566068b18ab4f5";

    nightcord = {
      url = "git+https://source.nightcord.st/nightcord/nightcord.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    veemeeter = {
      url = "github:Kisakay/VeeMeeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    github-redesktop = {
      url = "github:Kisakay/GithubReDesktop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cosmic-advanced-player = {
      url = "github:Kisakay/CosmicAdvancedPlayer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations.computer = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };

        modules = [
          { nix.settings.pure-eval = false; }
          ./hosts/computer
        ];
      };
    };
}
