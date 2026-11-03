#!/usr/bin/env bash
# Lab 04 — construye la sesión "obra": ventana editor (2 paneles) + ventana logs.
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

tmx new-session -d -s obra -n editor
tmx split-window -h -t obra:editor
# "obra:" con dos puntos: la siguiente ventana libre de la sesión obra.
tmx new-window -d -t obra: -n logs

# -s: los paneles de todas las ventanas de la sesión, no solo de la activa.
tmx list-panes -s -t obra -F '#{window_name}.#{pane_index} #{pane_id}'
