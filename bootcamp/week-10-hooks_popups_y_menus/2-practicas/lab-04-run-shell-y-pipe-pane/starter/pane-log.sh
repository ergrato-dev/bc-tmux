#!/usr/bin/env bash
# pane-log.sh — activa o desactiva el log de un panel con pipe-pane -o.
#
# Uso: pane-log.sh PANE      (p. ej. %0)
#      TMUX_SOCKET=lab ./starter/pane-log.sh %0
# Log: ${LAB_LOG_DIR:-/tmp/lab10/logs}/SESION-VENTANA-PANEL.log
# Salida: 0 bien, 1 el panel no existe, 2 uso incorrecto.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

(( $# == 1 )) || { echo "uso: pane-log.sh PANE" >&2; exit 2; }
pane=$1

# TODO 1: valida el panel con list-panes -t, que falla si no existe
# (display -p -t no falla: sale con 0 y usa otro panel):
#   tmx list-panes -t "$pane" >/dev/null 2>&1 || { echo "pane-log: no existe el panel '$pane'" >&2; exit 1; }

dir=${LAB_LOG_DIR:-/tmp/lab10/logs}
mkdir -p -- "$dir"
file="$dir/$(tmx display -p -t "$pane" '#{session_name}-#{window_index}-#{pane_index}').log"

# TODO 2: abre el pipe, o lo cierra si ya estaba abierto (-o). El comando
# pasa por dos lectores: tmux lo expande como format (# -> ##) y luego sh
# (espacios, ; y $ -> printf %q). Cambia la línea de abajo por:
#   quoted=$(printf '%q' "$file")
#   tmx pipe-pane -o -t "$pane" "cat >> ${quoted//#/##}"
echo "pane-log: sin implementar ($file)"

# TODO 3: informa del estado con #{pane_pipe} (1 abierto, 0 cerrado):
#   if [[ $(tmx display -p -t "$pane" '#{pane_pipe}') == 1 ]]; then
#     echo "log on: $file"
#   else
#     echo "log off: $file"
#   fi
