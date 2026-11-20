{ inputs, ... }:

{
  # Cosmic Advanced Player : lecteur de musique natif (Rust + libcosmic).
  # Le flake sert le binaire précompilé de la release, rien n'est compilé.
  # https://cosmic-advanced-player.v.bzh
  imports = [ inputs.cosmic-advanced-player.nixosModules.default ];

  programs.cosmic-advanced-player.enable = true;
}
