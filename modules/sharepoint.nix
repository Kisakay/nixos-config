# Mounts my disk.v.bzh FTP space on /share (rclone + FUSE, explicit FTPS).
#
# Self-contained: add it to the imports of any machine.
# The password lives outside the repo and the Nix store (see `passwordFile`);
# set it with `sharepoint-passwd`.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "anais@disk.v.bzh";
  host = "disk.v.bzh";
  port = 21;
  # Relative to the FTP account root.
  remotePath = "/";

  mountPoint = "/share";

  cfg = config.sharepoint;
  group = config.users.users.${cfg.localUser}.group;

  mountScript = pkgs.writeShellScript "sharepoint-mount" ''
    set -eu
    # Passed through the environment so it never shows up in `ps`.
    RCLONE_FTP_PASS="$(${pkgs.rclone}/bin/rclone obscure - < "$CREDENTIALS_DIRECTORY/password")"
    export RCLONE_FTP_PASS

    # The server presents a shared hosting certificate, not one for disk.v.bzh.
    exec ${pkgs.rclone}/bin/rclone mount ":ftp:${remotePath}" ${mountPoint} \
      --config /dev/null \
      --ftp-host ${host} \
      --ftp-port ${toString port} \
      --ftp-user ${lib.escapeShellArg username} \
      --ftp-explicit-tls \
      --ftp-no-check-certificate \
      --ftp-concurrency 4 \
      --ftp-idle-timeout 20s \
      --vfs-cache-mode writes \
      --cache-dir "$CACHE_DIRECTORY" \
      --dir-cache-time 30s \
      --timeout 30s
  '';

  passwdScript = pkgs.writeShellScriptBin "sharepoint-passwd" ''
    set -eu
    [ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"

    file=${lib.escapeShellArg cfg.passwordFile}
    if [ -s "$file" ]; then
      printf 'A password is already stored (%s). Replace it? [y/N] ' "$file"
      read -r ans
      case "$ans" in y|Y) ;; *) echo "Unchanged."; exit 0 ;; esac
    fi

    printf 'FTP password for ${username}: '
    stty -echo; trap 'stty echo' EXIT
    IFS= read -r pass; stty echo; echo
    [ -n "$pass" ] || { echo "Empty password, aborting." >&2; exit 1; }

    umask 077
    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$pass" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "Saved to $file."

    systemctl reset-failed sharepoint.service 2>/dev/null || true
    systemctl restart sharepoint.service && echo "${mountPoint} mounted." \
      || echo "Mount failed: journalctl -u sharepoint -e" >&2
  '';
in
{
  options.sharepoint = {
    localUser = lib.mkOption {
      type = lib.types.str;
      default = "kisa";
      description = "Local user owning the /share mount.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos-local/sharepoint-password";
      description = "File (outside the repo) holding the FTP password.";
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.rclone
      passwdScript
    ];

    system.activationScripts.sharepoint-password = ''
      if [ ! -s ${lib.escapeShellArg cfg.passwordFile} ]; then
        echo "sharepoint: no password set, run 'sudo sharepoint-passwd' to mount ${mountPoint}." >&2
      fi
    '';

    systemd.tmpfiles.rules = [
      "d ${mountPoint} 0755 ${cfg.localUser} ${group} -"
    ];

    systemd.services.sharepoint = {
      description = "FTPS mount ${username} -> ${mountPoint}";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      # For the setuid fusermount3 wrapper.
      path = [ "/run/wrappers" ];

      unitConfig = {
        ConditionPathExists = cfg.passwordFile;
        # Avoid getting banned by the host's fail2ban on a wrong password.
        StartLimitIntervalSec = 600;
        StartLimitBurst = 3;
      };

      serviceConfig = {
        Type = "notify";
        User = cfg.localUser;
        Group = group;
        LoadCredential = "password:${cfg.passwordFile}";
        CacheDirectory = "sharepoint";
        ExecStart = mountScript;
        ExecStopPost = "-/run/wrappers/bin/fusermount3 -uz ${mountPoint}";
        Restart = "on-failure";
        RestartSec = "30s";
      };
    };
  };
}
