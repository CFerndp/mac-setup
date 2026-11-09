#!/bin/bash
# Mover el deslizador cambia el volumen.
if [ "$SENDER" = "mouse.clicked" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
fi
