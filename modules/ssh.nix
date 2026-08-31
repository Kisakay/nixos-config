# SSH : serveur (connexions entrantes) et configuration du client.
{ config, pkgs, ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PubkeyAuthentication = true;
    };
  };

  programs.ssh.extraConfig = ''
    Host fw13
      HostName 192.168.2.1
      User kisakay
      Port 22
      IdentityFile ~/.ssh/id_ed25519
  '';
}
