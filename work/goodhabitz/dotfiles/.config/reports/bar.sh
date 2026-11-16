#!/bin/bash
# GoodHabitz (work/goodhabitz). Lo carga sketchybar-tools.sh.
# Reports de las automatizaciones de Orca (~/Reports). Magenta = hay alguno sin leer.
# Cada minuto, ~/.config/reports/reports.py scan limpia los viejos, avisa de los nuevos
# con una notificación y lista los no leídos. Clic = menú con los no leídos (clic en uno
# lo abre en el lector del navegador), el lector completo y "marcar todo como leído".
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"
REPORTS="python3 $HOME/.config/reports/reports.py"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

CLOSE="sketchybar --set $NAME popup.drawing=off"
REFRESH="sketchybar --trigger reports_change"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/reports\.r\..*/' 2>/dev/null
  i=0
  while IFS=$'\t' read -r path folder date title; do
    i=$((i + 1))
    sketchybar --add item "reports.r.$i" popup.reports \
               --set "reports.r.$i" icon=󰈙 icon.color=$MAGENTA \
                     label="$folder · ${date:8:2}/${date:5:2}" \
                     click_script="$CLOSE; $REPORTS open '$path'; $REFRESH"
  done < <($REPORTS unread)
  if [ "$i" -eq 0 ]; then
    sketchybar --add item reports.r.none popup.reports \
               --set reports.r.none icon=󰄬 icon.color=$GREEN label="Nada sin leer" label.color=$MUTED
  else
    sketchybar --add item reports.r.all popup.reports \
               --set reports.r.all icon=󰄹 icon.color=$GREEN label="Marcar todo como leído" \
                     click_script="$CLOSE; $REPORTS read-all; $REFRESH"
  fi
  sketchybar --add item reports.r.open popup.reports \
             --set reports.r.open icon=󰂺 icon.color=$CYAN label="Abrir el lector" \
                   click_script="$CLOSE; $REPORTS open; $REFRESH"
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

COUNT=$($REPORTS scan | grep -c .)
if [ "$COUNT" -gt 0 ]; then
  COLOR=$MAGENTA
  [ "$COUNT" -eq 1 ] && MSG="1 report sin leer" || MSG="$COUNT reports sin leer"
else
  COLOR=$MUTED
  MSG="Reports al día"
fi
hover "$MSG"
sketchybar --set "$NAME" icon.color=$COLOR "${HOVER_ARGS[@]}"
