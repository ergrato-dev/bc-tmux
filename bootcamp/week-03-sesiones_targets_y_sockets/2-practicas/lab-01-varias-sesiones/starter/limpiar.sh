#!/usr/bin/env bash
# Lab 01 — cierra las sesiones sin clientes cuyo nombre empieza por PREFIJO.
# Uso: limpiar.sh PREFIJO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

prefijo="${1:?uso: limpiar.sh PREFIJO}"

# TODO 1: guarda en "sesiones" el nombre y los clientes de cada sesión (README, paso 10).
# TODO 2: cierra las que empiezan por "$prefijo" y no tienen clientes (paso 11).
# TODO 3: imprime "quedan: " con los nombres que siguen vivos (paso 12).

# Borra esta línea al empezar:
echo "limpiar.sh: sin implementar ($prefijo)" >&2
