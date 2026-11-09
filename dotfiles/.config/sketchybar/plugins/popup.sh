#!/bin/bash
# Popup genérico: clic lo abre/cierra; al sacar el ratón de la barra se cierra.
case "$SENDER" in
  mouse.clicked)       sketchybar --set "$NAME" popup.drawing=toggle ;;
  mouse.exited.global) sketchybar --set "$NAME" popup.drawing=off ;;
esac
