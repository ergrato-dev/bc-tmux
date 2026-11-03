#!/usr/bin/env bash
# Lab 03 — salta a una sesión, dentro o fuera de tmux.
# Uso: jump.sh NOMBRE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

name="${1:?uso: jump.sh NOMBRE}"

if ! tmx has-session -t "=$name" 2>/dev/null; then
  echo "no existe la sesión '$name'" >&2
  exit 1
fi

# Dentro de tmux, attach anidaría un cliente en un panel: se mueve el actual.
if [[ -n "${TMUX:-}" ]]; then
  tmx switch-client -t "=$name"
else
  tmx attach-session -t "=$name"
fi
