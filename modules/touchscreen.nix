# Écran tactile : commande pour couper/réactiver le tactile au doigt, sans toucher au stylet.
{ pkgs, ... }:

let
  touchToggle = pkgs.writeShellScriptBin "touch-toggle" ''
    # Nom exact du nœud tactile (le stylet s'appelle "... Stylus", il n'est donc pas concerné).
    TOUCH_NAME="ILIT2901:00 222A:5539"

    for dev in /sys/class/input/input*; do
      if [[ "$(cat "$dev/name")" == "$TOUCH_NAME" ]]; then
        current=$(cat "$dev/inhibited")
        new=$((1 - current))
        # 1 = tactile ignoré, 0 = tactile actif
        echo "$new" > "$dev/inhibited"
        echo "touchscreen inhibited=$new"
      fi
    done
  '';
in
{
  environment.systemPackages = [ touchToggle ];

  # Permet de lancer la bascule depuis un raccourci sans demander de mot de passe.
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/touch-toggle";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
