#!/usr/bin/env bash
# Lab 03 — guarda cada buffer de tmux en DIR/NOMBRE.txt.
# Uso: guardar-buffers.sh DIR
# Salida: 0 si guardó al menos uno, 1 si no hay servidor o no hay buffers.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: guardar-buffers.sh DIR}"

# TODO 1: lee tamaño y nombre de cada buffer en una variable:
#           lista=$(tmx list-buffers -F '#{buffer_size} #{buffer_name}' 2>/dev/null) || true
#         Sin servidor, list-buffers falla; sin buffers, sale vacío. En los
#         dos casos ([[ -z "$lista" ]]) imprime por stderr
#         "guardar-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)"
#         y sal con 1.

# TODO 2: borra las dos líneas "sin implementar" de abajo. Crea "$dir" con
#         mkdir -p y recorre la lista con  while read -r bytes nombre; do ...
#         done <<<"$lista"  (el nombre va al final: read le deja el resto
#         de la línea, aunque tenga espacios). Por cada uno:
#           tmx save-buffer -b "$nombre" "$dir/${nombre//\//_}.txt"
#         (${nombre//\//_} cambia cada "/" por "_").

# TODO 3: dentro del bucle, imprime "guardado: NOMBRE (N bytes)".
echo "guardar-buffers.sh: sin implementar ($dir)" >&2
exit 1
