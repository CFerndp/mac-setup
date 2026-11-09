#!/bin/bash
# Volumen: el icono dice el nivel; el % al pasar el ratón. Rueda = subir/bajar.
# Clic = deslizador, silencio y reproducción. Clic derecho = ajustes de sonido.
source "$CONFIG_DIR/plugins/hover.sh"

case "$SENDER" in
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
  mouse.clicked)
    if [ "$BUTTON" = "right" ]; then
      open "x-apple.systempreferences:com.apple.Sound-Settings.extension"
      exit 0
    fi
    sketchybar --set "$NAME" popup.drawing=toggle
    ;;
  mouse.scrolled)
    osascript -e "set volume output volume ((output volume of (get volume settings)) + ${SCROLL_DELTA:-0} * 5)"
    ;;
esac

VOL=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

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
