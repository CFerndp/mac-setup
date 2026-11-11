#!/bin/bash
# Bluetooth: el icono dice el estado (cian = algo conectado, gris = apagado); al pasar
# el ratón, lo conectado. Clic = dispositivos emparejados (clic en uno lo conecta o
# desconecta) y Ajustes. Clic derecho = Ajustes de Bluetooth.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"
BT="$CONFIG_DIR/helpers/bluetooth"
SETTINGS="x-apple.systempreferences:com.apple.BluetoothSettings"

case "$SENDER" in
  mouse.exited.global)
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
  mouse.clicked)
    if [ "$BUTTON" = "right" ]; then
      open "$SETTINGS"
      exit 0
    fi
    sketchybar --remove '/bluetooth\.dev\..*/' >/dev/null 2>&1
    sketchybar --add item bluetooth.dev.header popup.bluetooth \
               --set bluetooth.dev.header label="DISPOSITIVOS" label.color=$MUTED icon.drawing=off \
                     label.font="JetBrainsMono Nerd Font:Bold:11.0"
    i=0
    while IFS='|' read -r addr connected kind name; do
      [ -n "$addr" ] || continue
      i=$((i + 1))
      case "$kind" in
        audio) mark=󰋋 ;; input) mark=󰌌 ;; phone) mark=󰏲 ;; computer) mark=󰍹 ;; *) mark=󰂯 ;;
      esac
      # Conectado en magenta, como el dispositivo elegido en el menú de audio
      if [ "$connected" = 1 ]; then color=$MAGENTA; else color=$TEXT; fi
      sketchybar --add item "bluetooth.dev.$i" popup.bluetooth \
                 --set "bluetooth.dev.$i" icon="$mark" icon.color=$color label="$name" label.color=$color \
                       click_script="sketchybar --set bluetooth popup.drawing=off; $BT toggle $addr; sketchybar --trigger bluetooth_change"
    done < <("$BT" list)
    if [ "$i" = 0 ]; then
      sketchybar --add item bluetooth.dev.none popup.bluetooth \
                 --set bluetooth.dev.none icon.drawing=off label="Ninguno emparejado" label.color=$MUTED
    fi
    sketchybar --add item bluetooth.dev.settings popup.bluetooth \
               --set bluetooth.dev.settings icon=󰒓 icon.color=$VIOLET label="Ajustes de Bluetooth" \
                     click_script="sketchybar --set bluetooth popup.drawing=off; open '$SETTINGS'" \
               --set "$NAME" popup.drawing=toggle
    exit 0
    ;;
esac

if [ "$("$BT" status)" != "on" ]; then
  hover "Bluetooth apagado"
  sketchybar --set "$NAME" icon=󰂲 icon.color=$MUTED "${HOVER_ARGS[@]}"
  exit 0
fi

CONNECTED=$("$BT" list | awk -F'|' '$2 == 1 { print $4 }' | paste -sd ',' - | sed 's/,/, /g')
if [ -n "$CONNECTED" ]; then
  hover "Bluetooth · $CONNECTED"
  sketchybar --set "$NAME" icon=󰂱 icon.color=$CYAN "${HOVER_ARGS[@]}"
else
  hover "Bluetooth · nada conectado"
  sketchybar --set "$NAME" icon=󰂯 icon.color=$TEXT "${HOVER_ARGS[@]}"
fi
