#!/usr/bin/env bash
# Lab 05 — qué servidores de tmux tienes y cuáles están vivos.
set -euo pipefail

dir="/tmp/tmux-$(id -u)"

for socket in "$dir"/*; do
  [[ -S "$socket" ]] || continue
  nombre=$(basename "$socket")

  # TODO: pregunta con tmux -S "$socket" list-sessions cuántas sesiones hay
  #       (wc -l). Si el comando falla, imprime "<nombre>: sin servidor";
  #       si no, "<nombre>: <n> sesiones".
  echo "$nombre: TODO"
done
