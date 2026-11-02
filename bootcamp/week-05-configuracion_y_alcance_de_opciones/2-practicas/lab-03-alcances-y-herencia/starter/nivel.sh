#!/usr/bin/env bash
# Lab 03 — de qué nivel sale el valor de una opción de ventana en un panel.
# Uso: nivel.sh OPCION PANEL
# Imprime "VALOR (NIVEL)", con NIVEL: panel, ventana o global.
# Salida: 0 encontrada, 1 la opción o el panel no existen.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

opcion="${1:?uso: nivel.sh OPCION PANEL}"
panel="${2:?uso: nivel.sh OPCION PANEL}"

# TODO 1: valida el panel con list-panes -t (sale con 1 si no existe).
# TODO 2: función valor FLAGS...: lista "show FLAGS" SIN nombre de opción y
#         busca la línea que empieza por "$opcion " (awk '$1 == o'). Imprime
#         el resto de la línea y falla si no está. Con el nombre, show
#         elegiría el alcance por su cuenta e ignoraría -p y -w.
# TODO 3: prueba -p -t "$panel", después -w -t "$panel", después -gw, e
#         imprime "VALOR (panel|ventana|global)"; si no está, sale con 1.
echo "nivel.sh: sin implementar ($opcion en $panel)" >&2
exit 1
