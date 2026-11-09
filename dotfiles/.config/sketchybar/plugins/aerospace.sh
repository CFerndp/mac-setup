#!/bin/bash
# Pinta un escritorio: número + iconos de sus apps. El activo va en magenta neón,
# el visible en la otra pantalla en gris, y los vacíos e inactivos apagados.
export PATH="/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

SID="$1"
if [ -z "$FOCUSED_WORKSPACE" ]; then
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
fi

ICONS=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  __icon_map "$app"
  ICONS+=" $icon_result"
done < <(aerospace list-windows --workspace "$SID" --format '%{app-name}' | sort -u)

if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --animate tanh 12 --set "$NAME" label="$ICONS" background.drawing=on background.color=$MAGENTA \
             icon.color=$BG label.color=$BG
elif aerospace list-workspaces --monitor all --visible | grep -qx "$SID"; then
  sketchybar --animate tanh 12 --set "$NAME" label="$ICONS" background.drawing=on background.color=$SURFACE \
             icon.color=$CYAN label.color=$CYAN
elif [ -n "$ICONS" ]; then
  sketchybar --animate tanh 12 --set "$NAME" label="$ICONS" background.drawing=off \
             icon.color=$TEXT label.color=$TEXT
else
  sketchybar --set "$NAME" label="" background.drawing=off \
             icon.color=$MUTED label.color=$MUTED
fi
