#!/usr/bin/env bash
# Lab 02 — ajusta el ancho de un panel a un porcentaje de la ventana.
# Uso: resize.sh PANEL PORCENTAJE      (p. ej. resize.sh medidas:0.0 25)
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

pane="${1:?uso: resize.sh PANEL PORCENTAJE}"
percent="${2:?uso: resize.sh PANEL PORCENTAJE}"

if ! [[ "$percent" =~ ^[0-9]+$ ]] || (( percent < 10 || percent > 90 )); then
  echo "el porcentaje debe ser un número entre 10 y 90: '$percent'" >&2
  exit 2
fi

# list-panes falla si el panel no existe; display-message no.
tmx list-panes -t "$pane" >/dev/null

tmx resize-pane -t "$pane" -x "${percent}%"
tmx display-message -p -t "$pane" \
  "$pane mide #{pane_width} de #{window_width} columnas ($percent %)"
