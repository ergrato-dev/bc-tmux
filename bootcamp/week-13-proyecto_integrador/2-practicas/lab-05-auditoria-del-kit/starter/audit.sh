#!/usr/bin/env bash
# kit, failed, ok y fail aún no se usan: borra esta línea y la siguiente al terminar el TODO 5.
# shellcheck disable=SC2034,SC2317
# audit.sh — auditoría rápida de un tmux-kit antes de entregarlo.
#
# Uso: ./audit.sh RUTA_DEL_KIT   (TMUX_SOCKET elige el socket; por defecto kit-audit)
# Salida: una línea ✅/❌ por punto. Código: 0 todo bien, 1 algo falla,
# 2 uso incorrecto.
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1/tmux.conf" ]]; then
  echo "uso: audit.sh RUTA_DEL_KIT (la carpeta que tiene tmux.conf)" >&2
  exit 2
fi
kit=$(cd "$1" && pwd -P)
socket="${TMUX_SOCKET:-kit-audit}"
home=$(mktemp -d)

# HOME vacío y sin XDG_CONFIG_HOME: se mide el kit, no tu config.
tmx() { env -u XDG_CONFIG_HOME HOME="$home" "${TMUX_BIN:-tmux}" -L "$socket" "$@"; }
trap 'tmx kill-server 2>/dev/null || true; rm -rf "$home"' EXIT

failed=0
ok()   { echo "✅ $1"; }
fail() { echo "❌ $1${2:+: $2}"; failed=1; }

# TODO 1: punto "shellcheck limpio en bin/". Guarda la salida y mira el código:
#   if out=$(shellcheck "$kit"/bin/* 2>&1); then ok "..."; else fail "..." "<códigos>"; fi
# Los códigos (SC2162...) salen de: grep -o 'SC[0-9]*' <<< "$out" | sort -u | tr '\n' ' '

# TODO 2: punto "sin TODOs". Desde dentro del kit, para rutas cortas:
#   if todo=$(cd "$kit" && grep -rIn TODO .); then fail "sin TODOs" "$(head -1 <<< "$todo")"; else ok "sin TODOs"; fi

# TODO 3: punto "arranque en menos de 300 ms". EPOCHREALTIME (bash 5) da
# segundos con decimales; sin el separador son microsegundos:
#   t0=${EPOCHREALTIME/[.,]/}
#   tmx -f "$kit/tmux.conf" new-session -d -s audit
#   t1=${EPOCHREALTIME/[.,]/}
#   ms=$(( (t1 - t0) / 1000 ))
# y ok "arranque en $ms ms" si (( ms < 300 )); si no, fail "..." "$ms ms".

# TODO 4: punto "status-interval >= 5 con #() en la barra". Necesita el
# servidor del TODO 3. interval=$(tmx show -gv status-interval) y
# bars="$(tmx show -gv status-left)$(tmx show -gv status-right)". Falla si
# [[ "$bars" == *'#('* ]] && (( interval < 5 )).

# TODO 5: el código de salida es "$failed", no siempre 0.
exit 0
