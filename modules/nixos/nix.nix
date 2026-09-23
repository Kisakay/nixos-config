{pkgs}:

{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };

  environment.systemPackages = with pkgs; [
    nixd
  ];

  nixpkgs.config.allowUnfree = true;
}
