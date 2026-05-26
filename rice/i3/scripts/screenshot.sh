#!/usr/bin/env bash

choice=$(printf "Zone\nFenêtre active\nÉcran" | rofi -dmenu -p "Screenshot")

case "$choice" in
  Zone)
    pkill -x rofi 2>/dev/null
    sleep 0.2
    flameshot gui -c
    ;;
  Fenêtre\ active)
    maim -i "$(xdotool getactivewindow)" | xclip -selection clipboard -t image/png
    ;;
  Écran)
    flameshot full -c
    ;;
esac