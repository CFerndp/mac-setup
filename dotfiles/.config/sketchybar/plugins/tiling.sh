#!/bin/bash
# Tiling de AeroSpace activado / desactivado. Clic (o SUPER+Shift+Escape) lo alterna.
# Desactivado, AeroSpace rechaza cualquier comando salvo "enable": así se sabe el
# estado sin guardarlo en ningún sitio. El icono avisa en amarillo si está apagado.
export PATH="/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  aerospace enable toggle
  sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

if aerospace list-modes --current >/dev/null 2>&1; then
  hover "Tiling activo"
  sketchybar --set "$NAME" icon=󰕰 icon.color=$CYAN "${HOVER_ARGS[@]}"
else
  hover "Tiling desactivado · clic para activar"
  sketchybar --set "$NAME" icon=󰖲 icon.color=$YELLOW "${HOVER_ARGS[@]}"
fi
