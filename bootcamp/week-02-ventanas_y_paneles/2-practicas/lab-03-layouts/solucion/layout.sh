#!/usr/bin/env bash
# Lab 03 — guarda y restaura el layout de una ventana.
# Uso: layout.sh save VENTANA ARCHIVO
#      layout.sh load VENTANA ARCHIVO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

action="${1:?uso: layout.sh save|load VENTANA ARCHIVO}"
window="${2:?falta la ventana}"
file="${3:?falta el archivo}"

# display-message no falla si la ventana no existe; list-panes sí.
tmx list-panes -t "$window" >/dev/null

case "$action" in
  save)
    tmx display-message -p -t "$window" '#{window_layout}' >"$file"
    echo "guardado en $file"
    ;;
  load)
    tmx select-layout -t "$window" "$(<"$file")"
    echo "restaurado desde $file"
    ;;
  *)
    echo "acción desconocida: $action" >&2
    exit 2
    ;;
esac
