{ pkgs, ... }:

{
  systemd.services.pm2 = {
    description = "PM2 process manager";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "forking";
      User = "kisakay";
      Environment = [
        "HOME=/home/kisakay"
        "PM2_HOME=/home/kisakay/.pm2"
      ];

      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.pm2}/bin/pm2 resurrect && sleep 1'";
      ExecStop = "${pkgs.pm2}/bin/pm2 kill";

      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "10s";
      WorkingDirectory = "/home/kisakay";
    };
  };
}
