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

# TODO 1 (lab-03-anatomia-de-un-plugin y lab-04-interpolacion-en-la-status):
#   - set_default OPCION VALOR: fija la opción con tmx set -g solo si
#     tmx show -gqv OPCION sale vacío. Úsala con @kit-sessions-label ses.
#   - Para cada opción de status-left y status-right: lee el valor con
#     tmx show -gqv, cambia #{kit_sessions} por el format
#     '#{server_sessions} #{@kit-sessions-label}' (${valor//'#{kit_sessions}'/"$nuevo"})
#     y escríbelo con tmx set -g solo si cambió.

# TODO 2 (lab-04-interpolacion-en-la-status): en el mismo bucle, cambia
#   #{kit_git} por '#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})'.
#   Cargado sin el kit, nadie fijó @kit-dir: dale como valor por defecto el
#   directorio padre de este archivo: $(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
