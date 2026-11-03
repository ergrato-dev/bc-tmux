#!/usr/bin/env bash
# sessions.tmux — añade a status-right cuántas sesiones hay y cuántas se
# crearon desde que arrancó el servidor.
#
# Probar a mano contra el servidor del lab (desde la carpeta del lab):
#   tmux -L lab run-shell "$PWD/starter/plugin/sessions.tmux"; echo $?
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" "$@"; }

segment=' #{server_sessions} ses (#{@sessions-created} creadas)'
right=$(tmx show -gqv status-right)
[[ "$right" == *"$segment"* ]] || tmx set -g status-right "$right$segment"

tmx set-hook -ga session-created 'set -gF @sessions-created "#{e|+:#{@sessions-created},1}"'
