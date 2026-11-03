#!/usr/bin/env bash
# Lab 05 — envía un comando a todos los paneles de una ventana.
# Uso: difundir.sh VENTANA COMANDO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

ventana="${1:?uso: difundir.sh VENTANA COMANDO}"
comando="${2:?uso: difundir.sh VENTANA COMANDO}"

# TODO 1: guarda los ids de panel de la ventana (uno por línea):
#         paneles=$(tmx list-panes -t "$ventana" -F '#{pane_id}')

# TODO 2: recorre los ids y en cada panel escribe el comando como texto
#         literal (-l; "--" por si empieza por "-") y pulsa Enter aparte:
#         while IFS= read -r panel; do
#           tmx send-keys -t "$panel" -l -- "$comando"
#           tmx send-keys -t "$panel" Enter
#         done <<<"$paneles"

# TODO 3: echo "enviado a $(wc -l <<<"$paneles") paneles de $ventana"
echo "difundir.sh: sin implementar ($ventana: $comando)" >&2
