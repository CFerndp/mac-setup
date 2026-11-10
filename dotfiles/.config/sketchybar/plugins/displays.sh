#!/bin/bash
# Al conectar o desconectar una pantalla: los escritorios se crean en sketchybarrc
# atados a la pantalla que había al arrancar, así que si cambia el conjunto de
# pantallas se recarga la barra entera (y AeroSpace ya habrá movido los escritorios).
# Si solo ha sido un despertar o macOS ha recolocado lo mismo, basta con el notch.
#   displays.sh save   -> guarda las pantallas actuales (lo llama sketchybarrc)
#   displays.sh        -> lo lanza display_change / system_woke
export PATH="/opt/homebrew/bin:$PATH"
STATE="${TMPDIR:-/tmp}/sketchybar_displays"
NOTCH="python3 $CONFIG_DIR/helpers/notch.py"

current() {
  aerospace list-monitors --format '%{monitor-name}|%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null
}

if [ "$1" = "save" ]; then
  current > "$STATE"
  exit 0
fi

# Un cambio de pantallas dispara varios eventos seguidos: esperar a que macOS y
# AeroSpace terminen de recolocar, y quedarse solo con el último
echo $$ > "$STATE.pending"
sleep 2
[ "$(cat "$STATE.pending" 2>/dev/null)" = "$$" ] || exit 0

if [ "$(current)" != "$(cat "$STATE" 2>/dev/null)" ]; then
  sketchybar --reload
else
  $NOTCH detect; $NOTCH fit
fi
