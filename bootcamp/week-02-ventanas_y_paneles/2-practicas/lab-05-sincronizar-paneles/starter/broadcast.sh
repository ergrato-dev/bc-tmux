#!/usr/bin/env bash
# Lab 05 — envía un comando a todos los paneles de una ventana.
# Uso: broadcast.sh VENTANA COMANDO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

window="${1:?uso: broadcast.sh VENTANA COMANDO}"
cmd="${2:?uso: broadcast.sh VENTANA COMANDO}"

# TODO 1: guarda los ids de panel de la ventana (uno por línea):
#         panes=$(tmx list-panes -t "$window" -F '#{pane_id}')

# TODO 2: recorre los ids y en cada panel escribe el comando como texto
#         literal (-l; "--" por si empieza por "-") y pulsa Enter aparte:
#         while IFS= read -r pane; do
#           tmx send-keys -t "$pane" -l -- "$cmd"
#           tmx send-keys -t "$pane" Enter
#         done <<<"$panes"

# TODO 3: echo "enviado a $(wc -l <<<"$panes") paneles de $window"
echo "broadcast.sh: sin implementar ($window: $cmd)" >&2
