{ pkgs, ... }:

let
  windows-test = pkgs.writeShellScriptBin "windows-test" ''
    set -euo pipefail

    NAME="windows-test"
    IMAGE="dockurr/windows"
    DATA="/var/lib/windows-test"

    start() {
      if docker container inspect "$NAME" >/dev/null 2>&1; then
        echo "Starting existing Windows VM..."
        docker start "$NAME"
        return
      fi

      echo "Creating disposable Windows 11 VM..."

      mkdir -p "$DATA"

      docker run -d \
        --name "$NAME" \
        --restart=no \
        -e VERSION=11 \
        -p 8006:8006 \
        -p 3389:3389 \
        --device=/dev/kvm \
        --device=/dev/net/tun \
        --cap-add=NET_ADMIN \
        --stop-timeout=120 \
        -v "$DATA:/storage" \
        "$IMAGE"

      echo
      echo "Windows is starting."
      echo "Web desktop: http://127.0.0.1:8006"
      echo "RDP:         127.0.0.1:3389"
    }

    stop() {
      docker stop "$NAME" 2>/dev/null || true
    }

    reset() {
      echo "Destroying Windows VM..."

      docker rm -f "$NAME" 2>/dev/null || true
      rm -rf "$DATA"

      echo "Windows VM deleted."
      echo "Run 'windows-test start' to create a completely fresh VM."
    }

    logs() {
      docker logs -f "$NAME"
    }

    case "''${1:-}" in
      start)
        start
        ;;
      stop)
        stop
        ;;
      reset)
        reset
        ;;
      restart)
        stop
        start
        ;;
      logs)
        logs
        ;;
      *)
        echo "Usage:"
        echo "  windows-test start"
        echo "  windows-test stop"
        echo "  windows-test reset"
        echo "  windows-test restart"
        echo "  windows-test logs"
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = [
    windows-test
  ];
}
