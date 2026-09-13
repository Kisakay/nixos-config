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

  System = import ../../hosts/computer/username.nix;
in
{
  programs.bash = {
    shellAliases = {
      fdp = "zeditor /etc/nixos/";
      maj = "cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch --impure --flake .#computer";
      flake_update = "sudo nix flake lock --update-input qxchat-src /etc/nixos";

      vpn = "sudo systemctl start wg-quick-wg1000";
      vpn-stop = "sudo systemctl stop wg-quick-wg1000";
      vpn-status = "sudo wg show";

      whatsmyip = "curl ifconfig.me; echo";
      monitoring = "ping 1.1.1.1 -D | tee ping.log";

      tgl = "gsettings set org.gnome.desktop.peripherals.touchpad send-events 'disabled'";
      revien = "gsettings set org.gnome.desktop.peripherals.touchpad send-events 'enabled'";
      bat = "acpi";

      c = "oco .";
      ncc = "ssh -L 3000:127.0.0.1:3000 nc";
    };

    interactiveShellInit = ''
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
      export PATH="$PATH:/home/${System.Username}/.spicetify"
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
  };

  environment.etc = {
    "xdg/fastfetch/config.jsonc".source = fastfetchConfig;
    "xdg/fastfetch/trans-nixos-logo.txt".source = fastfetchLogo;
  };
}
