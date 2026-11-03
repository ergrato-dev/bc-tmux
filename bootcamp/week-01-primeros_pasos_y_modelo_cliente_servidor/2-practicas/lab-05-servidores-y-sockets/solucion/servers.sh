#!/usr/bin/env bash
# Lab 05 — qué servidores de tmux tienes y cuáles están vivos.
set -euo pipefail

dir="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"

for socket in "$dir"/*; do
  [[ -S "$socket" ]] || continue
  name=$(basename "$socket")

  # list-sessions no arranca un servidor: un socket huérfano no "revive" por
  # preguntarle, y el if evita que set -e corte el script cuando falla.
  if sessions=$(tmux -S "$socket" list-sessions 2>/dev/null); then
    echo "$name: $(wc -l <<<"$sessions") sesiones"
  else
    echo "$name: sin servidor"
  fi
done
