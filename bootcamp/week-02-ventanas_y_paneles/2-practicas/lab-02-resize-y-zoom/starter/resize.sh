#!/usr/bin/env bash
# Lab 02 — ajusta el ancho de un panel a un porcentaje de la ventana.
# Uso: resize.sh PANEL PORCENTAJE      (p. ej. resize.sh medidas:0.0 25)
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

pane="${1:?uso: resize.sh PANEL PORCENTAJE}"
percent="${2:?uso: resize.sh PANEL PORCENTAJE}"

# TODO 1: si el porcentaje no es un número entre 10 y 90 (ambos incluidos),
#         avisa por stderr y sal con 2. Pista:
#         if ! [[ "$percent" =~ ^[0-9]+$ ]] || (( percent < 10 || percent > 90 )); then

# TODO 2: ajusta el ancho: tmx resize-pane -t "$pane" -x "${percent}%"

# TODO 3: imprime "<panel> mide <pane_width> de <window_width> columnas (<porcentaje> %)"
#         con tmx display-message -p -t "$pane" "... #{pane_width} ... #{window_width} ...".
echo "resize.sh: sin implementar ($pane $percent)" >&2
