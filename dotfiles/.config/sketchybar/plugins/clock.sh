#!/bin/bash
# Fecha corta "L 09/11 10:37"; al pasar el ratón por encima, la fecha completa.
HOVER="${TMPDIR:-/tmp}/sketchybar_clock_hover"

case "$SENDER" in
  mouse.entered) touch "$HOVER" ;;
  mouse.exited)  rm -f "$HOVER" ;;
esac

if [ -f "$HOVER" ]; then
  LABEL=$(LC_TIME=es_ES.UTF-8 date '+%A, %-d de %B de %Y · %H:%M')
else
  DAYS=(L M X J V S D)
  LABEL="${DAYS[$(( $(date +%u) - 1 ))]} $(date '+%d/%m %H:%M')"
fi

sketchybar --animate tanh 10 --set "$NAME" label="$LABEL"
