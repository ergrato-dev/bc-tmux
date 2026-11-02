#!/usr/bin/env bash
# Lab 02 — dice a qué sesión, ventana y panel apunta un target.
# Uso: resolver.sh TARGET
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: resolver.sh TARGET}"

# TODO 1: valida el target con list-panes -t (display-message no falla);
#         si no existe: "resolver.sh: no existe el target '...'" y sale con 1.
# TODO 2: imprime con display-message -p -t "$target":
#         "sesion:ventana.panel  sesión $N  ventana @N  panel %N"
echo "resolver.sh: sin implementar ($target)" >&2
