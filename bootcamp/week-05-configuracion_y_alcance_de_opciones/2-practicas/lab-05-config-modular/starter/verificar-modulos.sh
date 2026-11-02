#!/usr/bin/env bash
# Lab 05 — carga cada módulo de DIR/conf.d/ por separado y dice cuáles fallan.
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

# TODO 1: al salir (trap ... EXIT), cierra ese servidor: tmux -L "$sock" kill-server.
# TODO 2: por cada conf.d/*.conf: servidor limpio (-f /dev/null new -d),
#         @lab-dir con el valor de $dir (los módulos lo usan) y source-file.
#         Imprime "ok     NOMBRE" o "error  NOMBRE: MENSAJE" (en una línea).
# TODO 3: sale con 1 si alguno falló.
echo "verificar-modulos.sh: sin implementar ($dir)" >&2
exit 1
