#!/usr/bin/env bash
# Lab 03 — guarda cada buffer de tmux en DIR/NOMBRE.txt (SOLUCIÓN).
# Uso: guardar-buffers.sh DIR
# Salida: 0 si guardó al menos uno, 1 si no hay servidor o no hay buffers.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

dir="${1:?uso: guardar-buffers.sh DIR}"

# Sin servidor, list-buffers falla; con servidor y sin buffers, sale vacío.
# Los dos casos son el mismo para quien llama: no hay nada que guardar.
lista=$(tmx list-buffers -F '#{buffer_size} #{buffer_name}' 2>/dev/null) || true
if [[ -z "$lista" ]]; then
  echo "guardar-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)" >&2
  exit 1
fi

mkdir -p "$dir"
# El tamaño va primero: así read deja en $nombre el resto de la línea,
# aunque el nombre tenga espacios.
while read -r bytes nombre; do
  tmx save-buffer -b "$nombre" "$dir/${nombre//\//_}.txt"
  echo "guardado: $nombre ($bytes bytes)"
done <<<"$lista"
