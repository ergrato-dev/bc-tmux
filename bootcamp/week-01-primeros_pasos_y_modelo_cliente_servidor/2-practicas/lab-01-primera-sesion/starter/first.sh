#!/usr/bin/env bash
# Lab 01 — crea la sesión "primera" en segundo plano y lista las sesiones.
# Pruébalo sin tocar tus sesiones: el servidor es "lab" (tmux -L lab).
set -euo pipefail

# -f /dev/null: si este script arranca el servidor, lo hace sin tu configuración.
tmx() { tmux -L "${TMUX_SOCKET:-lab}" -f /dev/null "$@"; }

# TODO 1: crea la sesión "primera" sin conectarte, con la ventana "inicio".
#         new-session  -d (no te conecta)  -s <sesión>  -n <ventana>

# TODO 2: lista las sesiones del servidor (tmx ls).
