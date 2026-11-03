#!/usr/bin/env bash
# Lab 04 — lleva el panel de "logs" a "codigo" y lo devuelve a su ventana.
# Necesita: tmux -L lab new -d -s mover -n codigo \; new-window -d -n logs
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

tmx list-panes -t mover:logs >/dev/null   # falla si la ventana no existe
panel=$(tmx display-message -p -t mover:logs '#{pane_id}')

# Tras el join la ventana "logs" deja de existir: solo el id sigue sirviendo.
tmx join-pane -h -d -s "$panel" -t mover:codigo
tmx display-message -p -t mover:codigo 'codigo tiene #{window_panes} paneles'

tmx break-pane -d -s "$panel" -n logs
echo "ventanas: $(tmx list-windows -t mover -F '#{window_name}' | paste -sd' ' -)"
