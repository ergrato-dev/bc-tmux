#!/usr/bin/env bash
# Lab 03 — de qué nivel sale el valor de una opción de ventana en un panel
# (SOLUCIÓN).
# Uso: scope.sh OPCION PANEL
# Imprime "VALOR (NIVEL)", con NIVEL: panel, ventana o global.
# Salida: 0 encontrada, 1 la opción o el panel no existen.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

option="${1:?uso: scope.sh OPCION PANEL}"
pane="${2:?uso: scope.sh OPCION PANEL}"

# display-message no falla con un panel que no existe; list-panes sí.
if ! tmx list-panes -t "$pane" >/dev/null 2>&1; then
  echo "scope.sh: no existe el panel $pane" >&2
  exit 1
fi

# Sin nombre, show lista solo lo fijado en ese nivel. Con nombre, deduce el
# alcance por la opción y puede ignorar -w o -s (show -w escape-time contesta
# con el valor del servidor).
value() {
  tmx show "$@" | awk -v o="$option" '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'
}

# Del más concreto al más general: el primero que la tiene, gana.
if v=$(value -p -t "$pane"); then echo "$v (panel)"
elif v=$(value -w -t "$pane"); then echo "$v (ventana)"
elif v=$(value -gw); then echo "$v (global)"
else
  echo "scope.sh: $option no es una opción de ventana" >&2
  exit 1
fi
