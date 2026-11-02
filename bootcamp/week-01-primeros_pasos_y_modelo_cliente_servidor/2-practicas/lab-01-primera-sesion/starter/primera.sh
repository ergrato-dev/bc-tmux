#!/usr/bin/env bash
# Lab 01 — crea la sesión "primera" en segundo plano y lista las sesiones.
# Pruébalo sin tocar tus sesiones: el servidor es "lab" (tmux -L lab).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO 1: crea la sesión "primera" sin conectarte (-d), con la ventana "inicio" (-n).

# TODO 2: lista las sesiones del servidor (ls).
