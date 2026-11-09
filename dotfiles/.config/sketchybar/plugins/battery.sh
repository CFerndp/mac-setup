#!/bin/bash
# Batería: el icono y su color dicen el nivel (rojo si está baja); el % al pasar el ratón.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"

BATT=$(pmset -g batt)
PERCENT=$(grep -Eo '[0-9]+%' <<<"$BATT" | tr -d '%')
[ -z "$PERCENT" ] && exit 0
REMAINING=$(grep -Eo '[0-9]+:[0-9]+ remaining' <<<"$BATT" | cut -d' ' -f1)

if grep -q 'AC Power' <<<"$BATT"; then
  ICON=󰂄; COLOR=$GREEN; TEXT_="${PERCENT}% · cargando"
elif [ "$PERCENT" -gt 60 ]; then
  ICON=󰁹; COLOR=$GREEN; TEXT_="${PERCENT}%"
elif [ "$PERCENT" -gt 25 ]; then
  ICON=󰁾; COLOR=$YELLOW; TEXT_="${PERCENT}%"
else
  ICON=󰁺; COLOR=$RED; TEXT_="${PERCENT}%"
fi
if [ -n "$REMAINING" ] && [ "$REMAINING" != "0:00" ] && ! grep -q "AC Power" <<<"$BATT"; then
  TEXT_="$TEXT_ · quedan $REMAINING"
fi

hover "$TEXT_"
sketchybar --animate tanh 10 --set "$NAME" icon="$ICON" icon.color=$COLOR "${HOVER_ARGS[@]}"
