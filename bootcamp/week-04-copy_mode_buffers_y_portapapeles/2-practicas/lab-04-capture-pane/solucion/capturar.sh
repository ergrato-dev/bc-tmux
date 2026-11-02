#!/usr/bin/env bash
# Lab 04 — vuelca el historial completo de un panel, sin las líneas vacías
# de debajo del cursor (SOLUCIÓN).
# Uso: capturar.sh TARGET [ARCHIVO]     (sin ARCHIVO, a stdout)
# Salida: 0 capturado, 1 el panel no existe.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: capturar.sh TARGET [ARCHIVO]}"
archivo="${2:-}"

# display-message con un target que no existe usa otro panel y sale con 0:
# capturaríamos el panel equivocado sin enterarnos. list-panes sí falla.
if ! tmx list-panes -t "$target" >/dev/null 2>&1; then
  echo "capturar.sh: no existe el panel $target" >&2
  exit 1
fi

# -E cuenta desde la primera línea visible (0): parar en la del cursor deja
# fuera las líneas vacías que quedan debajo del prompt.
fin=$(tmx display -p -t "$target" '#{cursor_y}')

# -S -: desde el principio del historial. -J: une las líneas que la pantalla
# partió por ancho, para que grep encuentre la línea entera.
tmx capture-pane -p -J -S - -E "$fin" -t "$target" >"${archivo:-/dev/stdout}"

if [[ -n "$archivo" ]]; then
  echo "capturadas $(wc -l <"$archivo") líneas en $archivo" >&2
fi
