#!/usr/bin/env bash
# Comprueba que todo el setup está en marcha: apps y servicios, enlaces del repo,
# helpers compilados, config de AeroSpace y ajustes de macOS. Solo lee; no cambia nada.
# La salida va en inglés, como el README.
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
  if pgrep -xq "$1"; then ok "$2"; else bad "$2 is not running" "→ $3"; fi
}

section "Apps and services"
running AeroSpace AeroSpace "open -a AeroSpace"
running sketchybar SketchyBar "brew services restart sketchybar"
running borders "JankyBorders (borders)" "brew services restart borders"
if pgrep -fq Karabiner-Core-Service; then ok "Karabiner (Caps Lock = SUPER)"; else bad "Karabiner is not running" "→ open Karabiner-Elements"; fi
if launchctl list 2>/dev/null | grep -q com.cferndp.neon-wallpaper; then
  if pgrep -fq 'neon-wallpaper/wallpaper$'; then ok "Animated wallpaper"; else bad "Animated wallpaper: agent loaded but not running" "→ launchctl kickstart -k gui/$(id -u)/com.cferndp.neon-wallpaper"; fi
else
  bad "Animated wallpaper does not start at login" "→ ~/.config/neon-wallpaper/wallpaper.sh on"
fi
running BetterDisplay "BetterDisplay (bar brightness)" "open -a BetterDisplay and enable \"Launch at login\""
running Maccy "Maccy (clipboard)" "open -a Maccy"
running Shottr "Shottr (screenshots)" "open -a Shottr"

section "Repo symlinks"
while read -r path; do
  dst="$HOME/$path" src="$REPO/dotfiles/$path"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then ok "~/$path"
  else bad "~/$path does not point to the repo" "→ ./link.sh"; fi
done < <(sed -nE 's/^link "?([^"]+)"?$/\1/p' "$REPO/link.sh")

section "Compiled helpers"
H="$HOME/.config/sketchybar/helpers"
for f in "$H/inputsource" "$H/mediakey" "$H/menus" "$H/hotkey" "$H/badges" "$H/bluetooth" "$H/music_tabs.scpt" "$H/focus_tab.scpt" \
         "$HOME/.config/neon-wallpaper/wallpaper"; do
  if [ -e "$f" ]; then ok "${f/#$HOME/~}"; else bad "${f/#$HOME/~} is missing" "→ ./link.sh (or wallpaper.sh on)"; fi
done

section "Settings"
if aerospace reload-config --dry-run >/dev/null 2>&1; then ok "~/.aerospace.toml is valid"
else bad "~/.aerospace.toml has errors" "→ aerospace reload-config --dry-run"; fi
if [ "$(defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null)" = 1 ]; then ok "macOS menu bar auto-hidden"
else warn "macOS menu bar is not auto-hidden" "→ setup.sh turns it on"; fi
if grep -q 'neon-noir/theme.zsh' ~/.zshrc 2>/dev/null; then ok "~/.zshrc loads the Neon Noir theme"
else warn "~/.zshrc does not load the theme" "→ snippets/zshrc.sh"; fi
for font in JetBrainsMonoNerdFont-Regular sketchybar-app-font; do
  if ls ~/Library/Fonts/"$font".ttf >/dev/null 2>&1; then ok "Font $font"
  else bad "Missing font $font" "→ brew bundle --file Brewfile"; fi
done
if ls "$HOME/.config/neon-wallpaper/static/"*.png >/dev/null 2>&1; then
  ok "Static wallpaper generated"
else warn "No static wallpaper" "→ ~/.config/neon-wallpaper/wallpaper set-static"; fi

section "Permissions (cannot be checked from here)"
printf '  %s\n' "${DIM}System Settings → Privacy & Security → Accessibility: these must be${RESET}"
printf '  %s\n' "${DIM}enabled: AeroSpace, SketchyBar, Karabiner-Elements, Maccy and BetterDisplay.${RESET}"

echo
if [ "$failures" -eq 0 ]; then
  printf '%s All good.\n' "$OK"
else
  printf '%s %s problem(s). See above for how to fix each one.\n' "$BAD" "$failures"
  exit 1
fi
