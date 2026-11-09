#!/bin/bash
# Mover el deslizador cambia el brillo del monitor externo.
export PATH="/opt/homebrew/bin:$PATH"
if [ "$SENDER" = "mouse.clicked" ]; then
  name=$(cat "${TMPDIR:-/tmp}/sketchybar_brightness_display" 2>/dev/null)
  [ -n "$name" ] && betterdisplaycli set --name="$name" --brightness="$(python3 -c "print($PERCENTAGE / 100)")"
  sketchybar --trigger brightness_change
fi
