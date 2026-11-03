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

# El id ($0, $1...) delante: un nombre que empieza por $ no se encuentra
# con -t "=nombre", el id siempre.
sessions=$(tmx list-sessions -F '#{session_id} #{session_name}')
if (( list_only )); then
  printf '%s\n' "$sessions"
  exit 0
fi

fzf_bin=${FZF_BIN:-fzf}
if command -v "$fzf_bin" >/dev/null; then
  # --with-nth 2..: fzf muestra y busca solo el nombre, pero devuelve la
  # línea entera. Escape o C-c salen con 130: el popup se cierra sin más.
  sel=$(printf '%s\n' "$sessions" | "$fzf_bin" --with-nth 2.. --prompt 'sesión> ' --reverse) || exit 0
else
  mapfile -t lines <<<"$sessions"
  PS3='número (C-d cancela): '
  select sel in "${lines[@]}"; do [[ -n $sel ]] && break; done
  [[ -n ${sel:-} ]] || exit 0
fi

# El id va como argumento, nunca dentro de un comando ni de send-keys: un
# $(...) o un ; en el nombre de la sesión no ejecutan nada.
tmx switch-client -t "${sel%% *}"
