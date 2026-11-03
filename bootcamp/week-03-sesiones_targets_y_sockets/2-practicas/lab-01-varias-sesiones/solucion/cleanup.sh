#!/usr/bin/env bash
# Lab 01 — cierra las sesiones sin clientes cuyo nombre empieza por PREFIJO.
# Uso: cleanup.sh PREFIJO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

prefix="${1:?uso: cleanup.sh PREFIJO}"

# Se lee la lista entera antes de cerrar nada: así no se recorre una lista
# que cambia mientras se cierran sesiones.
sessions=$(tmx list-sessions -F '#{session_name} #{session_attached}')

while read -r name clients; do
  # Las comillas en "$prefix" hacen que * o ? del prefijo sean literales.
  if [[ "$name" == "$prefix"* ]] && (( clients == 0 )); then
    # "=": sin él, cerrar "tmp-1" ya cerrada podría cerrar "tmp-10".
    tmx kill-session -t "=$name"
    echo "cerrada: $name"
  fi
done <<<"$sessions"

echo "quedan: $(tmx list-sessions -F '#{session_name}' 2>/dev/null | paste -sd' ' -)"
