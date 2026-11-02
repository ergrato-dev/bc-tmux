#!/usr/bin/env bash
# Lab 05 — envía un comando a todos los paneles de una ventana.
# Uso: difundir.sh VENTANA COMANDO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

ventana="${1:?uso: difundir.sh VENTANA COMANDO}"
comando="${2:?uso: difundir.sh VENTANA COMANDO}"

# TODO: recorre los ids de panel de "$ventana" (list-panes -F '#{pane_id}')
#       y en cada uno: send-keys -t "$panel" -l -- "$comando" y después
#       send-keys -t "$panel" Enter.
echo "difundir.sh: sin implementar ($ventana: $comando)" >&2
