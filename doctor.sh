#!/usr/bin/env bash
# Comprueba que todo el setup está en marcha: apps y servicios, enlaces del repo,
# helpers compilados, config de AeroSpace y ajustes de macOS. Solo lee; no cambia nada.
#   ./doctor.sh
# Sale con código 1 si algo falla.

REPO="$(cd "$(dirname "$0")" && pwd)"
export PATH="/opt/homebrew/bin:$PATH"

OK=$'\e[38;2;0;255;159m✓\e[0m'
BAD=$'\e[38;2;255;42;109m✗\e[0m'
WARN=$'\e[38;2;243;230;0m!\e[0m'
TITLE=$'\e[1;38;2;5;217;232m'
DIM=$'\e[38;2;108;108;138m'
RESET=$'\e[0m'
failures=0

section() { printf '\n%s%s%s\n' "$TITLE" "$1" "$RESET"; }
ok()   { printf '  %s %s\n' "$OK" "$1"; }
bad()  { printf '  %s %s %s\n' "$BAD" "$1" "${DIM}${2:-}${RESET}"; failures=$((failures + 1)); }
warn() { printf '  %s %s %s\n' "$WARN" "$1" "${DIM}${2:-}${RESET}"; }

running() { # running <proceso> <nombre> <cómo arreglarlo>
  if pgrep -xq "$1"; then ok "$2"; else bad "$2 no está en marcha" "→ $3"; fi
}

section "Apps y servicios"
running AeroSpace AeroSpace "open -a AeroSpace"
running sketchybar SketchyBar "brew services restart sketchybar"
running borders "JankyBorders (bordes)" "brew services restart borders"
if pgrep -fq Karabiner-Core-Service; then ok "Karabiner (Caps Lock = SUPER)"; else bad "Karabiner no está en marcha" "→ abre Karabiner-Elements"; fi
if launchctl list 2>/dev/null | grep -q com.cferndp.neon-wallpaper; then
  if pgrep -fq 'neon-wallpaper/wallpaper$'; then ok "Fondo animado"; else bad "Fondo animado: agente cargado pero sin proceso" "→ launchctl kickstart -k gui/$(id -u)/com.cferndp.neon-wallpaper"; fi
else
  bad "Fondo animado sin arranque automático" "→ ~/.config/neon-wallpaper/wallpaper.sh on"
fi
running BetterDisplay "BetterDisplay (brillo en la barra)" "open -a BetterDisplay y activa «Launch at login»"
running Maccy "Maccy (portapapeles)" "open -a Maccy"
running Shottr "Shottr (capturas)" "open -a Shottr"

section "Enlaces del repo"
while read -r path; do
  dst="$HOME/$path" src="$REPO/dotfiles/$path"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then ok "~/$path"
  else bad "~/$path no apunta al repo" "→ ./link.sh"; fi
done < <(sed -nE 's/^link "?([^"]+)"?$/\1/p' "$REPO/link.sh")

section "Helpers compilados"
H="$HOME/.config/sketchybar/helpers"
for f in "$H/inputsource" "$H/mediakey" "$H/menus" "$H/hotkey" "$H/music_tabs.scpt" "$H/focus_tab.scpt" \
         "$HOME/.config/neon-wallpaper/wallpaper"; do
  if [ -e "$f" ]; then ok "${f/#$HOME/~}"; else bad "${f/#$HOME/~} no existe" "→ ./link.sh (o wallpaper.sh on)"; fi
done

section "Configuración"
if aerospace reload-config --dry-run >/dev/null 2>&1; then ok "~/.aerospace.toml es válido"
else bad "~/.aerospace.toml tiene errores" "→ aerospace reload-config --dry-run"; fi
if [ "$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null)" = 1 ]; then ok "Barra de macOS oculta"
else warn "La barra de macOS no se oculta" "→ setup.sh lo activa"; fi
if grep -q 'neon-noir/theme.zsh' ~/.zshrc 2>/dev/null; then ok "~/.zshrc carga el tema Neon Noir"
else warn "~/.zshrc no carga el tema" "→ snippets/zshrc.sh"; fi
for font in JetBrainsMonoNerdFont-Regular sketchybar-app-font; do
  if ls ~/Library/Fonts/"$font".ttf >/dev/null 2>&1; then ok "Fuente $font"
  else bad "Falta la fuente $font" "→ brew bundle --file Brewfile"; fi
done
if ls "$HOME/.config/neon-wallpaper/static/"*.png >/dev/null 2>&1; then
  ok "Fondo estático generado"
else warn "Sin fondo estático" "→ ~/.config/neon-wallpaper/wallpaper set-static"; fi

section "Permisos (no se pueden comprobar desde aquí)"
printf '  %s\n' "${DIM}Ajustes del Sistema → Privacidad y seguridad → Accesibilidad: deben estar${RESET}"
printf '  %s\n' "${DIM}activados AeroSpace, SketchyBar, Karabiner-Elements, Maccy y BetterDisplay.${RESET}"

echo
if [ "$failures" -eq 0 ]; then
  printf '%s Todo en orden.\n' "$OK"
else
  printf '%s %s problema(s). Arriba tienes cómo arreglar cada uno.\n' "$BAD" "$failures"
  exit 1
fi
