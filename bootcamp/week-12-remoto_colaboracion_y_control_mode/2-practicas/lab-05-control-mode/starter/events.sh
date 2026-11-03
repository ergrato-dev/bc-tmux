#!/usr/bin/env bash
# events.sh — escucha una sesión en control mode y traduce sus eventos.
#
# Uso: TMUX_SOCKET=cm ./starter/events.sh SESION SEGUNDOS
# Probar (desde la carpeta del lab, con el servidor del paso 0):
#   TMUX_SOCKET=cm ./starter/events.sh cm 5 &
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

# a y b quedan sin usar hasta los TODO 2 y 3:
# shellcheck disable=SC2034
# TODO 1: conecta en control mode y pasa cada línea al bucle. Con la entrada
# cerrada, tmux -C sale en cuanto conecta: alimenta su entrada con
# sleep "$secs" y envuélvelo en timeout "$((secs + 2))" como seguro.
# timeout no ejecuta funciones: escribe el comando entero.
#   sleep "$secs" |
#     timeout "$((secs + 2))" "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} -C attach -t "=$session" |
# Borra el echo de abajo.
echo "sin implementar ($secs s)" |
  while read -r kind a b _; do
    case $kind in
      # TODO 2: %window-add @ID     -> echo "ventana nueva: $a"
      #         %window-close @ID   -> echo "ventana cerrada: $a"
      #           (y %unlinked-window-close, la de otra sesión: mismo texto)
      #         %window-renamed @ID NOMBRE -> echo "ventana $a renombrada: $b"

      # TODO 3: %session-renamed $ID NOMBRE -> echo "sesión renombrada: $b"
      #         %exit                       -> echo "fin del control mode"

      # %begin/%end, %output y el resto: este script no los necesita.
      *) ;;
    esac
  done
