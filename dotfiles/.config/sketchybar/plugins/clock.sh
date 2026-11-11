#!/bin/bash
# Fecha corta "L 09/11 10:37"; al pasar el ratón, la fecha completa en un tooltip.
source "$CONFIG_DIR/plugins/hover.sh"

DAYS=(L M X J V S D)
LABEL="${DAYS[$(( $(date +%u) - 1 ))]} $(date '+%d/%m %H:%M')"

hover "$(LC_TIME=es_ES.UTF-8 date '+%A, %-d de %B de %Y · %H:%M')"
sketchybar --set "$NAME" label="$LABEL"
