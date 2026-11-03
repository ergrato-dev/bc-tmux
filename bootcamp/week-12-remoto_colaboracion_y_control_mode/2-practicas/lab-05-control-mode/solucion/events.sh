#!/usr/bin/env bash
# events.sh — escucha una sesión en control mode y traduce sus eventos.
#
# Uso: TMUX_SOCKET=cm ./solucion/events.sh SESION SEGUNDOS
# Probar (desde la carpeta del lab, con el servidor del paso 0):
#   TMUX_SOCKET=cm ./solucion/events.sh cm 5 &
#   tmux -L cm new-window -n logs
# Salida: 0 al acabar el tiempo, 1 si la sesión no existe, 2 uso incorrecto.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

(( $# == 2 )) || { echo "uso: events.sh SESION SEGUNDOS" >&2; exit 2; }
session=$1
secs=$2

tmx has-session -t "=$session" 2>/dev/null || {
  echo "events.sh: no existe la sesión $session" >&2
  exit 1
}

# Con la entrada cerrada, tmux -C sale en cuanto conecta: sleep la mantiene
# abierta los segundos pedidos y al acabar tmux recibe EOF y se desconecta.
# timeout es el seguro por si no lo hace. timeout no ejecuta funciones: por
# eso se repite aquí lo que hace tmx.
sleep "$secs" |
  timeout "$((secs + 2))" "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} -C attach -t "=$session" |
  while read -r kind a b _; do
    case $kind in
      %window-add) echo "ventana nueva: $a" ;;
      %window-close | %unlinked-window-close) echo "ventana cerrada: $a" ;;
      %window-renamed) echo "ventana $a renombrada: $b" ;;
      %session-renamed) echo "sesión renombrada: $b" ;;
      %exit) echo "fin del control mode" ;;
      # %begin/%end, %output y el resto: este script no los necesita.
      *) ;;
    esac
  done
