#!/bin/bash
# Avisos sin leer de una app ($1 = nombre). Solo se ve el icono cuando hay alguno;
# el número al pasar el ratón.
source "$CONFIG_DIR/plugins/hover.sh"
# El globo se lee del Dock (helpers/badges): lsappinfo ya no lo da en macOS 27.
COUNT=$("$CONFIG_DIR/helpers/badges" "$1" 2>/dev/null)

if [ -n "$COUNT" ]; then
  hover "$1 · $COUNT"
  sketchybar --set "$NAME" drawing=on "${HOVER_ARGS[@]}"
  python3 "$CONFIG_DIR/helpers/notch.py" fit &
else
  sketchybar --set "$NAME" drawing=off
fi
