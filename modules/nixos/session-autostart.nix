{ lib, ... }:

let
  # Apps lancées à l'ouverture de la session graphique. On passe par des
  # services systemd utilisateur (et pas ~/.config/autostart, vidé par
  # clear-autostart.nix), liés à graphical-session.target (COSMIC l'active).
  # Les binaires viennent du profil système pour garder les wrappers NixOS
  # (setcap de gpu-screen-recorder, etc.).
  bin = name: "/run/current-system/sw/bin/${name}";

  apps = {
    # Fenêtre du mixeur ; le démon, lui, démarre déjà avec PipeWire.
    veemeeter = "${bin "veemeeter"}";
    # Overlay en arrière-plan, ouvert avec Alt+Z.
    gsr-ui = "${bin "gsr-ui"} launch-daemon";
    signal = "${bin "signal-desktop"} --start-in-tray";
    telegram = "${bin "Telegram"} -startintray";
  };

  mkService = name: cmd: {
    description = "Session autostart: ${name}";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = cmd;
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
in
{
  systemd.user.services = lib.mapAttrs' (
    name: cmd: lib.nameValuePair "autostart-${name}" (mkService name cmd)
  ) apps;
}
