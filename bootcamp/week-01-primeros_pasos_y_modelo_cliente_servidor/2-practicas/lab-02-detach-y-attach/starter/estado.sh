#!/usr/bin/env bash
# Lab 02 — cuántos clientes mira cada sesión del servidor "lab".
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO: usa tmx list-sessions -F con #{session_name} y #{session_attached}
#       para imprimir una línea por sesión:  <nombre>: <n> clientes
