{ pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.fwupd.enable = true;

  services.hardware.bolt.enable = true;

  # Framework 13 AMD : on utilise power-profiles-daemon (recommandé avec
  # amd-pstate-epp), PAS system76-power qui est auto-activé par COSMIC mais
  # conçu pour les laptops System76. Logs actuels :
  # "Failed to set automatic graphics power: does not have switchable graphics",
  # "fan daemon: platform hwmon not found" -> conflit avec fw-fanctrl.
  hardware.system76.power-daemon.enable = lib.mkForce false;
  services.power-profiles-daemon.enable = true;

  hardware.fw-fanctrl = {
    enable = true;

    config = {
      defaultStrategy = "aggressive";

      strategies.aggressive = {
        fanSpeedUpdateFrequency = 2;
        movingAverageInterval = 5;

        speedCurve = [
          {
            temp = 45;
            speed = 0;
          }
          {
            temp = 50;
            speed = 0;
          }
          {
            temp = 55;
            speed = 30;
          }
          {
            temp = 60;
            speed = 50;
          }
          {
            temp = 65;
            speed = 70;
          }
          {
            temp = 70;
            speed = 100;
          }
        ];
      };
    };
  };

  services.fprintd.enable = false;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleSuspendKey = "ignore";
    HandleSuspendKeyLongPress = "ignore";
    HandleHibernateKey = "ignore";
    HandleHibernateKeyLongPress = "ignore";
    # on ne bloque QUE le sleep, pas l'extinction volontaire.
    HandlePowerKey = "poweroff";
    IdleAction = "ignore";
    IdleActionSec = "0";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  # UPower ne doit jamais déclencher HybridSleep ni tenir compte du capot.
  services.upower.ignoreLid = true;
  services.upower.criticalPowerAction = "PowerOff";

  # Retiré : HandlePowerKey=ignore / HandlePowerKeyLongPress=ignore
  # empêchaient le bouton power de déclencher un poweroff propre et
  # forçaient à couper en dur. On restaure les défauts logind
  # (poweroff sur appui court).

  environment.systemPackages = with pkgs; [
    lm_sensors
    acpi
    fprintd
    libfprint
  ];
}
