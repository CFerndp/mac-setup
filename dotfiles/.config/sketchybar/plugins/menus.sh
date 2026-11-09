#!/bin/bash
# Menús de la app activa en la barra (idea de FelixKratz). Clic en la app activa:
# los escritorios se cambian por los menús (Archivo, Edición…) y viceversa.
# En la pantalla con notch, los que no caben pasan al botón » (helpers/notch.py).
#   menus.sh toggle   -> alterna escritorios / menús
#   menus.sh refresh  -> si los menús están a la vista, recarga los de la app activa
HELPER="$CONFIG_DIR/helpers/menus"
STATE="${TMPDIR:-/tmp}/sketchybar_menus_on"
MAX=15

spaces() { # spaces on|off
  local args=() i
  for i in $(seq 1 10); do args+=(--set "space.$i" drawing="$1"); done
  sketchybar "${args[@]}" 2>/dev/null
}

hide_menus() {
  local args=(--set menu.more drawing=off popup.drawing=off) i
  for i in $(seq 1 $MAX); do args+=(--set "menu.$i" drawing=off label=""); done
  sketchybar "${args[@]}"
}

show_menus() {
  hide_menus
  local args=() i=1
  while IFS= read -r title; do
    [ "$i" -gt "$MAX" ] && break
    args+=(--set "menu.$i" label="$title" drawing=on)
    i=$((i + 1))
  done < <("$HELPER" list)
  [ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
  python3 "$CONFIG_DIR/helpers/notch.py" fit
}

case "$1" in
  toggle)
    if [ -f "$STATE" ]; then
      rm -f "$STATE"
      hide_menus
      sketchybar --remove '/menu\.more\..*/' 2>/dev/null
      spaces on
      sketchybar --trigger aerospace_workspace_change
    else
      touch "$STATE"
      spaces off
      show_menus
    fi
    ;;
  refresh)
    [ -f "$STATE" ] && show_menus
    ;;
esac
