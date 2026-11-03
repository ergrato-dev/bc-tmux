#!/usr/bin/env bash
# sessions.tmux — añade a status-right cuántas sesiones hay y cuántas se
# crearon desde que arrancó el servidor.
#
# Sin el lab: run-shell /ruta/a/plugin/sessions.tmux
# Volver a ejecutarlo no cambia nada.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" "$@"; }

segment=' #{server_sessions} ses (#{@sessions-created} creadas)'
right=$(tmx show -gqv status-right)
[[ "$right" == *"$segment"* ]] || tmx set -g status-right "$right$segment"

# Fallo 2: índice fijo. Con -ga cada recarga añadía otra entrada y una
# sesión nueva sumaba tantas veces como recargas hubo.
tmx set-hook -g 'session-created[10]' 'set -gF @sessions-created "#{e|+:#{@sessions-created},1}"'
