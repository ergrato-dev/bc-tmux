#!/usr/bin/env bash
# Lab 01 — cierra las sesiones sin clientes cuyo nombre empieza por PREFIJO.
# Uso: cleanup.sh PREFIJO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

prefix="${1:?uso: cleanup.sh PREFIJO}"

# TODO 1: guarda en "sessions" el nombre y los clientes de cada sesión (README, paso 10).
# TODO 2: cierra las que empiezan por "$prefix" y no tienen clientes (paso 11).
# TODO 3: imprime "quedan: " con los nombres que siguen vivos (paso 12).

# Borra esta línea al empezar:
echo "cleanup.sh: sin implementar ($prefix)" >&2
