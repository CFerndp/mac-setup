#!/bin/bash
# Red: icono según la conexión (Wi-Fi, cable o sin red); tipo e IP al pasar el ratón.
# Clic = abre los ajustes de red del sistema. macOS oculta el nombre de la Wi-Fi a
# las apps sin permiso de ubicación, así que no se muestra.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"

IFACE=$(route -n get default 2>/dev/null | awk '/interface:/ { print $2 }')
WIFI_IFACE=$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$IFACE" = "$WIFI_IFACE" ] || [ -z "$IFACE" ]; then
    open "x-apple.systempreferences:com.apple.wifi-settings-extension"
  else
    open "x-apple.systempreferences:com.apple.Network-Settings.extension"
  fi
  exit 0
fi

IP=$([ -n "$IFACE" ] && ipconfig getifaddr "$IFACE")

if [ -z "$IFACE" ] || [ -z "$IP" ]; then
  ICON=󰖪; COLOR=$RED; TEXT_="Sin conexión"
elif [ "$IFACE" = "$WIFI_IFACE" ]; then
  ICON=󰖩; COLOR=$CYAN; TEXT_="Wi-Fi · $IP"
else
  ICON=󰈀; COLOR=$CYAN; TEXT_="Cable · $IP"
fi

hover "$TEXT_"
sketchybar --animate tanh 10 --set "$NAME" icon="$ICON" icon.color=$COLOR "${HOVER_ARGS[@]}"
