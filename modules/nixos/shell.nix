{
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
in
{
  programs.bash.interactiveShellInit = ''
    alias fdp="codium /etc/nixos/ --user-data-dir /home/kisakay --no-sandbox"
    alias m2f="cd /etc/nixos/ && sudo nixos-rebuild switch --flake /etc/nixos#computer"
    alias maj="cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --flake .#computer"
    alias flake_update="sudo nix flake lock --update-input qxchat-src /etc/nixos"

    alias whatsmyip="curl ifconfig.me; echo"
    alias monitoring="ping 1.1.1.1 -D | tee ping.log"

    alias tgl="gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled'"
    alias revien="gsettings set org.gnome.desktop.peripherals.touchpad send-events 'enabled'"
    alias bat="acpi"

    alias c='oco .'
    alias ncc="ssh -L 3000:127.0.0.1:3000 nc"

    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    export PATH="$PATH:/home/kisakay/.spicetify"
    export PATH="$HOME/.local/bin:$PATH"

    export ANT_INSTALL="$HOME/.ant"
    export PATH="$ANT_INSTALL/bin:$PATH"

    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
      onefetch
    else
      fastfetch
    fi
  '';

  environment.etc = {
    "xdg/fastfetch/config.jsonc".source = fastfetchConfig;
    "xdg/fastfetch/trans-nixos-logo.txt".source = fastfetchLogo;
  };
}
