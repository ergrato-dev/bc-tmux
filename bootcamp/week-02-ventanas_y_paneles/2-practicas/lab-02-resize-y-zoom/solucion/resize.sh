#!/usr/bin/env bash
# Lab 02 — ajusta el ancho de un panel a un porcentaje de la ventana.
# Uso: ajustar.sh PANEL PORCENTAJE      (p. ej. ajustar.sh medidas:0.0 25)
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

panel="${1:?uso: ajustar.sh PANEL PORCENTAJE}"
porcentaje="${2:?uso: ajustar.sh PANEL PORCENTAJE}"

if ! [[ "$porcentaje" =~ ^[0-9]+$ ]] || (( porcentaje < 10 || porcentaje > 90 )); then
  echo "el porcentaje debe ser un número entre 10 y 90: '$porcentaje'" >&2
  exit 2
fi

# list-panes falla si el panel no existe; display-message no.
tmx list-panes -t "$panel" >/dev/null

tmx resize-pane -t "$panel" -x "${porcentaje}%"
tmx display-message -p -t "$panel" \
  "$panel mide #{pane_width} de #{window_width} columnas ($porcentaje %)"
