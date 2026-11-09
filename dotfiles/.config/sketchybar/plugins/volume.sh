#!/bin/bash
# Volumen: el icono dice el nivel; el % al pasar el ratón. Clic = deslizador,
# silencio y controles de reproducción.
source "$CONFIG_DIR/plugins/hover.sh"
VOL=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set "$NAME" popup.drawing=toggle
fi

if [ "$MUTED" = "true" ] || [ "$VOL" = "0" ]; then
  ICON=󰖁; LABEL="mute"; MUTE_LABEL="Activar sonido"
elif [ "$VOL" -ge 60 ]; then
  ICON=󰕾; LABEL="${VOL}%"; MUTE_LABEL="Silenciar"
elif [ "$VOL" -ge 25 ]; then
  ICON=󰖀; LABEL="${VOL}%"; MUTE_LABEL="Silenciar"
else
  ICON=󰕿; LABEL="${VOL}%"; MUTE_LABEL="Silenciar"
fi

hover "Volumen $LABEL"
sketchybar --animate tanh 10 --set "$NAME" icon="$ICON" "${HOVER_ARGS[@]}" \
           --set volume.slider slider.percentage="$VOL" \
           --set volume.mute label="$MUTE_LABEL"
