#!/bin/bash
# Brillo del monitor externo con BetterDisplay (su CLI: betterdisplaycli).
# Solo el icono; el % al pasar el ratón. Clic = deslizador. Rueda = subir/bajar.
# Se oculta si no hay monitor externo o BetterDisplay no está abierto.
export PATH="/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/plugins/hover.sh"

case "$SENDER" in
  mouse.exited.global) sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
  mouse.clicked)       sketchybar --set "$NAME" popup.drawing=toggle ;;
esac

# Nombre del primer monitor que no sea la pantalla del portátil
DISPLAY_NAME=$(betterdisplaycli get --identifiers 2>/dev/null | python3 -c '
import json, sys
try:
    items = json.loads("[" + sys.stdin.read() + "]")
except ValueError:
    sys.exit()
for d in items:
    if d.get("deviceType") == "Display" and d.get("originalName") != "Color LCD":
        print(d["name"]); break')

if [ -z "$DISPLAY_NAME" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.scrolled" ]; then
  cur=$(betterdisplaycli get --name="$DISPLAY_NAME" --brightness)
  new=$(python3 -c "print(min(1, max(0, $cur + ${SCROLL_DELTA:-0} * 0.05)))")
  betterdisplaycli set --name="$DISPLAY_NAME" --brightness="$new"
fi

PCT=$(betterdisplaycli get --name="$DISPLAY_NAME" --brightness | python3 -c 'import sys; print(round(float(sys.stdin.read()) * 100))')
echo "$DISPLAY_NAME" > "${TMPDIR:-/tmp}/sketchybar_brightness_display"

hover "Brillo $PCT%"
sketchybar --animate tanh 10 --set "$NAME" drawing=on "${HOVER_ARGS[@]}" \
           --set brightness.slider slider.percentage="$PCT"
