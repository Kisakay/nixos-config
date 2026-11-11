{ pkgs, ... }:

let
  clearAutostart = pkgs.writeShellApplication {
    name = "clear-autostart";
    runtimeInputs = [ pkgs.findutils pkgs.coreutils ];
    text = builtins.readFile ./scripts/clear-autostart.sh;
  };
in
{
  # Vide ~/.config/autostart à chaque ouverture de session...
  systemd.user.services.clear-autostart = {
    description = "Remove user autostart entries";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${clearAutostart}/bin/clear-autostart";
    };
  };

  # ...et dès qu'une app (Remmina, etc.) y recrée un fichier.
  systemd.user.paths.clear-autostart = {
    description = "Watch user autostart directory";
    wantedBy = [ "default.target" ];
    pathConfig = {
      PathChanged = "%h/.config/autostart";
      MakeDirectory = true;
      Unit = "clear-autostart.service";
    };
  };
}
