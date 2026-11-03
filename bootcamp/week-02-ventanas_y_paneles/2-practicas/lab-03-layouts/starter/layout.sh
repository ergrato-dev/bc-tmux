#!/usr/bin/env bash
# Lab 03 — guarda y restaura el layout de una ventana.
# Uso: layout.sh guardar VENTANA ARCHIVO
#      layout.sh restaurar VENTANA ARCHIVO
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

accion="${1:?uso: layout.sh guardar|restaurar VENTANA ARCHIVO}"
ventana="${2:?falta la ventana}"
archivo="${3:?falta el archivo}"

# TODO 1: falla si la ventana no existe. display-message no falla con un
#         target inexistente; list-panes sí:
#         tmx list-panes -t "$ventana" >/dev/null

case "$accion" in
  guardar)
    # TODO 2: escribe #{window_layout} de "$ventana" en "$archivo" y avisa:
    #         tmx display-message -p -t "$ventana" '#{window_layout}' >"$archivo"
    #         echo "guardado en $archivo"
    ;;
  restaurar)
    # TODO 3: aplica el contenido de "$archivo" y avisa:
    #         tmx select-layout -t "$ventana" "$(<"$archivo")"
    #         echo "restaurado desde $archivo"
    ;;
  *)
    echo "acción desconocida: $accion" >&2
    exit 2
    ;;
esac
echo "layout.sh: $accion sin implementar ($ventana $archivo)" >&2
