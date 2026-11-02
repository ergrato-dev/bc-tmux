#!/usr/bin/env bash
# Lab 01 — cierra las sesiones sin clientes cuyo nombre empieza por PREFIJO.
# Uso: limpiar.sh PREFIJO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

prefijo="${1:?uso: limpiar.sh PREFIJO}"

# TODO 1: recorre list-sessions -F '#{session_name} #{session_attached}'.
# TODO 2: si el nombre empieza por "$prefijo" ([[ $nombre == "$prefijo"* ]])
#         y no tiene clientes, kill-session -t "=$nombre" y echo "cerrada: ...".
# TODO 3: imprime "quedan: " y los nombres que quedan en una línea.
echo "limpiar.sh: sin implementar ($prefijo)" >&2
