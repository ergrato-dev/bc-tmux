#!/usr/bin/env bash
# Lab 03 — guarda cada buffer de tmux en DIR/NOMBRE.txt.
# Uso: save-buffers.sh DIR
# Salida: 0 si guardó al menos uno, 1 si no hay servidor o no hay buffers.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: save-buffers.sh DIR}"

# TODO 1: lee tamaño y nombre de cada buffer en una variable:
#           list=$(tmx list-buffers -F '#{buffer_size} #{buffer_name}' 2>/dev/null) || true
#         Sin servidor, list-buffers falla; sin buffers, sale vacío. En los
#         dos casos ([[ -z "$list" ]]) imprime por stderr
#         "save-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)"
#         y sal con 1.

# TODO 2: borra las dos líneas "sin implementar" de abajo. Crea "$dir" con
#         mkdir -p y recorre la lista con  while read -r bytes name; do ...
#         done <<<"$list"  (el nombre va al final: read le deja el resto
#         de la línea, aunque tenga espacios). Por cada uno:
#           tmx save-buffer -b "$name" "$dir/${name//\//_}.txt"
#         (${name//\//_} cambia cada "/" por "_").

# TODO 3: dentro del bucle, imprime "guardado: NOMBRE (N bytes)".
echo "save-buffers.sh: sin implementar ($dir)" >&2
exit 1
