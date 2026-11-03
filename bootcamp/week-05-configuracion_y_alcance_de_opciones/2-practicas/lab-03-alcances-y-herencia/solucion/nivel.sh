#!/usr/bin/env bash
# Lab 03 — de qué nivel sale el valor de una opción de ventana en un panel
# (SOLUCIÓN).
# Uso: nivel.sh OPCION PANEL
# Imprime "VALOR (NIVEL)", con NIVEL: panel, ventana o global.
# Salida: 0 encontrada, 1 la opción o el panel no existen.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

opcion="${1:?uso: nivel.sh OPCION PANEL}"
panel="${2:?uso: nivel.sh OPCION PANEL}"

# display-message no falla con un panel que no existe; list-panes sí.
if ! tmx list-panes -t "$panel" >/dev/null 2>&1; then
  echo "nivel.sh: no existe el panel $panel" >&2
  exit 1
fi

# Sin nombre, show lista solo lo fijado en ese nivel. Con nombre, deduce el
# alcance por la opción y puede ignorar -w o -s (show -w escape-time contesta
# con el valor del servidor).
valor() {
  tmx show "$@" | awk -v o="$opcion" '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'
}

# Del más concreto al más general: el primero que la tiene, gana.
if v=$(valor -p -t "$panel"); then echo "$v (panel)"
elif v=$(valor -w -t "$panel"); then echo "$v (ventana)"
elif v=$(valor -gw); then echo "$v (global)"
else
  echo "nivel.sh: $opcion no es una opción de ventana" >&2
  exit 1
fi
