#!/usr/bin/env bash
# Lab 03 — qué comando hay detrás de cada atajo del prefix.
# Necesita un servidor vivo: tmux -L lab new -s atajos
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

teclas=(d c n p % '"' '?')

for tecla in "${teclas[@]}"; do
  # TODO: tmx list-keys -T prefix "$tecla" imprime
  #         bind-key -T prefix <tecla> <comando...>
  #       Quita los cuatro primeros campos (awk) e imprime: <tecla> -> <comando>
  echo "$tecla -> TODO"
done
