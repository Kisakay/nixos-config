{ config, pkgs, lib, ... }:

{
  # SFTP anonyme (user `tidal`, mot de passe vide) sur 0.0.0.0:22
  # Expose /home/kisakay/Music/TidalDownloadedSongs en rwx via chroot + bind mount.
  #
  # Connexion cliente :  sftp tidal@<IP_LAN>   (mot de passe : vide, juste Entrée)
  # Dossier distant  :  /songs  (= /home/kisakay/Music/TidalDownloadedSongs sur l'hôte)
  #
  # SÉCURITÉ : ouvert à tout le monde en écriture. Ne pas exposer sur internet
  # sans durcissement (fail2ban, restriction IP, quota). Prévu pour LAN.

  users.groups.tidal = { };

  users.users.tidal = {
    isSystemUser = true;
    description = "SFTP anonyme musique";
    group = "tidal";
    home = "/srv/sftp/tidal";
    createHome = false;
    shell = "${pkgs.shadow}/bin/nologin";
    # "" = login sans mot de passe (combiné à PermitEmptyPasswords yes ci-dessous).
    # Pour mettre un mot de passe ensuite : `sudo passwd tidal` (avec mutableUsers).
    hashedPassword = "";
  };

  # kisakay garde rwx sur les fichiers créés via SFTP (groupe commun + umask 002).
  users.users.kisakay.extraGroups = [ "tidal" ];

  # Chroot : doit être owned root:root 0755, sinon sshd refuse.
  systemd.tmpfiles.rules = [
    "d /srv/sftp 0755 root root -"
    "d /srv/sftp/tidal 0755 root root -"
    "d /srv/sftp/tidal/songs 0755 root root -"
  ];

  # Le vrai stockage reste /home/kisakay/Music/TidalDownloadedSongs,
  # visible en SFTP sous /songs.
  fileSystems."/srv/sftp/tidal/songs" = {
    device = "/home/kisakay/Music/TidalDownloadedSongs";
    fsType = "none";
    options = [ "bind" ];
  };

  # Droits rwx pour kisakay + tidal sur le dossier réel (ACL + setgid).
  system.activationScripts.sftp-music-perms = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /home/kisakay/Music/TidalDownloadedSongs /srv/sftp/tidal/songs
    chgrp tidal /home/kisakay/Music/TidalDownloadedSongs || true
    chmod 2775 /home/kisakay/Music/TidalDownloadedSongs
    ${pkgs.acl}/bin/setfacl -m u:tidal:rwx,g:tidal:rwx /home/kisakay/Music/TidalDownloadedSongs || true
    ${pkgs.acl}/bin/setfacl -d -m u::rwx,g::rwx,g:tidal:rwx,o::r-x,u:tidal:rwx /home/kisakay/Music/TidalDownloadedSongs || true
    ${pkgs.acl}/bin/setfacl -R -m u:tidal:rwX,g:tidal:rwX /home/kisakay/Music/TidalDownloadedSongs || true
  '';

  networking.firewall.allowedTCPPorts = [ 22 ];

  services.openssh = {
    enable = true;
    # Pas de listenAddresses : par défaut sshd écoute déjà sur any
    # (0.0.0.0:22 + [::]:22, vérifié via `ss -tlnp`).
    # Ne pas mettre addr "::" + port 22 : NixOS génère `ListenAddress :::22`
    # ce qui fait échouer `sshd -t` avec "bad addr or host: :::22".
    # Le global reste key-only (défini dans networking.nix).
    # On ouvre le password vide UNIQUEMENT pour l'user tidal via Match.
    extraConfig = ''
      Match User tidal
        ChrootDirectory /srv/sftp/tidal
        ForceCommand internal-sftp -d /songs -u 002
        AllowTCPForwarding no
        AllowAgentForwarding no
        X11Forwarding no
        PermitTunnel no
        PermitTTY no
        PasswordAuthentication yes
        PermitEmptyPasswords yes
        KbdInteractiveAuthentication no
    '';
  };
}
