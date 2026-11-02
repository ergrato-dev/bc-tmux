#!/usr/bin/env bash
# Lab 06 — lanza tarea-larga.sh en una sesión en segundo plano.
# Uso: lanzar.sh <log> [segundos]
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

log="${1:?uso: lanzar.sh <log> [segundos]}"
segundos="${2:-0}"
tarea="$(cd "$(dirname "$0")" && pwd)/tarea-larga.sh"

# TODO 1: crea la sesión "larga" en segundo plano. El último argumento de
#         new-session es el programa de la ventana: pásale "$tarea" "$log" "$segundos"
#         como argumentos separados, no como un texto con espacios.

# TODO 2: imprime cómo volver a la sesión:
#         tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
echo "lanzar.sh: sin implementar ($tarea $log $segundos)" >&2
exit 1
