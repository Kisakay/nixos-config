#!/usr/bin/env bash
WALL="$HOME/Music/wallpaper-light.mp4"
FALLBACK="$HOME/.config/background"
MODE="${1:-video}"
DESKTOP_OUTPUT="DP-8"

pkill -x mpv 2>/dev/null
pkill -x xwinwrap 2>/dev/null
pkill -x picom 2>/dev/null
sleep 0.5

if [ -f "$FALLBACK" ]; then
  feh --bg-fill "$FALLBACK" 2>/dev/null || xsetroot -solid "#111111"
else
  xsetroot -solid "#111111"
fi

picom --config "$HOME/.config/picom/picom.conf" &
sleep 0.8

if [ "$MODE" = "image" ]; then
  exit 0
fi

if ! xrandr | grep -q "^$DESKTOP_OUTPUT connected"; then
  exit 0
fi

# if command -v xwinwrap >/dev/null 2>&1; then
#   xwinwrap -fs -ni -nf -b -ov -- mpv \
#     -wid WID \
#     --vo=gpu \
#     --hwdec=auto-safe \
#     --no-audio \
#     --loop-file=inf \
#     --no-osc \
#     --no-osd-bar \
#     --no-input-default-bindings \
#     --no-resume-playback \
#     --keepaspect=no \
#     --panscan=1.0 \
#     --really-quiet \
#     "$WALL" &
# fi