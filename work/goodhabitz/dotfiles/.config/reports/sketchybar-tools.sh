# GoodHabitz. Lo carga sketchybarrc (bucle de extras de la isla de herramientas).
# Reports de las automatizaciones de Orca (~/Reports): magenta = hay alguno sin leer.
sketchybar --add event reports_change
tip reports right
sketchybar --add item reports right \
           --subscribe reports reports_change system_woke mouse.clicked mouse.exited.global $HOVER \
           --set reports update_freq=60 icon=󰂺 icon.color=$MUTED \
                 script="$HOME/.config/reports/bar.sh" $POPUP
TOOLS_EXTRA+=(reports)
