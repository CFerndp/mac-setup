#!/bin/bash
# App activa: su icono; el nombre al pasar el ratón. Clic = ver sus menús en la barra.
source "$CONFIG_DIR/plugins/hover.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"
APP_FILE="${TMPDIR:-/tmp}/sketchybar_front_app"

case "$SENDER" in
  mouse.clicked)
    "$CONFIG_DIR/plugins/menus.sh" toggle
    exit 0
    ;;
  front_app_switched)
    echo "$INFO" > "$APP_FILE"
    "$CONFIG_DIR/plugins/menus.sh" refresh &
    ;;
esac
APP=$(cat "$APP_FILE" 2>/dev/null)
__icon_map "$APP"

hover "$APP"
sketchybar --set "$NAME" icon="$icon_result" "${HOVER_ARGS[@]}"
python3 "$CONFIG_DIR/helpers/notch.py" fit &
