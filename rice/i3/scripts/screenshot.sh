#!/usr/bin/env bash

choice=$(printf "Zone\nActive window\nScreen" | rofi -dmenu -p "Screenshot")

case "$choice" in
    Zone)
        pkill -x rofi 2>/dev/null
        sleep 0.2
        flameshot gui -c
        ;;
    "Active window")
        pkill -x rofi 2>/dev/null
        sleep 0.2
        WIN_ID=$(xdotool getactivewindow)
        maim -i "$WIN_ID" | xclip -selection clipboard -t image/png
        ;;
    Screen)
        flameshot full -c
        ;;
esac