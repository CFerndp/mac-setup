#!/bin/bash
# App activa: su icono; el nombre al pasar el ratón.
source "$CONFIG_DIR/plugins/hover.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"
APP_FILE="${TMPDIR:-/tmp}/sketchybar_front_app"

if [ "$SENDER" = "front_app_switched" ]; then
  echo "$INFO" > "$APP_FILE"
fi
APP=$(cat "$APP_FILE" 2>/dev/null)
__icon_map "$APP"

hover "$APP"
sketchybar --animate tanh 10 --set "$NAME" icon="$icon_result" "${HOVER_ARGS[@]}"
