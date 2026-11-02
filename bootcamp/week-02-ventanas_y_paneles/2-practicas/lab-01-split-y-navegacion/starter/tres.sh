#!/usr/bin/env bash
# Lab 01 — sesión "tres": paneles editor, shell y logs en el directorio dado.
# Uso: tres.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: tres.sh DIR}"

# TODO 1: crea la sesión "tres" en segundo plano en "$dir" y guarda el id de
#         su primer panel: editor=$(tmx new-session -d -P -F '#{pane_id}' ...)

# TODO 2: parte editor a lo ancho (shell) y shell a lo alto (logs), siempre
#         con -d, -c "$dir" y -P -F '#{pane_id}'.

# TODO 3: titula cada panel por su id (select-pane -t "$editor" -T editor ...).

# TODO 4: lista los paneles: '#{pane_id} #{pane_title} #{pane_current_path}'
echo "tres.sh: sin implementar ($dir)" >&2
