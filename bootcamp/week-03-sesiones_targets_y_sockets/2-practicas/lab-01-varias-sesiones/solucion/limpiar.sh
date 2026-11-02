#!/usr/bin/env bash
# Lab 01 — cierra las sesiones sin clientes cuyo nombre empieza por PREFIJO.
# Uso: limpiar.sh PREFIJO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

prefijo="${1:?uso: limpiar.sh PREFIJO}"

# Se lee la lista entera antes de cerrar nada: así no se recorre una lista
# que cambia mientras se cierran sesiones.
sesiones=$(tmx list-sessions -F '#{session_name} #{session_attached}')

while read -r nombre clientes; do
  # Las comillas en "$prefijo" hacen que * o ? del prefijo sean literales.
  if [[ "$nombre" == "$prefijo"* ]] && (( clientes == 0 )); then
    # "=": sin él, cerrar "tmp-1" ya cerrada podría cerrar "tmp-10".
    tmx kill-session -t "=$nombre"
    echo "cerrada: $nombre"
  fi
done <<<"$sesiones"

echo "quedan: $(tmx list-sessions -F '#{session_name}' 2>/dev/null | paste -sd' ' -)"
