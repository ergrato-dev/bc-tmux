#!/usr/bin/env bash
# tmux-kit.tmux — plugin del kit: marcadores para la status line.
#
# Lo carga conf.d/60-plugins.conf con run-shell; TPM lo cargaría igual (ejecuta
# cada *.tmux de un plugin). Sin el kit: run-shell /ruta/al/kit/plugin/tmux-kit.tmux
# Sustituye en status-left y status-right:
#   #{kit_sessions}  cuántas sesiones hay, seguido de @kit-sessions-label (por defecto: ses)
#   #{kit_git}       la rama git del panel activo (bin/kit-git-branch)
# Volver a ejecutarlo no cambia nada: sin marcadores, no queda nada que sustituir.
set -euo pipefail

# Un plugin corre siempre dentro del servidor (run-shell): $TMUX ya apunta a
# él y tmux a secas le habla. TMUX_SOCKET no se usa: podría venir heredado del
# entorno con el que arrancó el servidor y apuntar a otro.
tmx() { "${TMUX_BIN:-tmux}" "$@"; }

kit_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# set_default OPCION VALOR — la fija solo si nadie lo hizo antes. Sin -q, show
# sale con 1 si la opción no existe.
set_default() {
  [[ -n "$(tmx show -gqv "$1")" ]] || tmx set -g "$1" "$2"
}

# Cargado sin el kit, nadie ha fijado @kit-dir: el marcador de git lo necesita.
set_default @kit-dir "$kit_dir"
set_default @kit-sessions-label ses

# Los marcadores se cambian por formats que tmux expande al dibujar, no por su
# valor de ahora: el número de sesiones y la etiqueta salen siempre al día, y
# cambiar @kit-sessions-label en caliente no pide volver a cargar el plugin.
# #{q:...} escapa las rutas para la shell de #(...), como en la semana 07.
sessions='#{server_sessions} #{@kit-sessions-label}'
git='#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})'

for option in status-left status-right; do
  value=$(tmx show -gqv "$option")
  # Reemplazo entre comillas: en bash 5.2 un & sin comillas sería "lo encontrado".
  new=${value//'#{kit_sessions}'/"$sessions"}
  new=${new//'#{kit_git}'/"$git"}
  [[ "$new" == "$value" ]] || tmx set -g "$option" "$new"
done
