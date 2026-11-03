#!/usr/bin/env bash
# Lab 06 — te lleva a la sesión del proyecto DIR, creándola si no existe.
# Este script tiene CUATRO errores. Encuéntralos (README.md).
# Uso: project.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: project.sh DIR}"
name=$(basename "$dir")

if ! tmx ls 2>/dev/null | grep -q "$name"; then
  tmx new-session -d -s "$name" -c "$dir"
fi

tmx attach-session -t "$name"
