#!/usr/bin/env bash
# zoom-flag.tmux — plugin mínimo: marca de zoom en status-right y una tecla
# para alternar el zoom del panel.
#
# Sin TPM: run-shell /ruta/a/zoom-flag/zoom-flag.tmux
# Opciones (se fijan antes de cargarlo):
#   @zoom-flag-key   tecla tras el prefix (por defecto: Z)
#   @zoom-flag-text  texto de la marca (por defecto: ZOOM)
# Volver a ejecutarlo no cambia nada.
set -euo pipefail

# run-shell lo ejecuta dentro del servidor: $TMUX ya apunta a él.
tmx() { "${TMUX_BIN:-tmux}" "$@"; }

# set_default OPCION VALOR — fija la opción solo si el usuario no lo hizo.
# Sin -q, show sale con 1 si la opción no existe y set -e corta el plugin.
set_default() {
  [[ -n "$(tmx show -gqv "$1")" ]] || tmx set -g "$1" "$2"
}

set_default @zoom-flag-key Z
set_default @zoom-flag-text ZOOM

key=$(tmx show -gqv @zoom-flag-key)
tmx bind-key "$key" resize-pane -Z

# El texto va como #{@zoom-flag-text}, no como su valor: tmux lo expande al
# dibujar la barra, así que cambiar la opción en caliente no pide recargar.
segment='#{?window_zoomed_flag,[#{@zoom-flag-text}] ,}'

# Comprobar antes de añadir: con set -ga cada recarga lo duplicaría.
right=$(tmx show -gqv status-right)
[[ "$right" == *"$segment"* ]] || tmx set -g status-right "$segment$right"
