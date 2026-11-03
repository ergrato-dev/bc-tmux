#!/usr/bin/env bash
# Lab 03 — de qué nivel sale el valor de una opción de ventana en un panel.
# Uso: nivel.sh OPCION PANEL
# Imprime "VALOR (NIVEL)", con NIVEL: panel, ventana o global.
# Salida: 0 encontrada, 1 la opción o el panel no existen.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

opcion="${1:?uso: nivel.sh OPCION PANEL}"
panel="${2:?uso: nivel.sh OPCION PANEL}"

# TODO 1: valida el panel con list-panes -t (display-message no falla con un
#         panel que no existe). Si falla: "nivel.sh: no existe el panel PANEL"
#         por stderr y exit 1.
# TODO 2: función valor FLAGS...: tmx show "$@" SIN nombre de opción, por una
#         tubería a awk -v o="$opcion" '$1 == o { sub(/^[^ ]+ /, ""); print;
#         f = 1; exit } END { exit !f }'. Con el nombre, show deduce el
#         alcance por la opción y puede ignorar -w o -s.
# TODO 3: if v=$(valor -p -t "$panel"); then "VALOR (panel)"; elif con
#         -w -t "$panel" (ventana); elif con -gw (global); else
#         "nivel.sh: OPCION no es una opción de ventana" por stderr y exit 1.
#         Borra las dos líneas de abajo.
echo "nivel.sh: sin implementar ($opcion en $panel)" >&2
exit 1
