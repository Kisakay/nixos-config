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
