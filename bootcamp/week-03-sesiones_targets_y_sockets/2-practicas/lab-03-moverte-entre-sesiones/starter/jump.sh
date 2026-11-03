#!/usr/bin/env bash
# Lab 03 — salta a una sesión, dentro o fuera de tmux.
# Uso: jump.sh NOMBRE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

name="${1:?uso: jump.sh NOMBRE}"

# TODO 1: si la sesión exacta no existe, avisa por stderr y sal con 1 (README, paso 9).
# TODO 2: dentro de tmux cambia el cliente actual; fuera, conecta uno (paso 10).

# Borra esta línea al empezar:
echo "jump.sh: sin implementar ($name)" >&2
