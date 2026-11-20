{pkgs, ...}:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Les gros builds Rust (LTO fat) prennent ~9 Go par rustc : sur 16 cœurs
      # sans limite, un build de cosmic-comp a saturé les 31 Go et l'OOM killer
      # a tué Discord. 2 jobs × 6 cœurs laisse de la marge à la session.
      max-jobs = 2;
      cores = 6;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    optimise.automatic = true;
  };

  # Si la RAM sature malgré tout, l'OOM killer doit sacrifier un build Nix
  # plutôt que les applis de la session (les builders héritent de ce score).
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = 1000;

  # Pas de swap disque (swapDevices = [ ]) : swap compressé en RAM pour
  # absorber les pics au lieu de déclencher l'OOM killer directement.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  environment.systemPackages = with pkgs; [
    nixd
  ];

  nixpkgs.config.allowUnfree = true;
}
