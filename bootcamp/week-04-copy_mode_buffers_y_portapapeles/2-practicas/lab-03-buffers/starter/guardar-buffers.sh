#!/usr/bin/env bash
# Lab 03 — guarda cada buffer de tmux en DIR/NOMBRE.txt.
# Uso: guardar-buffers.sh DIR
# Salida: 0 si guardó al menos uno, 1 si no hay servidor o no hay buffers.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: guardar-buffers.sh DIR}"

# TODO 1: lee tamaño y nombre de cada buffer con
#         list-buffers -F '#{buffer_size} #{buffer_name}'.
#         Si falla (no hay servidor) o sale vacío, avisa por stderr y sal con 1.
# TODO 2: crea "$dir" y, por cada buffer, save-buffer -b "$nombre" en
#         "$dir/NOMBRE.txt". Un nombre puede tener "/": cámbiala por "_".
# TODO 3: imprime "guardado: NOMBRE (N bytes)" por cada uno.
echo "guardar-buffers.sh: sin implementar ($dir)" >&2
exit 1
