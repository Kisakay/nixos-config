# Programmes : Firefox, fastfetch et configuration des shells (Bash, Zsh).
{
  config,
  lib,
  pkgs,
  ...
}:

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
    ls = "ls --color=auto -F";
    ll = "ls --color=auto -lhF";
    la = "ls --color=auto -lAhF";
    l = "ls --color=auto -CF";
    grep = "grep --color=auto";
    ".." = "cd ..";
    "..." = "cd ../..";
  };

  interactiveShellInit = ''
    export PATH="$HOME/.bun/bin:$PATH"

    if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1; then
      onefetch 2>/dev/null || fastfetch
    else
      fastfetch 2>/dev/null || true
    fi
  '';

  zshInteractiveExtra = ''
    # --- Options lisibilité / confort ---
    setopt AUTO_CD HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS SHARE_HISTORY APPEND_HISTORY
    unsetopt BEEP NOMATCH

    # Complétion insensible à la casse, menu navigable, couleurs
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
    zstyle ':completion:*' menu select
    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' verbose true
    zstyle ':completion:*' group-name ""
    zstyle ':completion:*:descriptions' format '%F{blue}-- %d --%f'
    zstyle ':completion:*:warnings' format '%F{red}-- no match --%f'

    # Flèches haut/bas : recherche dans l'historique par préfixe
    bindkey '^[[A' history-beginning-search-backward
    bindkey '^[[B' history-beginning-search-forward

    # builtins ls colorés même sans starship
    export LS_COLORS="''${LS_COLORS:-di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34}"
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
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "pattern"
      ];
    };
    histSize = 10000;
    inherit shellAliases;
    interactiveShellInit = interactiveShellInit + zshInteractiveExtra;
    ohMyZsh = {
      enable = true;
      # Thème désactivé : c'est Starship qui dessine le prompt.
      theme = "";
      plugins = [
        "git"
        "sudo"
        "dirhistory"
        "history"
        "colored-man-pages"
        "command-not-found"
      ];
    };
  };

  # --- Beau prompt NixOS : Starship ---
  # Lisible : heure, user@host, chemin tronqué, git, nix-shell, durée, code retour.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      command_timeout = 1000;
      scan_timeout = 10;

      format = "$os$username$hostname$directory$git_branch$git_status$nix_shell$jobs$cmd_duration$time$line_break$character";

      os = {
        disabled = false;
        style = "bold blue";
        symbols.NixOS = " ";
      };

      username = {
        show_always = true;
        style_root = "bold red";
        style_user = "bold cyan";
        format = "[$user]($style)";
      };

      hostname = {
        ssh_only = false;
        trim_at = ".";
        style = "bold yellow";
        format = "[@$hostname]($style) ";
      };

      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        style = "bold blue";
        read_only_style = "red";
        read_only = " 󰌾";
        format = "in [$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "on [$symbol$branch]($style) ";
        truncation_length = 30;
      };

      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        conflicted = "═";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
        stashed = "\\$";
      };

      nix_shell = {
        symbol = " ";
        style = "bold blue";
        format = "via [$symbol$state]($style) ";
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        unknown_msg = "[shell](bold yellow)";
      };

      jobs = {
        symbol = "✦";
        style = "bold cyan";
        format = "[$symbol$number]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "took [$duration]($style) ";
      };

      time = {
        disabled = false;
        style = "dimmed white";
        format = "at [$time]($style) ";
        time_format = "%R";
      };

      character = {
        success_symbol = "[➜](bold green) ";
        error_symbol = "[✗](bold red) ";
        vicmd_symbol = "[❮](bold green) ";
      };

      status.disabled = true;

      # Langages : affichés seulement quand pertinent, style discret.
      nodejs.style = "bold green";
      python.style = "bold yellow";
      nix_shell.disabled = false;
    };
  };

  # Configuration fastfetch (logo + config installés dans /etc/xdg/fastfetch).
  environment.etc = {
    "xdg/fastfetch/config.jsonc".source = fastfetchConfig;
    "xdg/fastfetch/trans-nixos-logo.txt".source = fastfetchLogo;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
