#!/usr/bin/env bash
# Lab 04 — vuelca el historial completo de un panel, sin las líneas vacías
# de debajo del cursor.
# Uso: capturar.sh TARGET [ARCHIVO]     (sin ARCHIVO, a stdout)
# Salida: 0 capturado, 1 el panel no existe.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: capturar.sh TARGET [ARCHIVO]}"
archivo="${2:-}"

# TODO 1: valida el target con list-panes (display-message no falla si no
#         existe). Si no existe, "capturar.sh: no existe el panel TARGET" por
#         stderr y sal con 1.
#         Pista: if ! tmx list-panes -t "$target" >/dev/null 2>&1; then ... fi

# TODO 2: lee la línea del cursor (0 = primera línea visible):
#           fin=$(tmx display -p -t "$target" '#{cursor_y}')

# TODO 3: borra las dos líneas "sin implementar" de abajo. Captura desde el
#         principio del historial (-S -) hasta la línea del cursor (-E "$fin"),
#         uniendo las líneas partidas (-J):
#           tmx capture-pane -p -J -S - -E "$fin" -t "$target" >"${archivo:-/dev/stdout}"
#         Si hay archivo, di por stderr cuántas líneas tiene:
#           echo "capturadas $(wc -l <"$archivo") líneas en $archivo" >&2
echo "capturar.sh: sin implementar ($target ${archivo:-stdout})" >&2
exit 1
