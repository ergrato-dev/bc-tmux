#!/usr/bin/env bash
# Lab 03 — guarda y restaura el layout de una ventana.
# Uso: layout.sh guardar VENTANA ARCHIVO
#      layout.sh restaurar VENTANA ARCHIVO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

accion="${1:?uso: layout.sh guardar|restaurar VENTANA ARCHIVO}"
ventana="${2:?falta la ventana}"
archivo="${3:?falta el archivo}"

case "$accion" in
  guardar)
    # TODO 1: escribe #{window_layout} de "$ventana" en "$archivo".
    ;;
  restaurar)
    # TODO 2: aplica el contenido de "$archivo" con select-layout -t "$ventana".
    ;;
  *)
    echo "acción desconocida: $accion" >&2
    exit 2
    ;;
esac
echo "layout.sh: $accion sin implementar ($ventana $archivo)" >&2
