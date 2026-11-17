#!/bin/bash
# Arreglar la barra cuando se descoloca (desde el reloj o SUPER+Shift+R).
#   reset.sh reload    -> vuelve a cargar la config (rápido; suele bastar)
#   reset.sh restart   -> reinicia el servicio de SketchyBar (si la recarga no basta)
# Se lanza desacoplado: la recarga mata los scripts que la barra tenga en marcha.
export PATH="/opt/homebrew/bin:$PATH"
case "$1" in
  restart) nohup brew services restart sketchybar >/dev/null 2>&1 & ;;
  *)       nohup sketchybar --reload >/dev/null 2>&1 & ;;
esac
