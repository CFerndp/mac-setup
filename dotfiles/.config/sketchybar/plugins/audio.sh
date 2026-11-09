#!/bin/bash
# Altavoz y micrófono seleccionados: solo iconos; al pasar el ratón, sus nombres.
# Clic = menú para elegir dispositivo.
export PATH="/opt/homebrew/bin:$PATH"
source "$CONFIG_DIR/colors.sh"
HOVER="${TMPDIR:-/tmp}/sketchybar_audio_hover"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

short() { [ ${#1} -gt 14 ] && printf '%s…' "${1:0:13}" || printf '%s' "$1"; }

icon_for() {
  case "$1" in
    *[Hh]eadset*|*[Hh]eadphone*|*[Aa]uricular*|*AirPods*|*G435*) echo 󰋋 ;;
    *LG*|*[Mm]onitor*|*DELL*|*Dell*) echo 󰍹 ;;
    *) echo 󰓃 ;;
  esac
}

OUT=$(SwitchAudioSource -c -t output)
IN=$(SwitchAudioSource -c -t input)

add_section() { # $1 = output|input, $2 = título, $3 = dispositivo actual
  sketchybar --add item "audio.dev.h$1" popup.audio \
             --set "audio.dev.h$1" label="$2" label.color=$MUTED icon.drawing=off \
                   label.font="JetBrainsMono Nerd Font:Bold:11.0"
  while IFS= read -r line; do
    id=$(awk -F, '{ print $(NF-1) }' <<<"$line")
    name=$(awk -F, '{ NF -= 3; print }' OFS=, <<<"$line")
    if [ "$name" = "$3" ]; then mark=󰄴; color=$MAGENTA; else mark=󰄰; color=$TEXT; fi
    sketchybar --add item "audio.dev.$id" popup.audio \
               --set "audio.dev.$id" icon="$mark" icon.color=$color label="$name" label.color=$color \
                     click_script="SwitchAudioSource -t $1 -i $id >/dev/null; sketchybar --set audio popup.drawing=off --trigger audio_change"
  done < <(SwitchAudioSource -a -t "$1" -f cli)
}

if [ "$SENDER" = "mouse.clicked" ] && [ "$BUTTON" = "right" ]; then
  open "x-apple.systempreferences:com.apple.Sound-Settings.extension"
  exit 0
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --remove '/audio\.dev\..*/' 2>/dev/null
  add_section output "SALIDA" "$OUT"
  add_section input "ENTRADA" "$IN"
  sketchybar --set audio popup.drawing=toggle
  exit 0
fi

case "$SENDER" in
  mouse.entered) touch "$HOVER" ;;
  mouse.exited)  rm -f "$HOVER" ;;
esac

if [ -f "$HOVER" ]; then
  LABEL="$(short "$OUT")  󰍬 $(short "$IN")"
else
  LABEL="󰍬"
fi
sketchybar --animate tanh 10 --set "$NAME" icon="$(icon_for "$OUT")" label="$LABEL"
