{
  config,
  pkgs,
  lib,
  ...
}:

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
    # Mot de passe en clair : "tidal" (hash sha-512 via `openssl passwd -6`).
    # Requis car certains clients (driver SSHFS Windows) refusent le mdp vide.
    # Faible par design, LAN uniquement : ne JAMAIS exposer le 22 sur internet.
    hashedPassword = "$6$8atse4TuhiYsSjJ/$LapfIRnoYCRkwzze2VSJ5DwT3ZypdXpsqcrDdu0PzshuymuYJ.1K6/oOSwLDD6NVtSdF5WSkeHVU8tMri7mya/";
  };

  # Pas de gestion fine : 0777 pour tout le monde, c'est juste un subfolder.
  # NOTE: le chroot lui-même (/srv/sftp, /srv/sftp/tidal) doit rester
  # root:root 0755 NON-writable, sinon sshd coupe la connexion
  # ("bad ownership or modes for chroot directory").
  # Seul /songs (le vrai stockage) est 0777.
  system.activationScripts.sftp-music-perms = lib.stringAfter [ "users" "groups" ] ''
    mkdir -p /home/kisakay/Music/TidalDownloadedSongs /srv/sftp/tidal/songs
    chown root:root /srv/sftp /srv/sftp/tidal
    chmod 0755 /srv/sftp /srv/sftp/tidal
    chmod 0777 /home/kisakay/Music/TidalDownloadedSongs
  '';

  # Chroot : doit être owned root:root 0755 (NON writable), sinon sshd refuse
  # la session (reset peer après auth OK). Seul le sous-dossier songs est writable.
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

  # Sans ça, l'auth password de tidal échoue toujours :
  # - unixAuth=false par défaut car PasswordAuthentication=false global
  #   (le module sshd ne met pam_unix que si password global activé,
  #   et notre Match User ne suffit pas côté PAM) -> on force.
  # - allowNullPassword (nullok) requis pour le mot de passe vide.
  security.pam.services.sshd = {
    unixAuth = lib.mkForce true;
    allowNullPassword = true;
  };

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
        ForceCommand internal-sftp -d /songs -u 000
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
