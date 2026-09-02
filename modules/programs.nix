# Programmes : Firefox, fastfetch et configuration des shells (Bash, Zsh).
{ config, lib, pkgs, ... }:

let
  fastfetchLogo = pkgs.writeText "trans-nixos-logo.txt" (
    builtins.readFile ./assets/fastfetch-logo.txt
  );

  fastfetchConfig = pkgs.writeText "fastfetch-config.jsonc" (
    lib.replaceStrings [ "~/.config/fastfetch/trans-nixos-logo.txt" ] [ "${fastfetchLogo}" ] (
      builtins.readFile ./assets/fastfetch-config.jsonc
    )
  );

  shellAliases = {
    maj = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --impure --flake .#fw12";
    fdp = "zeditor /etc/nixos/";
  };

  interactiveShellInit = ''
    export PATH="$HOME/.bun/bin:$PATH"

    if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1; then
      onefetch
    else
      fastfetch
    fi
  '';
in
{
  programs.firefox.enable = true;

  programs.bash = {
    enable = true;
    inherit shellAliases interactiveShellInit;
  };

  programs.zsh = {
    enable = true;
    inherit shellAliases interactiveShellInit;
    ohMyZsh = {
      enable = true;
      theme = "apple";
    };
  };

  # Configuration fastfetch (logo + config installés dans /etc/xdg/fastfetch).
  environment.etc = {
    "xdg/fastfetch/config.jsonc".source = fastfetchConfig;
    "xdg/fastfetch/trans-nixos-logo.txt".source = fastfetchLogo;
  };
}
