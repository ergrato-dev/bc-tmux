#!/usr/bin/env bash
# Lab 05 — envía un comando a todos los paneles de una ventana.
# Uso: difundir.sh VENTANA COMANDO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

ventana="${1:?uso: difundir.sh VENTANA COMANDO}"
comando="${2:?uso: difundir.sh VENTANA COMANDO}"

paneles=$(tmx list-panes -t "$ventana" -F '#{pane_id}')

while IFS= read -r panel; do
  # -l: el comando llega como texto, nunca como nombres de tecla. "--" evita
  # que un comando que empiece por "-" se lea como opción de send-keys.
  # Enter va aparte: es la única tecla que el script quiere pulsar.
  tmx send-keys -t "$panel" -l -- "$comando"
  tmx send-keys -t "$panel" Enter
done <<<"$paneles"

echo "enviado a $(wc -l <<<"$paneles") paneles de $ventana"
