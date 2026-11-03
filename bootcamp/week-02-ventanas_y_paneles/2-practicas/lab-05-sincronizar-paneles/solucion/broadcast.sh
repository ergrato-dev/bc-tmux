#!/usr/bin/env bash
# Lab 05 — envía un comando a todos los paneles de una ventana.
# Uso: broadcast.sh VENTANA COMANDO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

window="${1:?uso: broadcast.sh VENTANA COMANDO}"
cmd="${2:?uso: broadcast.sh VENTANA COMANDO}"

panes=$(tmx list-panes -t "$window" -F '#{pane_id}')

while IFS= read -r pane; do
  # -l: el comando llega como texto, nunca como nombres de tecla. "--" evita
  # que un comando que empiece por "-" se lea como opción de send-keys.
  # Enter va aparte: es la única tecla que el script quiere pulsar.
  tmx send-keys -t "$pane" -l -- "$cmd"
  tmx send-keys -t "$pane" Enter
done <<<"$panes"

echo "enviado a $(wc -l <<<"$panes") paneles de $window"
