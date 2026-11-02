#!/usr/bin/env bash
# Lab 02 — dice a qué sesión, ventana y panel apunta un target.
# Uso: resolver.sh TARGET
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

target="${1:?uso: resolver.sh TARGET}"

# display-message usaría otro objeto sin avisar; list-panes falla de verdad.
if ! tmx list-panes -t "$target" >/dev/null 2>&1; then
  echo "resolver.sh: no existe el target '$target'" >&2
  exit 1
fi

tmx display-message -p -t "$target" \
  '#{session_name}:#{window_index}.#{pane_index}  sesión #{session_id}  ventana #{window_id}  panel #{pane_id}'
