#!/usr/bin/env bash
# Lab 02 — dice a qué sesión, ventana y panel apunta un target.
# Uso: resolve.sh TARGET
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: resolve.sh TARGET}"

# TODO 1: si el target no existe, avisa por stderr y sal con 1 (README, paso 8).
# TODO 2: imprime posición e ids de sesión, ventana y panel (paso 9).

# Borra esta línea al empezar:
echo "resolve.sh: sin implementar ($target)" >&2
