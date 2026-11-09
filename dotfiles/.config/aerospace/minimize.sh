#!/bin/bash
# Minimizar y restaurar ventanas con AeroSpace (SUPER+M / SUPER+Shift+M).
#   minimize.sh min      -> apunta la ventana activa y la minimiza al Dock
#   minimize.sh restore  -> restaura la última ventana minimizada con min; si no
#                           queda ninguna apuntada, las minimizadas de la app activa
AEROSPACE=/opt/homebrew/bin/aerospace
STACK="${TMPDIR:-/tmp}/aerospace_minimized"

restore() { # restore <app> [título]: restaura y trae al frente; falla si no había ninguna
  osascript - "$1" "${2:-}" <<'APPLESCRIPT'
on run argv
  set appName to item 1 of argv
  set winTitle to item 2 of argv
  set restored to false
  tell application "System Events"
    if not (exists process appName) then error "No está abierta"
    tell process appName
      -- Primero la ventana exacta; si cambió de título, cualquiera minimizada
      repeat with pass from 1 to 2
        repeat with w in windows
          if value of attribute "AXMinimized" of w is true then
            if pass is 2 or winTitle is "" or name of w is winTitle then
              set value of attribute "AXMinimized" of w to false
              set restored to true
              exit repeat
            end if
          end if
        end repeat
        if restored then exit repeat
      end repeat
      if restored then set frontmost to true
    end tell
  end tell
  if not restored then error "Ninguna minimizada"
end run
APPLESCRIPT
}

case "$1" in
  min)
    "$AEROSPACE" list-windows --focused --format '%{app-name}|%{window-title}' >> "$STACK"
    "$AEROSPACE" macos-native-minimize
    ;;
  restore)
    while [ -s "$STACK" ]; do
      last=$(tail -n 1 "$STACK")
      sed -i '' '$d' "$STACK"
      restore "${last%%|*}" "${last#*|}" 2>/dev/null && exit 0
    done
    app=$("$AEROSPACE" list-windows --focused --format '%{app-name}' 2>/dev/null)
    [ -n "$app" ] && restore "$app" 2>/dev/null
    ;;
esac
