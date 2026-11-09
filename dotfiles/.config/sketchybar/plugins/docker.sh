#!/bin/bash
# Contenedores de Docker en marcha. Clic = menú con cada contenedor (clic en uno = ver
# sus logs en WezTerm). Se oculta si Docker no está corriendo.
export PATH="$HOME/.docker/bin:/Applications/Docker.app/Contents/Resources/bin:/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"
DOCKER="$(command -v docker)"
WEZTERM=/Applications/WezTerm.app/Contents/MacOS/wezterm

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

if ! "$DOCKER" info >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off popup.drawing=off
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/docker\.c\..*/' 2>/dev/null
  i=0
  while IFS='|' read -r name image status; do
    i=$((i + 1))
    sketchybar --add item "docker.c.$i" popup.docker \
               --set "docker.c.$i" icon=󰡨 icon.color=$GREEN \
                     label="$name  ·  $image  ·  $status" \
                     click_script="sketchybar --set docker popup.drawing=off; $WEZTERM start -- $DOCKER logs -f --tail 200 $name"
  done < <("$DOCKER" ps --format '{{.Names}}|{{.Image}}|{{.Status}}')
  if [ "$i" -eq 0 ]; then
    sketchybar --add item docker.c.none popup.docker \
               --set docker.c.none icon=󰅙 icon.color=$MUTED label="Sin contenedores en marcha" label.color=$MUTED
  fi
  sketchybar --add item docker.c.open popup.docker \
             --set docker.c.open icon=󰏌 icon.color=$CYAN label="Abrir Docker Desktop" \
                   click_script="sketchybar --set docker popup.drawing=off; open -a Docker"
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

COUNT=$("$DOCKER" ps -q | wc -l | tr -d ' ')
if [ "$COUNT" -gt 0 ]; then COLOR=$GREEN; else COLOR=$MUTED; fi
hover "Docker · $COUNT en marcha"
sketchybar --animate tanh 10 --set "$NAME" drawing=on icon.color=$COLOR "${HOVER_ARGS[@]}"
