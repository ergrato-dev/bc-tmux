#!/usr/bin/env bash
# Lab 05 — carga cada módulo de DIR/conf.d/ por separado y dice cuáles fallan.
# Uso: check-modules.sh DIR
# Salida: 0 todos cargan, 1 alguno falla, 2 DIR no tiene conf.d/.
set -euo pipefail

dir="${1:?uso: check-modules.sh DIR}"
[[ -d "$dir/conf.d" ]] || { echo "check-modules.sh: $dir no tiene conf.d/" >&2; exit 2; }
dir=$(cd "$dir" && pwd)

# Un servidor propio, que nunca es el tuyo ni el del lab. Nombre fijo:
# kill-server deja el archivo del socket, y uno por ejecución se acumularía.
sock=check-modules
tmx() { tmux -L "$sock" "$@"; }

# TODO 1: al salir, cierra ese servidor.
#         Pista: trap 'tmux -L "$sock" kill-server 2>/dev/null || true' EXIT
# TODO 2: failures=0; por cada "$dir"/conf.d/*.conf: kill-server (servidor
#         limpio), tmx -f /dev/null new -d, tmx set -g @lab-dir "$dir" y
#         err=$(tmx source-file "$f" 2>&1). Imprime "ok     NOMBRE" o
#         "error  NOMBRE: MENSAJE" (${err//$'\n'/; }, en una línea) y suma
#         el fallo. Borra las dos líneas de abajo.
# TODO 3: sale con 1 si alguno falló: (( failures == 0 )) como última línea.
echo "check-modules.sh: sin implementar ($dir)" >&2
exit 1
