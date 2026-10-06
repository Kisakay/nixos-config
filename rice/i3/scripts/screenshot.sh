#!/usr/bin/env bash
# i3/X11 only. Uniforme maim(1) : pas de mélange flameshot/maim.
# Zone = maim -s (sélection native X11, fiable sous i3+picom multi-écrans).
# Sauve dans ~/Pictures/Screenshots + copie presse-papiers + notifie (dunst).
set -u

DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"

notify() {
    command -v notify-send >/dev/null && notify-send -a screenshot "$1" "$2"
}

choice=$(printf "Zone\nActive window\nScreen" | rofi -dmenu -p "Screenshot")
[ -z "${choice:-}" ] && exit 0

# Laisser rofi relâcher le clavier/souris avant que maim grabbe l'input.
# 0.2s était trop court : la sélection Zone ne recevait jamais le drag.
pkill -x rofi 2>/dev/null
sleep 0.5

case "$choice" in
    Zone)
        # Esc / clic-droit = annulation (maim renvoie != 0) : sortir silencieusement.
        maim -s -u "$FILE" || exit 1
        ;;
    "Active window")
        WIN_ID=$(xdotool getactivewindow)
        maim -i "$WIN_ID" -u "$FILE" || exit 1
        ;;
    Screen)
        maim -u "$FILE" || exit 1
        ;;
    *)
        exit 1
        ;;
esac

xclip -selection clipboard -t image/png -i "$FILE"
notify "Screenshot" "Sauvé dans $FILE (copié dans le presse-papiers)"