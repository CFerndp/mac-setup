#!/bin/bash
# Distribución de teclado actual. Clic = menú para cambiar entre las activas.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"
IS="$CONFIG_DIR/helpers/inputsource"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

code() {
  case "$1" in
    *Spanish*) echo ES ;;
    *.US|*.US-*) echo US ;;
    *.ABC) echo ABC ;;
    *) echo "${1##*.}" | cut -c1-3 | tr '[:lower:]' '[:upper:]' ;;
  esac
}

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/keyboard\.l\..*/' 2>/dev/null
  i=0
  while IFS='|' read -r id name active; do
    i=$((i + 1))
    if [ "$active" = 1 ]; then mark=󰄴; color=$MAGENTA; else mark=󰄰; color=$TEXT; fi
    sketchybar --add item "keyboard.l.$i" popup.keyboard \
               --set "keyboard.l.$i" icon="$mark" icon.color=$color \
                     label="$(code "$id")  $name" label.color=$color \
                     click_script="$IS select $id; sketchybar --set keyboard popup.drawing=off"
  done < <("$IS" list)
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

IFS='|' read -r id name < <("$IS" current)
hover "$(code "$id") · $name"
sketchybar --animate tanh 10 --set "$NAME" "${HOVER_ARGS[@]}"
