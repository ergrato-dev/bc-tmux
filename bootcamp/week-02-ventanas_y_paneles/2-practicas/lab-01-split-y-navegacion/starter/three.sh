#!/usr/bin/env bash
# Lab 01 — sesión "tres": paneles editor, shell y logs en el directorio dado.
# Uso: three.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: three.sh DIR}"

# TODO 1: crea la sesión "tres" en segundo plano en "$dir" y guarda el id de
#         su primer panel:
#         editor=$(tmx new-session -d -P -F '#{pane_id}' -s tres -c "$dir")

# TODO 2: parte editor a lo ancho (shell) y shell a lo alto (logs):
#         shell=$(tmx split-window -d -h -P -F '#{pane_id}' -t "$editor" -c "$dir")
#         logs=...  (lo mismo con -v y -t "$shell")

# TODO 3: titula cada panel por su id: tmx select-pane -t "$editor" -T editor
#         (y lo mismo para shell y logs).

# TODO 4: espera a que arranquen las shells (sleep 0.3) y lista los paneles de
#         la sesión con -F '#{pane_id} #{pane_title} #{pane_current_path}'.
echo "three.sh: sin implementar ($dir)" >&2
