#!/bin/bash
# Pinta todos los escritorios de una vez: número + iconos de sus apps. El activo en
# magenta, el visible en la otra pantalla en gris, los vacíos apagados.
# Lo lanza un único item oculto (spaces.observer) para no llamar a AeroSpace 10 veces.
export PATH="/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}"
VISIBLE=" $(aerospace list-workspaces --monitor all --visible | tr '\n' ' ') "
WINDOWS=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' | sort -u)

args=()
for sid in $(aerospace list-workspaces --all); do
  icons=""
  while IFS='|' read -r ws app; do
    [ "$ws" = "$sid" ] || continue
    __icon_map "$app"
    icons+="${icons:+ }$icon_result"
  done <<<"$WINDOWS"
  if [ -n "$icons" ]; then has=on; else has=off; fi

  if [ "$sid" = "$FOCUSED" ]; then
    args+=(--set "space.$sid" label="$icons" label.drawing=$has background.drawing=on background.color=$MAGENTA icon.color=$BG label.color=$BG)
  elif [[ "$VISIBLE" == *" $sid "* ]]; then
    args+=(--set "space.$sid" label="$icons" label.drawing=$has background.drawing=on background.color=$SURFACE icon.color=$CYAN label.color=$CYAN)
  elif [ -n "$icons" ]; then
    args+=(--set "space.$sid" label="$icons" label.drawing=on background.drawing=off icon.color=$TEXT label.color=$TEXT)
  else
    args+=(--set "space.$sid" label="" label.drawing=off background.drawing=off icon.color=$MUTED label.color=$MUTED)
  fi
done

sketchybar --animate tanh 12 "${args[@]}"

# En la pantalla con notch, compactar si invade la cámara
python3 "$CONFIG_DIR/helpers/notch.py" fit &
