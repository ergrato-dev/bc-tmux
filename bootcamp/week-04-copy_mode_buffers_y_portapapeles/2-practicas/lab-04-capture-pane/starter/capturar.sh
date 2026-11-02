#!/usr/bin/env bash
# Lab 04 — vuelca el historial completo de un panel, sin las líneas vacías
# de debajo del cursor.
# Uso: capturar.sh TARGET [ARCHIVO]     (sin ARCHIVO, a stdout)
# Salida: 0 capturado, 1 el panel no existe.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: capturar.sh TARGET [ARCHIVO]}"
archivo="${2:-}"

# TODO 1: valida el target con list-panes -t (display-message no falla si
#         no existe). Si no existe: "capturar.sh: no existe el panel TARGET"
#         por stderr y sale con 1.
# TODO 2: lee la línea del cursor con display -p -t "$target" '#{cursor_y}'.
# TODO 3: capture-pane -p -J -S - -E "$fin" -t "$target", a "$archivo" si lo
#         hay (y di por stderr "capturadas N líneas en ARCHIVO") o a stdout.
echo "capturar.sh: sin implementar ($target ${archivo:-stdout})" >&2
exit 1
