#!/usr/bin/env bash
# Lab 02 — cuántos clientes mira cada sesión del servidor "lab".
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# #{session_attached} cuenta los clientes conectados a la sesión.
tmx list-sessions -F '#{session_name}: #{session_attached} clientes'
