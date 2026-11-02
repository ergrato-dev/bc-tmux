#!/usr/bin/env bash
# Lab 03 — salta a una sesión, dentro o fuera de tmux.
# Uso: saltar.sh NOMBRE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

nombre="${1:?uso: saltar.sh NOMBRE}"

# TODO 1: si no existe la sesión exacta (has-session -t "=$nombre"), avisa
#         por stderr y sal con 1.
# TODO 2: dentro de tmux ($TMUX no vacío) switch-client -t "=$nombre";
#         fuera, attach-session -t "=$nombre".
echo "saltar.sh: sin implementar ($nombre)" >&2
