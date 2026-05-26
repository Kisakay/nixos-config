#!/usr/bin/env bash

OUT="/tmp/i3-now-playing"

update() {
  text=$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)
  status=$?

  if [ $status -ne 0 ] || [ -z "$text" ]; then
    printf '♫ nothing\n' > "$OUT"
    return
  fi

  printf '♫ %s\n' "$text" > "$OUT"
}

update

playerctl --follow metadata --format '{{artist}} - {{title}}' 2>/dev/null | while IFS= read -r _; do
  update
done
