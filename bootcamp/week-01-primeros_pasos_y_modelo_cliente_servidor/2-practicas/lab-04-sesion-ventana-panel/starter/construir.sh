#!/usr/bin/env bash
# Lab 04 — construye la sesión "obra": ventana editor (2 paneles) + ventana logs.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO 1: crea la sesión "obra" en segundo plano con la ventana "editor".

# TODO 2: divide "obra:editor" en dos paneles lado a lado (split-window -h).

# TODO 3: crea la ventana "logs" en la sesión "obra" (new-window -t obra:).

# TODO 4: lista todos los paneles de la sesión (list-panes -s -t obra) con el formato
#         '#{window_name}.#{pane_index} #{pane_id}'
