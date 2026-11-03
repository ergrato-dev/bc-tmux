#!/usr/bin/env bash
# popup-info.sh — pensado para un popup: dónde estás y una tecla para cerrar.
#
# Uso: popup-info.sh   (desde un binding con display-popup -E)
# Prueba fuera de un popup: echo | TMUX_SOCKET=lab ./starter/popup-info.sh
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

# TODO 3: imprime sesión, ventana y panel con display -p. Dentro del popup
# $TMUX apunta al servidor del lab, así que tmx no necesita -L:
#   tmx display -p 'sesión #{session_name}, ventana #{window_index}, panel #{pane_id}'
# y borra la línea de abajo.
echo "sin implementar"
echo "directorio: $PWD"
# -s: no muestra la tecla; -n1: basta una. Sin esta línea, -E cerraría el
# popup antes de que pudieras leerlo.
read -rsn1 -p "pulsa una tecla para cerrar"
