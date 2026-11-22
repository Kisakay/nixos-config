{ pkgs, ... }:

# Journal de crash sur un disque séparé (SanDisk SATA, label "crashlog").
# But : garder une trace des freezes même si le NVMe système décroche.
# - FS monté en "sync" : chaque ligne part immédiatement sur le disque.
# - Boucles en builtins bash uniquement (aucun exec dans la boucle) :
#   elles continuent même si /nix/store (sur le NVMe) ne répond plus.
let
  dir = "/var/crashlog";

  kmsgLogger = pkgs.writeShellScript "crashlog-kmsg" ''
    log=${dir}/kmsg-$(date +%Y%m%d-%H%M%S).log
    while true; do
      while IFS= read -r line; do
        printf '%(%F %T)T %s\n' -1 "$line" >> "$log"
      done < /dev/kmsg
    done
  '';

  statsLogger = pkgs.writeShellScript "crashlog-stats" ''
    log=${dir}/stats-$(date +%Y%m%d-%H%M%S).log
    # FIFO jamais alimentée : "read -t 2" sert de sleep sans exec.
    fifo=/run/crashlog-stats.fifo
    rm -f "$fifo"; mkfifo "$fifo"; exec 3<> "$fifo"

    rd() { local v; IFS= read -r v < "$1" 2>/dev/null && printf '%s' "$v"; }
    nvmeTemp=/dev/null; cpuTemp=/dev/null
    for h in /sys/class/hwmon/hwmon*; do
      case "$(rd "$h/name")" in
        nvme) nvmeTemp=$h/temp1_input ;;
        k10temp) cpuTemp=$h/temp1_input ;;
      esac
    done

    while true; do
      printf '%(%F %T)T load=[%s] io=[%s] mem=[%s] cpu=[%s] nvme_state=%s nvme_temp=%s cpu_temp=%s\n' -1 \
        "$(rd /proc/loadavg)" "$(rd /proc/pressure/io)" "$(rd /proc/pressure/memory)" \
        "$(rd /proc/pressure/cpu)" "$(rd /sys/class/nvme/nvme0/state)" \
        "$(rd "$nvmeTemp")" "$(rd "$cpuTemp")" >> "$log"
      read -t 2 -u 3 _ || true
    done
  '';

  service = description: script: {
    inherit description;
    wantedBy = [ "multi-user.target" ];
    after = [ "var-crashlog.mount" ];
    requires = [ "var-crashlog.mount" ];
    serviceConfig = {
      ExecStart = script;
      Restart = "always";
      RestartSec = 2;
      # Reste prioritaire quand la machine rame.
      Nice = -10;
      IOSchedulingClass = "realtime";
      OOMScoreAdjust = -1000;
    };
  };
in
{
  fileSystems.${dir} = {
    device = "/dev/disk/by-label/crashlog";
    fsType = "ext4";
    options = [ "nofail" "sync" "noatime" "x-systemd.device-timeout=5s" ];
  };

  systemd.services.crashlog-kmsg =
    service "Copie des messages noyau sur le disque crashlog" kmsgLogger;
  systemd.services.crashlog-stats =
    service "Stats système toutes les 2 s sur le disque crashlog" statsLogger;
}
