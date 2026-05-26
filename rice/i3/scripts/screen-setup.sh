#!/usr/bin/env bash

sleep 1

# reset complet avant config
xrandr \
  --output eDP-1 --off \
  --output DP-8 --off \
  --output DP-7 --off

if xrandr | grep -q "DP-8 connected"; then
    # DESKTOP MODE
    xrandr \
      --output DP-8 --primary --mode 1920x1080 --pos 0x0 --auto \
      --output DP-7 --mode 1920x1080 --right-of DP-8 --auto
else
    # LAPTOP MODE
    xrandr \
      --output eDP-1 --primary --auto
fi