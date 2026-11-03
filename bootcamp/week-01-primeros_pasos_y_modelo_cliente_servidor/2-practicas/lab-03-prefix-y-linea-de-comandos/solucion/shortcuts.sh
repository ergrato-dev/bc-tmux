#!/usr/bin/env bash
# Lab 03 — qué comando hay detrás de cada atajo del prefix.
# Necesita un servidor vivo: tmux -L lab -f /dev/null new -s atajos
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

teclas=(d c n p % '"' '?')

for tecla in "${teclas[@]}"; do
  # Los cuatro primeros campos son "bind-key -T prefix <tecla>". Se imprime la
  # tecla pedida y no la del listado, que llega escapada (\% y \").
  comando=$(tmx list-keys -T prefix "$tecla" | cut -d' ' -f5-)
  echo "$tecla -> $comando"
done
