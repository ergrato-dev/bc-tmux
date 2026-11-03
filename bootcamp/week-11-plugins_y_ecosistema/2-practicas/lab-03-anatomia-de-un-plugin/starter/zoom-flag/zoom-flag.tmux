#!/usr/bin/env bash
# zoom-flag.tmux — plugin mínimo: marca de zoom en status-right y una tecla
# para alternar el zoom del panel.
#
# Probar a mano contra el servidor del lab (desde la carpeta del lab):
#   tmux -L lab run-shell "$PWD/starter/zoom-flag/zoom-flag.tmux"; echo $?
# Opciones (se fijan antes de cargarlo):
#   @zoom-flag-key   tecla tras el prefix (por defecto: Z)
#   @zoom-flag-text  texto de la marca (por defecto: ZOOM)
set -euo pipefail

# run-shell lo ejecuta dentro del servidor: $TMUX ya apunta a él.
tmx() { "${TMUX_BIN:-tmux}" "$@"; }

# set_default OPCION VALOR — fija la opción solo si el usuario no lo hizo.
set_default() {
  # TODO 1: lee la opción con `tmx show -gqv "$1"` (-q: sin error si no
  # existe; -v: solo el valor) y, si sale vacía, fíjala con
  # `tmx set -g "$1" "$2"`. Borra el `:` de abajo.
  :
}

set_default @zoom-flag-key Z
set_default @zoom-flag-text ZOOM

# TODO 2: lee la tecla con `key=$(tmx show -gqv @zoom-flag-key)` y crea
# `tmx bind-key "$key" resize-pane -Z` (en la tabla prefix por defecto).

# El texto va como #{@zoom-flag-text}, no como su valor: tmux lo expande al
# dibujar la barra, así que cambiar la opción en caliente no pide recargar.
segment='#{?window_zoomed_flag,[#{@zoom-flag-text}] ,}'

# TODO 3: -ga añade el segmento otra vez en cada carga. Lee status-right
# con `tmx show -gqv status-right` y añádelo solo si no lo contiene:
#   [[ "$right" == *"$segment"* ]] || tmx set -g status-right "$segment$right"
# Después borra la línea de abajo.
tmx set -ga status-right "$segment"
