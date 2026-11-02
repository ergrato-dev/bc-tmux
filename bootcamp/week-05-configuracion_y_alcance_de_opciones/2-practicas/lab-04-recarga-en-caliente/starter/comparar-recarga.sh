#!/usr/bin/env bash
# Lab 04 — comprueba que recargar una config dos veces da el mismo estado.
# Uso: comparar-recarga.sh CONF
# Salida: 0 idéntico, 1 la segunda recarga cambia algo (y lo muestra).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

conf="${1:?uso: comparar-recarga.sh CONF}"

# TODO 1: si no hay servidor (list-sessions falla), avisa y sal con 1.
# TODO 2: función estado: show -s, show -g, show -gw y list-keys.
# TODO 3: recarga una vez, guarda el estado; recarga otra, guarda el estado.
#         La primera recarga es la referencia: arrancar y recargar pueden
#         diferir con razón; recargar y recargar, no.
# TODO 4: si son iguales, "idéntico: recargar CONF no cambia nada"; si no,
#         muestra el diff y sal con 1.
echo "comparar-recarga.sh: sin implementar ($conf)" >&2
exit 1
