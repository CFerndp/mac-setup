#!/bin/bash
# Lo que suena en el navegador (YouTube Music, Spotify Web, YouTube, SoundCloud en
# Brave o Chrome). Lee el título de la pestaña y sabe si suena porque el navegador
# avisa al sistema con "Playing audio". Clic = menú con controles.
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/hover.sh"
HELPERS="$CONFIG_DIR/helpers"
STATE="${TMPDIR:-/tmp}/sketchybar_media"

if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set "$NAME" popup.drawing=toggle
  exit 0
fi

ASSERTIONS=$(pmset -g assertions)
best="" best_score=-1
for browser in "Brave Browser" "Google Chrome"; do
  pgrep -xq "$browser" || continue
  playing=0
  grep -F "($browser)" <<<"$ASSERTIONS" | grep -q '"Playing audio"' && playing=1
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    url="${line##*|}"
    case "$url" in
      *music.youtube.com*|*open.spotify.com*|*soundcloud.com*) score=2 ;;
      *) score=1 ;;
    esac
    score=$((score + playing * 10))
    if [ "$score" -gt "$best_score" ]; then
      best="$browser|$playing|$line" best_score=$score
    fi
  done < <(osascript "$HELPERS/music_tabs.scpt" "$browser" 2>/dev/null)
done

if [ -z "$best" ]; then
  rm -f "$STATE"
  sketchybar --set "$NAME" drawing=off popup.drawing=off
  exit 0
fi

IFS='|' read -r browser playing wi ti _ <<<"$best"
url="${best##*|}"
title="${best#*|*|*|*|}"; title="${title%|*}"
title=$(sed -E 's/^\([0-9]+\) //; s/ [|-] YouTube Music$//; s/ - YouTube$//; s/ \| Spotify$//; s/ • / — /' <<<"$title")

case "$url" in
  *music.youtube.com*) icon=󰗃; source="YouTube Music" ;;
  *open.spotify.com*)  icon=󰓇; source="Spotify" ;;
  *soundcloud.com*)    icon=󰓀; source="SoundCloud" ;;
  *)                   icon=󰗃; source="YouTube" ;;
esac

echo "$browser|$wi|$ti" > "$STATE"

if [ "$playing" = 1 ]; then
  color=$MAGENTA; status="Sonando"; play_label="Pausa"; play_icon=󰏤
else
  color=$MUTED; status="En pausa"; play_label="Reproducir"; play_icon=󰐊
fi

hover "$title"
sketchybar --animate tanh 10 --set "$NAME" drawing=on icon="$icon" icon.color=$color label.color=$color "${HOVER_ARGS[@]}" \
           --set media.title label="$title" \
           --set media.source icon="$icon" label="$source · ${browser% Browser} · $status" \
           --set media.play icon="$play_icon" label="$play_label"
