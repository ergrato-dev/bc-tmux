#!/usr/bin/env bash
# Lab 03 — qué comando hay detrás de cada atajo del prefix.
# Necesita un servidor vivo: tmux -L lab new -s atajos
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

teclas=(d c n p % '"' '?')

for tecla in "${teclas[@]}"; do
  # Los cuatro primeros campos son "bind-key -T prefix <tecla>". Se imprime la
  # tecla pedida y no la del listado, que llega escapada (\% y \").
  comando=$(tmx list-keys -T prefix "$tecla" | awk '{ $1 = $2 = $3 = $4 = ""; sub(/^ +/, ""); print }')
  echo "$tecla -> $comando"
done
