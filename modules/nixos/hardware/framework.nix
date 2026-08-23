{ pkgs, ... }:

{
  services.fwupd.enable = true;

  services.hardware.bolt.enable = true;

  hardware.fw-fanctrl = {
    enable = true;

    config = {
      defaultStrategy = "aggressive";

      strategies.aggressive = {
        fanSpeedUpdateFrequency = 2;
        movingAverageInterval = 5;

        speedCurve = [
          {
            temp = 0;
            speed = 80;
          }
          {
            temp = 50;
            speed = 100;
          }
        ];
      };
    };
  };

  services.fprintd.enable = false;

  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandlePowerKeyLongPress = "ignore";
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    acpi
    fprintd
    libfprint
  ];
}
