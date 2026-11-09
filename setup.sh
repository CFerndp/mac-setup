#!/usr/bin/env bash
# Setup del Mac para desarrollo. Se puede ejecutar varias veces sin problema.
set -euo pipefail

echo "==> Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
fi

echo "==> Herramientas de línea de comandos"
brew install btop duti fastfetch switchaudio-osx

echo "==> Apps"
brew install --cask \
  maccy \
  shottr \
  nikitabobko/tap/aerospace \
  karabiner-elements \
  font-jetbrains-mono-nerd-font \
  font-sketchybar-app-font \
  dbeaver-community \
  jordanbaird-ice \
  betterdisplay \
  appcleaner \
  keka

echo "==> SketchyBar y JankyBorders (se compilan: requieren Command Line Tools al día)"
brew tap FelixKratz/formulae
brew trust --formula felixkratz/formulae/sketchybar
brew trust --formula felixkratz/formulae/borders
brew install sketchybar borders

echo "==> Configuraciones del repo"
"$(cd "$(dirname "$0")" && pwd)/link.sh"

brew services start felixkratz/formulae/sketchybar
brew services start felixkratz/formulae/borders

echo "==> WezTerm abre scripts y enlaces ssh"
B=com.github.wez.wezterm
for ext in sh zsh bash; do duti -s $B .$ext all; done
duti -s $B com.apple.terminal.shell-script all
for s in ssh telnet x-man-page; do duti -s $B $s; done

echo "==> Ajustes de macOS"
# Repetición de teclas rápida (se aplica al cerrar sesión)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Finder: archivos ocultos y extensiones visibles
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Capturas en ~/Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# Barra de menú oculta (SketchyBar ocupa su lugar)
osascript -e 'tell application "System Events" to set autohide menu bar of dock preferences to true'

killall Finder SystemUIServer 2>/dev/null || true

echo
echo "Listo. Cierra sesión y vuelve a entrar para aplicar la repetición de teclas."
echo "Falta a mano: la línea de fastfetch en ~/.zshrc y los temas de Zed y VS Code"
echo "(ver la carpeta snippets/)."
