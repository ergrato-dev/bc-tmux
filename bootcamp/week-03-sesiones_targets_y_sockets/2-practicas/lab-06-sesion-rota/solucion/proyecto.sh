#!/usr/bin/env bash
# Lab 06 — te lleva a la sesión del proyecto DIR, creándola si no existe.
# Solución con los cuatro errores corregidos.
# Uso: proyecto.sh DIR
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: proyecto.sh DIR}"

# Error 4: "." y ":" separan las partes de un target; tmux los cambia por
# "_" al crear la sesión. Se convierten antes para buscar el mismo nombre.
nombre=$(basename "$dir")
nombre=${nombre//[.:]/_}

# Error 2: "ls | grep api" también encuentra "api-vieja" (y "." en grep es
# cualquier carácter). has-session pregunta por una sesión concreta.
# Error 3: sin "=", -t "api" coincide por prefijo con "api-vieja".
if ! tmx has-session -t "=$nombre" 2>/dev/null; then
  tmx new-session -d -s "$nombre" -c "$dir"
fi

# Error 1: dentro de tmux, attach anidaría un cliente; se cambia el actual.
if [[ -n "${TMUX:-}" ]]; then
  tmx switch-client -t "=$nombre"
else
  tmx attach-session -t "=$nombre"
fi
