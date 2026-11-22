{ pkgs, lib, ... }:

let
  # EasyEffects sert UNIQUEMENT à nettoyer le micro :
  #   Microphone (VeeMeeter) -> chaîne EE -> easyeffects_source
  #   -> loopback (desktop/audio.nix) -> "Micro Sortie EasyEffect" (vi3) -> "Micro Clean" (b1)
  # Par défaut EE (8.x) aspire TOUS les flux (processAll* = true dans
  # [EffectsPipelines]). On force ces clés à chaque démarrage : les presets et
  # réglages faits dans l'interface restent modifiables, mais le routage non.
  kw = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file easyeffects/db/easyeffectsrc";

  settings = {
    EffectsPipelines = {
      processAllOutputs = "false";
      processAllInputs = "false";
      # Sinon EE débranche la chaîne micro après 10 s s'il ne voit pas
      # d'"app" sur easyeffects_source (il ignore notre loopback).
      inputInactivityTimerEnable = "false";
    };
    StreamInputs = {
      useDefaultInputDevice = "false";
      inputDevice = "veemeeter.hi1.out";
      # Pas de "listen to mic" : il partage la sortie des effets de sortie.
      listenToMic = "false";
    };
    StreamOutputs = {
      useDefaultOutputDevice = "true";
    };
  };

  enforce = pkgs.writeShellScript "easyeffects-enforce-config" (
    lib.concatStringsSep "\n" (
      lib.flatten (
        lib.mapAttrsToList (
          group: keys:
          lib.mapAttrsToList (key: value: "${kw} --group ${group} --key ${key} ${lib.escapeShellArg value}") keys
        ) settings
      )
    )
  );
  waitMic = pkgs.writeShellScript "easyeffects-wait-veemeeter-mic" ''
    for _ in $(seq 40); do
      ${pkgs.pipewire}/bin/pw-cli ls Node | grep -q 'node.name = "veemeeter.hi1.out"' && exit 0
      sleep 0.5
    done
    exit 0
  '';

  # Si EE démarre sans monter sa chaîne micro (arrive pendant un switch),
  # on échoue -> Restart=on-failure le relance.
  checkChain = pkgs.writeShellScript "easyeffects-check-mic-chain" ''
    for _ in $(seq 20); do
      ${pkgs.pipewire}/bin/pw-link -l | grep -A1 '^veemeeter.hi1.out:capture_FL' | grep -q 'ee_sie_' && exit 0
      sleep 0.5
    done
    echo "chaîne micro EasyEffects absente, redémarrage" >&2
    exit 1
  '';

  # Launcher / commande `easyeffects` : démarre d'abord le service (config
  # forcée), puis ouvre sa fenêtre. EE est mono-instance : le second lancement
  # passe la main à l'instance du service, jamais une instance "sauvage".
  gui = pkgs.writeShellScript "easyeffects-gui" ''
    ${pkgs.systemd}/bin/systemctl --user start easyeffects.service
    exec ${pkgs.easyeffects}/bin/easyeffects "$@"
  '';

  easyeffects-safe = pkgs.symlinkJoin {
    name = "easyeffects-safe";
    paths = [ pkgs.easyeffects ];
    postBuild = ''
      rm $out/bin/easyeffects
      ln -s ${gui} $out/bin/easyeffects
      desktop=$out/share/applications/com.github.wwmm.easyeffects.desktop
      cp --remove-destination "$(readlink -f $desktop)" $desktop
      sed -i 's|^Exec=.*|Exec=${gui}|' $desktop
    '';
  };
in
{
  environment.systemPackages = [ easyeffects-safe ];

  systemd.user.services.easyeffects = {
    description = "EasyEffects (micro uniquement)";
    wantedBy = [ "graphical-session.target" ];
    # Redémarre avec VeeMeeter : son entrée (veemeeter.hi1.out) est créée par
    # VeeMeeter, et EE ne se rebranche pas tout seul si elle apparaît après lui.
    partOf = [
      "graphical-session.target"
      "veemeeter.service"
    ];
    wants = [ "veemeeter.service" ];
    after = [
      "graphical-session.target"
      "pipewire.service"
      "wireplumber.service"
      "veemeeter.service"
    ];
    serviceConfig = {
      ExecStartPre = [
        "${enforce}"
        # Attend (max 20 s) que le micro VeeMeeter existe avant de lancer EE.
        "${waitMic}"
      ];
      ExecStartPost = "${checkChain}";
      ExecStart = "${pkgs.easyeffects}/bin/easyeffects --service-mode --hide-window";
      ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
