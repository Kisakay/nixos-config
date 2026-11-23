# Mode tablette : garder clavier + touchpad actifs quand l'écran est plié.
# Sur le Framework 12, c'est l'EC (firmware) qui coupe le clavier en mode tablette,
# indépendamment de l'OS. On force donc l'EC en mode "laptop" via framework_tool.
# (L'EC ne permet pas de relire l'override : l'état est mémorisé dans /run, remis à
#  zéro au redémarrage, comme l'override lui-même côté EC.)
{ pkgs, ... }:

let
  fwTool = "${pkgs.framework-tool}/bin/framework_tool";

  tabletKbd = pkgs.writeShellScriptBin "tablet-kbd" ''
    # Usage : tablet-kbd [on|off|status]   (sans argument = bascule)
    STATE=/run/tablet-kbd
    cur=$(cat "$STATE" 2>/dev/null || echo 0)

    case "''${1:-toggle}" in
      on)     new=1 ;;
      off)    new=0 ;;
      status)
        if [[ "$cur" == 1 ]]; then echo "ON : clavier actif même plié"
        else echo "OFF : comportement normal"; fi
        exit 0 ;;
      *)      new=$((1 - cur)) ;;
    esac

    if [[ $EUID -ne 0 ]]; then
      echo "Erreur : lance cette commande avec sudo."; exit 1
    fi

    if [[ "$new" == 1 ]]; then
      ${fwTool} --tablet-mode laptop >/dev/null || exit 1
      echo "ON : clavier actif même plié"
    else
      ${fwTool} --tablet-mode auto >/dev/null || exit 1
      echo "OFF : mode tablette normal rétabli"
    fi
    echo "$new" > "$STATE"
  '';
in
{
  environment.systemPackages = [ tabletKbd pkgs.framework-tool ];

  # Bascule sans mot de passe (alias / raccourci clavier COSMIC).
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/tablet-kbd";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
