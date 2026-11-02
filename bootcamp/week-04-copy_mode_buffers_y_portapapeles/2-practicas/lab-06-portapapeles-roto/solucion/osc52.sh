#!/usr/bin/env bash
# Lab 06 — copia su entrada estándar al portapapeles de tu terminal con OSC 52
# (SOLUCIÓN).
# Uso: ... | osc52.sh
# OSC52_TTY cambia el destino (para ver la secuencia en un archivo).
set -euo pipefail

# Dentro de tmux (run-shell, copy-pipe) no hay tty, y si la hay es un panel.
# load-buffer -w crea un buffer y le pide a tmux que envíe él el OSC 52 a la
# terminal exterior, según set-clipboard y terminal-features.
if [[ -n "${TMUX:-}" ]]; then
  exec tmux load-buffer -w -
fi

# base64 parte la salida cada 76 caracteres; la secuencia debe ir en una
# sola línea o la terminal la descarta. tr también funciona en macOS (base64
# de BSD no tiene -w0).
printf '\033]52;c;%s\a' "$(base64 | tr -d '\n')" >"${OSC52_TTY:-/dev/tty}"
