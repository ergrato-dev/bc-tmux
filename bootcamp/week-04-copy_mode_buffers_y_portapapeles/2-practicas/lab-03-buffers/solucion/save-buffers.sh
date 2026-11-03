#!/usr/bin/env bash
# Lab 03 — guarda cada buffer de tmux en DIR/NOMBRE.txt (SOLUCIÓN).
# Uso: save-buffers.sh DIR
# Salida: 0 si guardó al menos uno, 1 si no hay servidor o no hay buffers.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: save-buffers.sh DIR}"

# Sin servidor, list-buffers falla; con servidor y sin buffers, sale vacío.
# Los dos casos son el mismo para quien llama: no hay nada que guardar.
list=$(tmx list-buffers -F '#{buffer_size} #{buffer_name}' 2>/dev/null) || true
if [[ -z "$list" ]]; then
  echo "save-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)" >&2
  exit 1
fi

mkdir -p "$dir"
# El tamaño va primero: así read deja en $name el resto de la línea,
# aunque el nombre tenga espacios.
while read -r bytes name; do
  tmx save-buffer -b "$name" "$dir/${name//\//_}.txt"
  echo "guardado: $name ($bytes bytes)"
done <<<"$list"
