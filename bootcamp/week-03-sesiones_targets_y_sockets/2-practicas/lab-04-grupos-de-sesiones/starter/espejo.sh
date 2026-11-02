#!/usr/bin/env bash
# Lab 04 — crea BASE-espejo en el grupo de BASE (si no existe).
# Uso: espejo.sh BASE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

base="${1:?uso: espejo.sh BASE}"
espejo="$base-espejo"

# TODO 1: si la base no existe (has-session -t "=$base"), avisa y sal con 1.
# TODO 2: si ya existe "$espejo": "ya existe: ..."; si no, créala en el grupo
#         (new-session -d -t "=$base" -s "$espejo") y "creada: ...".
# TODO 3: "grupo <grupo>: <miembros>" con #{session_group} y
#         #{session_group_list} de la base.
echo "espejo.sh: sin implementar ($base, $espejo)" >&2
