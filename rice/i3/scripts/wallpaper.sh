#!/usr/bin/env bash
# Fond d'écran + picom pour i3. Déclaratif : $HOME prioritaire (override),
# /etc en repli (version NixOS). Ne touche pas COSMIC.
MODE="${1:-video}"

FALLBACK="$HOME/.config/background"
[ -f "$FALLBACK" ] || FALLBACK="/etc/i3/background"

PICOM_CONF="$HOME/.config/picom/picom.conf"
[ -f "$PICOM_CONF" ] || PICOM_CONF="/etc/xdg/picom/picom.conf"

pkill -x picom 2>/dev/null
sleep 0.5

if [ -f "$FALLBACK" ]; then
  if command -v feh >/dev/null 2>&1; then
    feh --bg-fill "$FALLBACK" 2>/dev/null || xsetroot -solid "#111111"
  else
    xsetroot -solid "#111111"
  fi
else
  xsetroot -solid "#111111"
fi

if [ -f "$PICOM_CONF" ] && command -v picom >/dev/null 2>&1; then
  picom --config "$PICOM_CONF" &
fi

if [ "$MODE" = "image" ]; then
  exit 0
fi
