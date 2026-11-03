#!/usr/bin/env bash
# Lab 03 — de qué nivel sale el valor de una opción de ventana en un panel.
# Uso: scope.sh OPCION PANEL
# Imprime "VALOR (NIVEL)", con NIVEL: panel, ventana o global.
# Salida: 0 encontrada, 1 la opción o el panel no existen.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

option="${1:?uso: scope.sh OPCION PANEL}"
pane="${2:?uso: scope.sh OPCION PANEL}"

# TODO 1: valida el panel con list-panes -t (display-message no falla con un
#         panel que no existe). Si falla: "scope.sh: no existe el panel PANEL"
#         por stderr y exit 1.
# TODO 2: función value FLAGS...: tmx show "$@" SIN nombre de opción, por una
#         tubería a awk -v o="$option" '$1 == o { sub(/^[^ ]+ /, ""); print;
#         f = 1; exit } END { exit !f }'. Con el nombre, show deduce el
#         alcance por la opción y puede ignorar -w o -s.
# TODO 3: if v=$(value -p -t "$pane"); then "VALOR (panel)"; elif con
#         -w -t "$pane" (ventana); elif con -gw (global); else
#         "scope.sh: OPCION no es una opción de ventana" por stderr y exit 1.
#         Borra las dos líneas de abajo.
echo "scope.sh: sin implementar ($option en $pane)" >&2
exit 1
