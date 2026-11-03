#!/usr/bin/env bash
# Lab 03 — qué comando hay detrás de cada atajo del prefix.
# Necesita un servidor vivo: tmux -L lab -f /dev/null new -s atajos
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

keys=(d c n p % '"' '?')

for key in "${keys[@]}"; do
  # TODO: tmx list-keys -T prefix "$key" imprime
  #         bind-key -T prefix <tecla> <comando...>
  #       Guarda en "cmd" del quinto campo al final (cut -d' ' -f5-),
  #       imprime "$key -> $cmd" y borra el echo de abajo.
  echo "$key -> TODO"
done
