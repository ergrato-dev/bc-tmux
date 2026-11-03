#!/usr/bin/env bash
# Lab 04 — lleva el panel de "logs" a "codigo" y lo devuelve a su ventana.
# Necesita: tmux -L lab -f /dev/null new -d -s mover -n codigo \; new-window -d -n logs
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO 1: comprueba que la ventana existe (list-panes falla si no; display-message no)
#         y guarda el id de su panel:
#         tmx list-panes -t mover:logs >/dev/null
#         pane=$(tmx display-message -p -t mover:logs '#{pane_id}')

# TODO 2: une el panel a la derecha de codigo sin cambiar el foco (-d) e
#         imprime cuántos paneles tiene codigo:
#         tmx join-pane -h -d -s "$pane" -t mover:codigo
#         tmx display-message -p -t mover:codigo 'codigo tiene #{window_panes} paneles'

# TODO 3: devuélvelo a una ventana propia llamada logs e imprime las ventanas
#         de mover en una línea:
#         tmx break-pane -d -s "$pane" -n logs
#         echo "ventanas: $(tmx list-windows -t mover -F '#{window_name}' | paste -sd' ' -)"
echo "rearrange.sh: sin implementar" >&2
