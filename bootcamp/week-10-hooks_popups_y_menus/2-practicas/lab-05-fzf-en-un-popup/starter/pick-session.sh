#!/usr/bin/env bash
# pick-session.sh — elige una sesión y cambia el cliente a ella.
#
# Uso: pick-session.sh [-l]
#   sin argumentos: elige con fzf (o, sin fzf, con una lista numerada) y
#                   hace switch-client. Pensado para display-popup -E.
#   -l:             solo lista las sesiones: "id nombre", una por línea.
# FZF_BIN cambia el fzf que se usa (FZF_BIN=no-fzf simula que no está).
# Salida: 0 bien o cancelado, 1 tmux falla, 2 uso incorrecto.
set -euo pipefail

tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

case $# in
  0) list_only=0 ;;
  1) [[ $1 == -l ]] || { echo "uso: pick-session.sh [-l]" >&2; exit 2; }; list_only=1 ;;
  *) echo "uso: pick-session.sh [-l]" >&2; exit 2 ;;
esac

# TODO 1: una línea por sesión con el id delante: "$0 lab". Un nombre que
# empieza por $ no se encuentra con -t "=nombre"; el id siempre. Cambia la
# línea sessions= por:
#   sessions=$(tmx list-sessions -F '#{session_id} #{session_name}')
sessions="sin implementar"
if (( list_only )); then
  printf '%s\n' "$sessions"
  exit 0
fi

fzf_bin=${FZF_BIN:-fzf}
if command -v "$fzf_bin" >/dev/null; then
  # TODO 2: elige con fzf. --with-nth 2.. muestra y busca solo el nombre,
  # pero devuelve la línea entera. Escape o C-c salen con 130: no es un
  # error, así que || exit 0. Cambia la línea sel= por:
  #   sel=$(printf '%s\n' "$sessions" | "$fzf_bin" --with-nth 2.. --prompt 'sesión> ' --reverse) || exit 0
  sel="$sessions"
else
  # TODO 3: sin fzf, una lista numerada con select, que lee de la terminal
  # y repite la pregunta si el número no vale. Cambia la línea sel= por:
  #   mapfile -t lines <<<"$sessions"
  #   PS3='número (C-d cancela): '
  #   select sel in "${lines[@]}"; do [[ -n $sel ]] && break; done
  sel=""
  [[ -n ${sel:-} ]] || exit 0
fi

# TODO 4: cambia el cliente a la sesión elegida por su id (lo que hay antes
# del primer espacio). Va como argumento, nunca dentro de un comando:
#   tmx switch-client -t "${sel%% *}"
# y borra la línea de abajo.
echo "pick-session: elegiste '$sel' (sin implementar)"
