#!/bin/bash
# Uso de CPU: el icono cambia de color con la carga; el % al pasar el ratón.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"

CORES=$(sysctl -n hw.ncpu)
CPU=$(ps -A -o %cpu | awk -v c="$CORES" '{ s += $1 } END { printf "%d", s / c }')

if [ "$CPU" -ge 80 ]; then COLOR=$RED; elif [ "$CPU" -ge 50 ]; then COLOR=$YELLOW; else COLOR=$CYAN; fi

hover "CPU ${CPU}%"
sketchybar --animate tanh 10 --set "$NAME" icon.color=$COLOR "${HOVER_ARGS[@]}"
