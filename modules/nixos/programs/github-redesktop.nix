{ inputs, ... }:

{
  # GitHub ReDesktop : réécriture native (Rust + libcosmic) de GitHub Desktop.
  # Le flake sert le binaire précompilé de la release, rien n'est compilé.
  imports = [ inputs.github-redesktop.nixosModules.default ];

  programs.github-redesktop.enable = true;
}
