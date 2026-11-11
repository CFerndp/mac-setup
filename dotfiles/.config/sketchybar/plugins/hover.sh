# Filosofía de la barra: solo iconos; el dato aparece en un tooltip al pasar el ratón.
# El tooltip es el popup de un ancla de ancho 0 pegada al item ("tip.<item>", la crea
# tip() en sketchybarrc), así la barra no cambia de tamaño y nada se mueve bajo el ratón.
# Uso: source "$CONFIG_DIR/plugins/hover.sh"; hover "texto"
#      sketchybar --set "$NAME" ... "${HOVER_ARGS[@]}"
# El item debe estar suscrito a mouse.entered y mouse.exited.
HOVER_FILE="${TMPDIR:-/tmp}/sketchybar_hover_$NAME"
TIP="tip.$NAME"
TIP_DELAY=0.35

case "$SENDER" in
  mouse.entered) touch "$HOVER_FILE" ;;
  # Al salir, y al hacer clic (para no tapar el menú del item), se esconde
  mouse.exited|mouse.exited.global|mouse.clicked)
    rm -f "$HOVER_FILE"
    sketchybar --set "$TIP" popup.drawing=off 2>/dev/null
    ;;
esac

# El dato ya no va en la etiqueta de la barra
HOVER_ARGS=(label.drawing=off)

hover() {
  [ -n "$1" ] || return
  sketchybar --set "$TIP.text" label="$1" 2>/dev/null
  [ "$SENDER" = "mouse.entered" ] || return
  # Con un pequeño retraso, para no ir encendiendo tooltips al cruzar la barra, y
  # solo si el ratón sigue encima y el menú del item no está abierto
  (
    sleep "$TIP_DELAY"
    [ -f "$HOVER_FILE" ] || exit 0
    sketchybar --query "$NAME" 2>/dev/null | tr -d '\n\t' | grep -q '"popup": {"drawing": "on"' && exit 0
    sketchybar --set "$TIP" popup.drawing=on
  ) &
}
