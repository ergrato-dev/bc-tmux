#!/usr/bin/env bash
# Lab 04 — crea BASE-espejo en el grupo de BASE (si no existe).
# Uso: mirror.sh BASE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

base="${1:?uso: mirror.sh BASE}"
mirror="$base-espejo"

# TODO 1: si la base no existe, avisa por stderr y sal con 1 (README, paso 7).
# TODO 2: crea "$mirror" en el grupo de la base solo si no existe (paso 8).
# TODO 3: imprime el grupo y sus miembros (paso 9).

# Borra esta línea al empezar:
echo "mirror.sh: sin implementar ($base, $mirror)" >&2
