#!/bin/bash
# Fecha corta "L 09/11 10:37"; al pasar el ratón, la fecha completa en un tooltip.
# Clic = recargar la barra o reiniciar SketchyBar (por si se descoloca).
source "$CONFIG_DIR/plugins/hover.sh"

case "$SENDER" in
  mouse.clicked)       sketchybar --set "$NAME" popup.drawing=toggle; exit 0 ;;
  mouse.exited.global) sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
esac

DAYS=(L M X J V S D)
LABEL="${DAYS[$(( $(date +%u) - 1 ))]} $(date '+%d/%m %H:%M')"

hover "$(LC_TIME=es_ES.UTF-8 date '+%A, %-d de %B de %Y · %H:%M')"
sketchybar --set "$NAME" label="$LABEL"
