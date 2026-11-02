#!/usr/bin/env bash
# Lab 05 — dice a qué servidor, sesión y panel pertenece esta shell.
# Uso: quien-soy.sh
set -euo pipefail

if [[ -z "${TMUX:-}" ]]; then
  echo "no estás dentro de tmux" >&2
  exit 1
fi

# $TMUX = socket,pid,sesión. Con -S y el socket se habla con el servidor de
# este panel, se haya arrancado con -L, con -S o con TMUX_TMPDIR.
socket="${TMUX%%,*}"

# -t "$TMUX_PANE": sin él, display-message elegiría la sesión más reciente,
# que no tiene por qué ser la de este panel.
tmux -S "$socket" display-message -p -t "$TMUX_PANE" \
  'servidor: #{socket_path} (pid #{pid})
sesión: #{session_name}
panel: #{pane_id}'
