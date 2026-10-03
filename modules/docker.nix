{ pkgs, ... }:
{
  virtualisation.docker = {
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    docker
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/windows-test 0700 root root -"
  ];

  users.users.kisa.extraGroups = [ "docker" ];
}
