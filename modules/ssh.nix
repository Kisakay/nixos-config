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
      HostName 10.66.66.2
      User kisakay
      Port 22
      IdentityFile ~/.ssh/id_ed25519
    Host btsProd
      HostName lab.sio-brest.fr
      User root
      Port 12272
      IdentityFile ~/.ssh/id_ed25519
    Host btsTest
      HostName lab.sio-estran.fr
      User root
      Port 12272
      IdentityFile ~/.ssh/id_ed25519
    Host h
      HostName 192.168.1.192
      User kisakay
      Port 22
      IdentityFile ~/.ssh/id_ed25519
  '';
}
