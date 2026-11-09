#!/usr/bin/env bash
# Fondo animado Neon Noir.
#   wallpaper.sh on   -> compila el helper y lo deja arrancando solo al iniciar sesión
#   wallpaper.sh off  -> lo para y quita el arranque automático
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT="$HOME/Library/LaunchAgents/com.cferndp.neon-wallpaper.plist"
DOMAIN="gui/$(id -u)"

case "${1:-}" in
  on)
    swiftc -O "$DIR/wallpaper.swift" -o "$DIR/wallpaper"
    mkdir -p "$(dirname "$AGENT")"
    sed "s|HOME_DIR|$HOME|" "$DIR/com.cferndp.neon-wallpaper.plist" > "$AGENT"
    launchctl bootout "$DOMAIN" "$AGENT" 2>/dev/null || true
    launchctl bootstrap "$DOMAIN" "$AGENT"
    echo "Fondo animado activado (arranca solo al iniciar sesión)."
    ;;
  off)
    launchctl bootout "$DOMAIN" "$AGENT" 2>/dev/null || true
    rm -f "$AGENT"
    echo "Fondo animado desactivado."
    ;;
  *)
    echo "Uso: wallpaper.sh on | off" >&2
    exit 1
    ;;
esac
