#!/bin/bash
# Energía desde el popup del reloj.
#   power.sh lock      -> bloquea (apaga la pantalla; pide contraseña si así está en Ajustes)
#   power.sh sleep     -> suspende
#   power.sh restart   -> diálogo nativo de macOS para reiniciar (no reinicia sin confirmar)
#   power.sh shutdown  -> diálogo nativo de macOS para apagar
# Reiniciar y apagar piden confirmación con el diálogo de loginwindow, el mismo que el
# del botón de encendido: un clic sin querer no apaga el Mac.
case "$1" in
  lock)     pmset displaysleepnow ;;
  sleep)    pmset sleepnow ;;
  restart)  osascript -e 'tell application "loginwindow" to «event aevtrrst»' ;;
  shutdown) osascript -e 'tell application "loginwindow" to «event aevtrsdn»' ;;
esac
