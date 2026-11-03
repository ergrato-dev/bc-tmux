#!/usr/bin/env bash
# Lab 01 — crea la sesión "primera" en segundo plano y lista las sesiones.
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

tmx new-session -d -s primera -n inicio
tmx ls
