#!/usr/bin/env bash
# Lab 06 — lanza long-task.sh en una sesión en segundo plano.
# Uso: launch.sh <log> [segundos]
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

log="${1:?uso: launch.sh <log> [segundos]}"
seconds="${2:-0}"
task="$(cd "$(dirname "$0")" && pwd)/long-task.sh"

# Con varios argumentos tras las opciones, tmux ejecuta el programa sin pasar
# por una shell: una ruta con espacios no se rompe. Cuando el programa
# termine, el panel se cierra con él.
tmx new-session -d -s larga "$task" "$log" "$seconds"

echo "tarea lanzada en la sesión \"larga\"; vuelve con: tmux -L ${TMUX_SOCKET:-lab} attach -t larga"
