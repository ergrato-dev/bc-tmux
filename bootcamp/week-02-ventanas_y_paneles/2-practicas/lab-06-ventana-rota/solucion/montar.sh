#!/usr/bin/env bash
# Lab 06 — ventana "monitor": cpu a la izquierda (50 %), disco y red a la derecha.
# Solución con los cuatro errores corregidos.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# Error 1: sin -d, new-session intenta conectar un cliente. Dentro de tmux
# falla con "sessions should be nested with care".
cpu=$(tmx new-session -d -P -F '#{pane_id}' -s monitor -n monitor)

# Error 2: sin -t, split-window parte el panel desde el que corre el script
# (el de $TMUX_PANE), que está en otra sesión. Siempre -t con un id.
disco=$(tmx split-window -d -h -P -F '#{pane_id}' -t "$cpu")
red=$(tmx split-window -d -v -P -F '#{pane_id}' -t "$disco")

# Error 3: sin -t, select-pane -T titula ese mismo panel ajeno, no el nuevo.
tmx select-pane -t "$cpu" -T cpu
tmx select-pane -t "$disco" -T disco
tmx select-pane -t "$red" -T red

# Error 4: main-pane-width se lee al aplicar el layout: primero la opción,
# después select-layout.
tmx set -w -t "$cpu" main-pane-width 50%
tmx select-layout -t "$cpu" main-vertical

echo "ventana monitor lista"
