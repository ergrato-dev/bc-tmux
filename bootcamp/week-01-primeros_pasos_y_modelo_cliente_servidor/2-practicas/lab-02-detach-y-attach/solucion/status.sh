#!/usr/bin/env bash
# Lab 02 — cuántos clientes mira cada sesión del servidor "lab".
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

# #{session_attached} cuenta los clientes conectados a la sesión.
tmx list-sessions -F '#{session_name}: #{session_attached} clientes'
