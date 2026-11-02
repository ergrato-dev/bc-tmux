#!/usr/bin/env bash
# Lab 04 — lleva el panel de "logs" a "codigo" y lo devuelve a su ventana.
# Necesita: tmux -L lab new -d -s mover -n codigo \; new-window -d -n logs
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO 1: guarda el id del panel de mover:logs (display-message -p '#{pane_id}').

# TODO 2: join-pane -h -d -s "$panel" -t mover:codigo
#         e imprime "codigo tiene N paneles" (#{window_panes}).

# TODO 3: break-pane -d -s "$panel" -n logs
#         e imprime "ventanas: ..." con los nombres de las ventanas de mover
#         en una línea (list-windows -F '#{window_name}' | paste -sd' ' -).
echo "reorganizar.sh: sin implementar" >&2
