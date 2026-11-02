#!/usr/bin/env bash
# Lab 06 — lanza tarea-larga.sh en una sesión en segundo plano.
# Uso: lanzar.sh <log> [segundos]
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

log="${1:?uso: lanzar.sh <log> [segundos]}"
segundos="${2:-0}"
tarea="$(cd "$(dirname "$0")" && pwd)/tarea-larga.sh"

# Con varios argumentos tras las opciones, tmux ejecuta el programa sin pasar
# por una shell: una ruta con espacios no se rompe. Cuando el programa
# termine, el panel se cierra con él.
tmx new-session -d -s larga "$tarea" "$log" "$segundos"

echo "tarea lanzada en la sesión \"larga\"; vuelve con: tmux -L ${TMUX_SOCKET:-lab} attach -t larga"
