#!/usr/bin/env bash
# Lab 05 — carga cada módulo de DIR/conf.d/ por separado y dice cuáles fallan
# (SOLUCIÓN).
# Uso: verificar-modulos.sh DIR
# Salida: 0 todos cargan, 1 alguno falla, 2 DIR no tiene conf.d/.
set -euo pipefail

dir="${1:?uso: verificar-modulos.sh DIR}"
[[ -d "$dir/conf.d" ]] || { echo "verificar-modulos.sh: $dir no tiene conf.d/" >&2; exit 2; }
dir=$(cd "$dir" && pwd)

# Un servidor propio, que nunca es el tuyo ni el del lab. Nombre fijo:
# kill-server deja el archivo del socket, y uno por ejecución se acumularía.
sock=verificar-modulos
tmx() { tmux -L "$sock" "$@"; }
trap 'tmux -L "$sock" kill-server 2>/dev/null || true' EXIT

fallos=0
for f in "$dir"/conf.d/*.conf; do
  # Servidor limpio por módulo: si uno solo funciona porque otro cargó antes
  # algo que necesita, aquí se nota.
  tmux -L "$sock" kill-server 2>/dev/null || true
  tmx -f /dev/null new -d
  tmx set -g @lab-dir "$dir"
  # source-file sale con 1 si alguna línea falla; los mensajes, en una línea.
  if err=$(tmx source-file "$f" 2>&1); then
    echo "ok     ${f##*/}"
  else
    echo "error  ${f##*/}: ${err//$'\n'/; }"
    fallos=$((fallos + 1))
  fi
done

(( fallos == 0 ))
