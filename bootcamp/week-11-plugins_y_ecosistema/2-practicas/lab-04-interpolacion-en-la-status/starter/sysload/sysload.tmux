#!/usr/bin/env bash
# sysload.tmux — sustituye marcadores en status-left y status-right, como
# hacen tmux-cpu o tmux-battery:
#   #{sysload_load}   carga media del último minuto (scripts/load.sh)
#   #{sysload_cores}  número de núcleos
#
# Probar a mano contra el servidor del lab (desde la carpeta del lab):
#   tmux -L lab run-shell "$PWD/starter/sysload/sysload.tmux"; echo $?
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" "$@"; }

# TODO 1: la carpeta del plugin, para encontrar scripts/load.sh esté donde
# esté instalado (TPM, run-shell a mano):
#   CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# TODO 2: lo que va en lugar de cada marcador.
# - La carga cambia: un #(...) que tmux vuelve a ejecutar cada
#   status-interval. printf %q cita la ruta para la shell de #(...):
#     printf -v load '#(%q)' "$CURRENT_DIR/scripts/load.sh"
# - Los núcleos no cambian: se calculan una vez, al cargar el plugin:
#     cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu)

for option in status-left status-right; do
  value=$(tmx show -gqv "$option")
  new=$value
  # TODO 3: sustituye los dos marcadores con ${var//patrón/reemplazo}. El
  # patrón entre comillas simples (literal); el reemplazo entre dobles (en
  # bash 5.2, un & sin comillas sería "lo encontrado"):
  #   new=${new//'#{sysload_load}'/"$load"}
  #   new=${new//'#{sysload_cores}'/"$cores"}
  [[ "$new" == "$value" ]] || tmx set -g "$option" "$new"
done
