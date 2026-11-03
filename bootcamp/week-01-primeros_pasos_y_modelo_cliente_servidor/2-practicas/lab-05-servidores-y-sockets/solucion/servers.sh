#!/usr/bin/env bash
# Lab 05 — qué servidores de tmux tienes y cuáles están vivos.
set -euo pipefail

dir="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"

for socket in "$dir"/*; do
  [[ -S "$socket" ]] || continue
  nombre=$(basename "$socket")

  # -S habla con ese socket exacto. list-sessions no arranca un servidor, así
  # que un socket huérfano no "revive" por preguntarle.
  if sesiones=$(tmux -S "$socket" list-sessions 2>/dev/null); then
    echo "$nombre: $(wc -l <<<"$sesiones") sesiones"
  else
    echo "$nombre: sin servidor"
  fi
done
