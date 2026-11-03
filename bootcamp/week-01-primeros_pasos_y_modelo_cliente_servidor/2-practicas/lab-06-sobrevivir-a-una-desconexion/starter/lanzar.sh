#!/usr/bin/env bash
# Lab 06 — lanza tarea-larga.sh en una sesión en segundo plano.
# Uso: lanzar.sh <log> [segundos]
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

log="${1:?uso: lanzar.sh <log> [segundos]}"
segundos="${2:-0}"
tarea="$(cd "$(dirname "$0")" && pwd)/tarea-larga.sh"

# TODO 1: crea la sesión "larga" en segundo plano. Lo que va tras las opciones
#         es el programa de la ventana: pásalo como argumentos separados,
#           tmx new-session -d -s <sesión> "$tarea" "$log" "$segundos"
#         y borra las dos últimas líneas de este archivo (echo y exit 1).

# TODO 2: imprime cómo volver a la sesión:
#         tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
echo "lanzar.sh: sin implementar ($tarea $log $segundos)" >&2
exit 1
