#!/usr/bin/env bash
# Lab 06 — lanza long-task.sh en una sesión en segundo plano.
# Uso: launch.sh <log> [segundos]
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

log="${1:?uso: launch.sh <log> [segundos]}"
seconds="${2:-0}"
task="$(cd "$(dirname "$0")" && pwd)/long-task.sh"

# TODO 1: crea la sesión "larga" en segundo plano. Lo que va tras las opciones
#         es el programa de la ventana: pásalo como argumentos separados,
#           tmx new-session -d -s larga "$task" "$log" "$seconds"
#         y borra las dos últimas líneas de este archivo (echo y exit 1).

# TODO 2: imprime cómo volver a la sesión:
#         tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
echo "launch.sh: sin implementar ($task $log $seconds)" >&2
exit 1
