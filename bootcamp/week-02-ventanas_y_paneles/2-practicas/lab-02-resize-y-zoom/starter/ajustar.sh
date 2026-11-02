#!/usr/bin/env bash
# Lab 02 — ajusta el ancho de un panel a un porcentaje de la ventana.
# Uso: ajustar.sh PANEL PORCENTAJE      (p. ej. ajustar.sh medidas:0.0 25)
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

panel="${1:?uso: ajustar.sh PANEL PORCENTAJE}"
porcentaje="${2:?uso: ajustar.sh PANEL PORCENTAJE}"

# TODO 1: si el porcentaje no es un número entre 10 y 90, avisa por stderr y sal con 2.

# TODO 2: resize-pane -t "$panel" -x "${porcentaje}%"

# TODO 3: imprime "<panel> mide <pane_width> de <window_width> columnas (<porcentaje> %)"
#         con display-message -p -t "$panel".
echo "ajustar.sh: sin implementar ($panel $porcentaje)" >&2
