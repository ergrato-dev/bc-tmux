#!/usr/bin/env bash
# sysload.tmux — sustituye marcadores en status-left y status-right, como
# hacen tmux-cpu o tmux-battery:
#   #{sysload_load}   carga media del último minuto (scripts/load.sh)
#   #{sysload_cores}  número de núcleos
#
# Sin TPM: run-shell /ruta/a/sysload/sysload.tmux
# Volver a ejecutarlo no cambia nada: sin marcadores, no queda qué sustituir.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" "$@"; }

# run-shell se ejecuta en el directorio del servidor: sin la ruta del propio
# plugin, scripts/load.sh no se encontraría.
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# La carga cambia: un #(...) que tmux vuelve a ejecutar cada status-interval.
# %q cita la ruta: con un espacio en ella, #(...) ejecutaría otra cosa.
printf -v load '#(%q)' "$CURRENT_DIR/scripts/load.sh"
# Los núcleos no cambian: una vez, al cargar, y sin shell en cada redibujado.
cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu)

for option in status-left status-right; do
  value=$(tmx show -gqv "$option")
  # Reemplazo entre comillas: en bash 5.2 un & sin comillas sería "lo encontrado".
  new=${value//'#{sysload_load}'/"$load"}
  new=${new//'#{sysload_cores}'/"$cores"}
  [[ "$new" == "$value" ]] || tmx set -g "$option" "$new"
done
