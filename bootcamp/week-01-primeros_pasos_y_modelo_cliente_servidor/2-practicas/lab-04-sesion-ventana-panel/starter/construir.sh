#!/usr/bin/env bash
# Lab 04 — construye la sesión "obra": ventana editor (2 paneles) + ventana logs.
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

# TODO 1: crea la sesión "obra" en segundo plano con la ventana "editor".
#         new-session -d -s <sesión> -n <ventana>

# TODO 2: divide "obra:editor" en dos paneles lado a lado.
#         split-window -h -t <sesión>:<ventana>

# TODO 3: crea la ventana "logs" en la sesión "obra" sin activarla.
#         new-window -d -t obra: -n <ventana>     ("obra:" = siguiente índice libre)

# TODO 4: lista todos los paneles de la sesión, una línea por panel:
#         list-panes -s -t obra -F '#{window_name}.#{pane_index} #{pane_id}'
