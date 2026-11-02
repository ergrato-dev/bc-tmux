#!/usr/bin/env bash
# Lab 03 — salta a una sesión, dentro o fuera de tmux.
# Uso: saltar.sh NOMBRE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

nombre="${1:?uso: saltar.sh NOMBRE}"

if ! tmx has-session -t "=$nombre" 2>/dev/null; then
  echo "no existe la sesión '$nombre'" >&2
  exit 1
fi

# Dentro de tmux, attach anidaría un cliente en un panel: se mueve el actual.
if [[ -n "${TMUX:-}" ]]; then
  tmx switch-client -t "=$nombre"
else
  tmx attach-session -t "=$nombre"
fi
