#!/usr/bin/env bash
# Lab 01 — teclas de una tabla que tienen nota (bind -N) (SOLUCIÓN).
# Uso: keys-of.sh TABLA
# Imprime "TECLA NOTA" por cada tecla con nota y, al final,
# "con nota: N de M".
# Salida: 0 bien, 1 sin servidor o tabla inexistente, 2 uso incorrecto.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

if [[ $# -ne 1 ]]; then
  echo "uso: keys-of.sh TABLA" >&2
  exit 2
fi
table="$1"

tmx list-sessions >/dev/null 2>&1 || {
  echo "keys-of.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}" >&2
  exit 1
}

# Sin -N, list-keys lista todas las teclas: sirve para saber si la tabla
# existe y cuántas tiene.
if ! all=$(tmx list-keys -T "$table" 2>/dev/null); then
  echo "keys-of.sh: no existe la tabla $table" >&2
  exit 1
fi

tmx list-keys -N -T "$table"
echo "con nota: $(tmx list-keys -N -T "$table" | wc -l) de $(printf '%s\n' "$all" | wc -l)"
