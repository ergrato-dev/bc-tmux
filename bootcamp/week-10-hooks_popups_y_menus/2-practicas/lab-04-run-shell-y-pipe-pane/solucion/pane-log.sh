#!/usr/bin/env bash
# pane-log.sh — activa o desactiva el log de un panel con pipe-pane -o.
#
# Uso: pane-log.sh PANE      (p. ej. %0)
#      TMUX_SOCKET=lab ./solucion/pane-log.sh %0
# Log: ${LAB_LOG_DIR:-/tmp/lab10/logs}/SESION-VENTANA-PANEL.log
# Salida: 0 bien, 1 el panel no existe, 2 uso incorrecto.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

(( $# == 1 )) || { echo "uso: pane-log.sh PANE" >&2; exit 2; }
pane=$1

# display -p -t no falla con un panel que no existe: list-panes sí.
tmx list-panes -t "$pane" >/dev/null 2>&1 || { echo "pane-log: no existe el panel '$pane'" >&2; exit 1; }

dir=${LAB_LOG_DIR:-/tmp/lab10/logs}
mkdir -p -- "$dir"
file="$dir/$(tmx display -p -t "$pane" '#{session_name}-#{window_index}-#{pane_index}').log"

# tmux expande el comando como format (## para cada #) y luego lo lee sh
# (%q): una sesión llamada "a b;c" no parte la ruta ni ejecuta nada.
quoted=$(printf '%q' "$file")
tmx pipe-pane -o -t "$pane" "cat >> ${quoted//#/##}"

if [[ $(tmx display -p -t "$pane" '#{pane_pipe}') == 1 ]]; then
  echo "log on: $file"
else
  echo "log off: $file"
fi
