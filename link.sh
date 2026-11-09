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
link .config/aerospace
link .config/karabiner
link .config/fastfetch
link .config/neon-wallpaper
link .config/neon-noir
link .config/btop/themes/neon-noir.theme
link "Library/Application Support/lazygit/config.yml"
link .config/zed/themes/neon-noir.json

# btop: activar el tema (btop reescribe su btop.conf al salir, así que no se enlaza)
BTOP_CONF="$HOME/.config/btop/btop.conf"
if [ -f "$BTOP_CONF" ] && grep -q '^color_theme' "$BTOP_CONF"; then
  sed -i '' 's|^color_theme = .*|color_theme = "neon-noir"|' "$BTOP_CONF"
else
  printf 'color_theme = "neon-noir"\ntheme_background = False\n' >> "$BTOP_CONF"
fi
echo "ok   btop -> neon-noir"

echo "==> Helpers de SketchyBar"
cd "$REPO/dotfiles/.config/sketchybar/helpers"
swiftc -O inputsource.swift -o inputsource 2>/dev/null
swiftc -O mediakey.swift -o mediakey 2>/dev/null
swiftc -O menus.swift -o menus 2>/dev/null
swiftc -O hotkey.swift -o hotkey 2>/dev/null
swiftc -O badges.swift -o badges 2>/dev/null
osacompile -o music_tabs.scpt music_tabs.applescript
osacompile -o focus_tab.scpt focus_tab.applescript
echo "ok"
