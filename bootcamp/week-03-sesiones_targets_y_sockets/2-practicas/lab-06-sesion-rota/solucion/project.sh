#!/usr/bin/env bash
# Lab 06 — te lleva a la sesión del proyecto DIR, creándola si no existe.
# Solución con los cuatro errores corregidos.
# Uso: project.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: project.sh DIR}"

# Error 4: "." y ":" separan las partes de un target; tmux los cambia por
# "_" al crear la sesión. Se convierten antes para buscar el mismo nombre.
name=$(basename "$dir")
name=${name//[.:]/_}

# Error 2: "ls | grep api" también encuentra "api-vieja" (y "." en grep es
# cualquier carácter). has-session pregunta por una sesión concreta.
# Error 3: sin "=", -t "api" coincide por prefijo con "api-vieja".
if ! tmx has-session -t "=$name" 2>/dev/null; then
  tmx new-session -d -s "$name" -c "$dir"
fi

# Error 1: dentro de tmux, attach anidaría un cliente; se cambia el actual.
if [[ -n "${TMUX:-}" ]]; then
  tmx switch-client -t "=$name"
else
  tmx attach-session -t "=$name"
fi
