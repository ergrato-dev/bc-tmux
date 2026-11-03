#!/usr/bin/env bash
# Lab 06 — ventana "monitor": cpu a la izquierda (50 %), disco y red a la derecha.
# Este script tiene CUATRO errores. Encuéntralos (README.md).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

tmx new-session -s monitor -n monitor
tmx select-pane -T cpu

tmx split-window -h
tmx select-pane -T disco

tmx split-window -v
tmx select-pane -T red

tmx select-layout -t monitor:monitor main-vertical
tmx set -w -t monitor:monitor main-pane-width 50%

echo "ventana monitor lista"
