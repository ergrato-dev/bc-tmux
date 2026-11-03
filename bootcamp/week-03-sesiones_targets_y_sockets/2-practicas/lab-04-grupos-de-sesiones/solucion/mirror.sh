#!/usr/bin/env bash
# Lab 04 — crea BASE-espejo en el grupo de BASE (si no existe).
# Uso: mirror.sh BASE
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

base="${1:?uso: mirror.sh BASE}"
mirror="$base-espejo"

if ! tmx has-session -t "=$base" 2>/dev/null; then
  echo "no existe la sesión '$base'" >&2
  exit 1
fi

# Idempotente: comprobar antes de crear. "=" para no confundir "base-espejo"
# con otra sesión que empiece igual.
if tmx has-session -t "=$mirror" 2>/dev/null; then
  echo "ya existe: $mirror"
else
  # En new-session, -t no es un destino: es la sesión con la que agruparse.
  tmx new-session -d -t "=$base" -s "$mirror"
  echo "creada: $mirror"
fi

tmx display-message -p -t "=$base:" 'grupo #{session_group}: #{session_group_list}'
