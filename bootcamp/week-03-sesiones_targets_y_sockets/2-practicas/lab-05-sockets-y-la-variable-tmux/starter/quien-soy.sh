#!/usr/bin/env bash
# Lab 05 — dice a qué servidor, sesión y panel pertenece esta shell.
# Uso: quien-soy.sh
set -euo pipefail

# TODO 1: si $TMUX está vacío: "no estás dentro de tmux" por stderr y sal con 1.
# TODO 2: el socket es lo que va antes de la primera coma: "${TMUX%%,*}".
# TODO 3: con tmux -S "$socket" display-message -p -t "$TMUX_PANE", imprime:
#         servidor: SOCKET (pid N)
#         sesión: NOMBRE
#         panel: %N
echo "quien-soy.sh: sin implementar" >&2
