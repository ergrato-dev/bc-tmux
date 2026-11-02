#!/usr/bin/env bash
# Lab 06 — te lleva a la sesión del proyecto DIR, creándola si no existe.
# Este script tiene CUATRO errores. Encuéntralos (README.md).
# Uso: proyecto.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: proyecto.sh DIR}"
nombre=$(basename "$dir")

if ! tmx ls 2>/dev/null | grep -q "$nombre"; then
  tmx new-session -d -s "$nombre" -c "$dir"
fi

tmx attach-session -t "$nombre"
