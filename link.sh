#!/usr/bin/env bash
# Enlaza las configuraciones del repo en su sitio (~/...) y compila los helpers de
# SketchyBar. Se puede ejecutar varias veces sin problema. Si en el destino ya hay un
# archivo real, lo guarda como <nombre>.bak-<fecha> antes de enlazar.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$REPO/dotfiles/$1" dst="$HOME/$1"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok   ~/$1"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mv "$dst" "$dst.bak-$(date +%Y%m%d%H%M%S)"
    echo "bak  ~/$1"
  fi
  ln -s "$src" "$dst"
  echo "link ~/$1"
}

echo "==> Enlaces"
link .aerospace.toml
link .wezterm.lua
link .config/sketchybar
link .config/borders
link .config/karabiner
link .config/fastfetch
link .config/zed/themes/neon-noir.json

echo "==> Helpers de SketchyBar"
cd "$REPO/dotfiles/.config/sketchybar/helpers"
swiftc -O inputsource.swift -o inputsource 2>/dev/null
swiftc -O mediakey.swift -o mediakey 2>/dev/null
osacompile -o music_tabs.scpt music_tabs.applescript
osacompile -o focus_tab.scpt focus_tab.applescript
echo "ok"
