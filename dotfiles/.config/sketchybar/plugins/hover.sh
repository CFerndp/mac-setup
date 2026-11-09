# Filosofía de la barra: solo iconos; el dato aparece al pasar el ratón por encima.
# Uso: source "$CONFIG_DIR/plugins/hover.sh"; hover "texto"
#      sketchybar --set "$NAME" ... "${HOVER_ARGS[@]}"
HOVER_FILE="${TMPDIR:-/tmp}/sketchybar_hover_$NAME"

case "$SENDER" in
  mouse.entered) touch "$HOVER_FILE" ;;
  mouse.exited)  rm -f "$HOVER_FILE" ;;
esac

hover() {
  if [ -f "$HOVER_FILE" ] && [ -n "$1" ]; then
    HOVER_ARGS=(label="$1" label.drawing=on)
  else
    HOVER_ARGS=(label.drawing=off)
  fi
}
