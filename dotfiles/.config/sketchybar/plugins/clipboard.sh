#!/bin/bash
# Portapapeles (Maccy): solo el icono; el nombre al pasar el ratón. El clic lo
# gestiona click_script en sketchybarrc.
source "$CONFIG_DIR/plugins/hover.sh"
hover "Portapapeles"
sketchybar --animate tanh 10 --set "$NAME" "${HOVER_ARGS[@]}"
