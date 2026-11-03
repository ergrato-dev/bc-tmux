#!/usr/bin/env bash
# Lab 04 — comprueba que recargar una config dos veces da el mismo estado.
# Uso: comparar-recarga.sh CONF
# Salida: 0 idéntico, 1 la segunda recarga cambia algo (y lo muestra).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

conf="${1:?uso: comparar-recarga.sh CONF}"

# TODO 1: si no hay servidor (tmx list-sessions falla), imprime por stderr
#         "comparar-recarga.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}"
#         y sal con 1.
# TODO 2: función estado: tmx show -s; tmx show -g; tmx show -gw; tmx list-keys.
# TODO 3: tmx source-file "$conf"; antes=$(estado); otra vez source-file;
#         despues=$(estado). La primera recarga es la referencia: arrancar y
#         recargar pueden diferir con razón; recargar y recargar, no.
# TODO 4: si son iguales, "idéntico: recargar CONF no cambia nada"; si no,
#         diff <(printf '%s\n' "$antes") <(printf '%s\n' "$despues") || true
#         y exit 1. Borra las dos líneas de abajo.
echo "comparar-recarga.sh: sin implementar ($conf)" >&2
exit 1
