#!/usr/bin/env bash
# Supprime toutes les entrées d'autostart utilisateur (ex: remmina-applet.desktop).
set -eu

dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
[ -d "$dir" ] || exit 0

find "$dir" -mindepth 1 -maxdepth 1 -print -exec rm -rf -- {} +
