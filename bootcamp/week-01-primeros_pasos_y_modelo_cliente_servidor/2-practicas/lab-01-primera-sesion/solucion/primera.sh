#!/usr/bin/env bash
# Lab 01 — crea la sesión "primera" en segundo plano y lista las sesiones.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

tmx new-session -d -s primera -n inicio
tmx ls
