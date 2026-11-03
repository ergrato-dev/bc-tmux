#!/usr/bin/env bash
# Lab 05 — qué servidores de tmux tienes y cuáles están vivos.
set -euo pipefail

dir="/tmp/tmux-$(id -u)"

for socket in "$dir"/*; do
  [[ -S "$socket" ]] || continue
  name=$(basename "$socket")

  # TODO: guarda la salida de tmux -S "$socket" list-sessions en "sessions"
  #       dentro de un if (con set -e, un fallo suelto corta el script) y con
  #       2>/dev/null (calla "no server running"). Si falla:
  #       "$name: sin servidor"; si no: "$name: <n> sesiones", con
  #       n = wc -l <<<"$sessions". Borra el echo de abajo.
  echo "$name: TODO"
done
