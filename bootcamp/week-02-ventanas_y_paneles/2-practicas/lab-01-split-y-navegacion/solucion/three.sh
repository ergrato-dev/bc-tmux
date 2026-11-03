#!/usr/bin/env bash
# Lab 01 — sesión "tres": paneles editor, shell y logs en el directorio dado.
# Uso: tres.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: tres.sh DIR}"

editor=$(tmx new-session -d -P -F '#{pane_id}' -s tres -c "$dir")
# -d: el panel nuevo no se vuelve el activo, así el siguiente split sabe
# siempre de quién parte (lo dice su -t, no el foco).
shell=$(tmx split-window -d -h -P -F '#{pane_id}' -t "$editor" -c "$dir")
logs=$(tmx split-window -d -v -P -F '#{pane_id}' -t "$shell" -c "$dir")

tmx select-pane -t "$editor" -T editor
tmx select-pane -t "$shell" -T shell
tmx select-pane -t "$logs" -T logs

# Un instante para que las shells arranquen y #{pane_current_path} sea real.
sleep 0.3
tmx list-panes -t tres -F '#{pane_id} #{pane_title} #{pane_current_path}'
