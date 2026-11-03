#!/usr/bin/env bash
# Lab 02 — cuántos clientes mira cada sesión del servidor "lab".
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

# TODO: una línea por sesión con el formato  <nombre>: <n> clientes
#       tmx list-sessions -F '...'  con #{session_name} y #{session_attached}
