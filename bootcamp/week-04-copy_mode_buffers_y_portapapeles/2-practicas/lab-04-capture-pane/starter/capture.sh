#!/usr/bin/env bash
# Lab 04 — vuelca el historial completo de un panel, sin las líneas vacías
# de debajo del cursor.
# Uso: capture.sh TARGET [ARCHIVO]     (sin ARCHIVO, a stdout)
# Salida: 0 capturado, 1 el panel no existe.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: capture.sh TARGET [ARCHIVO]}"
file="${2:-}"

# TODO 1: valida el target con list-panes (display-message no falla si no
#         existe). Si no existe, "capture.sh: no existe el panel TARGET" por
#         stderr y sal con 1.
#         Pista: if ! tmx list-panes -t "$target" >/dev/null 2>&1; then ... fi

# TODO 2: lee la línea del cursor (0 = primera línea visible):
#           end=$(tmx display -p -t "$target" '#{cursor_y}')

# TODO 3: borra las dos líneas "sin implementar" de abajo. Captura desde el
#         principio del historial (-S -) hasta la línea del cursor (-E "$end"),
#         uniendo las líneas partidas (-J):
#           tmx capture-pane -p -J -S - -E "$end" -t "$target" >"${file:-/dev/stdout}"
#         Si hay archivo, di por stderr cuántas líneas tiene:
#           echo "capturadas $(wc -l <"$file") líneas en $file" >&2
echo "capture.sh: sin implementar ($target ${file:-stdout})" >&2
exit 1
