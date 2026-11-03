#!/usr/bin/env bash
# popup-info.sh — pensado para un popup: dónde estás y una tecla para cerrar.
#
# Uso: popup-info.sh   (desde un binding con display-popup -E)
# Prueba fuera de un popup: echo | TMUX_SOCKET=lab ./solucion/popup-info.sh
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

tmx display -p 'sesión #{session_name}, ventana #{window_index}, panel #{pane_id}'
echo "directorio: $PWD"
# Sin esta espera, -E cerraría el popup antes de que pudieras leerlo.
read -rsn1 -p "pulsa una tecla para cerrar"
