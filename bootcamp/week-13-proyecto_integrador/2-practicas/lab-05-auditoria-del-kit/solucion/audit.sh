#!/usr/bin/env bash
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

if out=$(shellcheck "$kit"/bin/* 2>&1); then
  ok "shellcheck limpio en bin/"
else
  fail "shellcheck limpio en bin/" "$(grep -o 'SC[0-9]*' <<< "$out" | sort -u | tr '\n' ' ')"
fi

# Desde dentro del kit, para que la ruta salga corta (./conf.d/...).
if todo=$(cd "$kit" && grep -rIn TODO .); then
  fail "sin TODOs" "$(head -1 <<< "$todo")"
else
  ok "sin TODOs"
fi

# Microsegundos desde EPOCHREALTIME (bash 5) sin el separador decimal, que
# según el locale es punto o coma. date +%N no existe en macOS.
t0=${EPOCHREALTIME/[.,]/}
tmx -f "$kit/tmux.conf" new-session -d -s audit
t1=${EPOCHREALTIME/[.,]/}
ms=$(( (t1 - t0) / 1000 ))
if (( ms < 300 )); then
  ok "arranque en $ms ms"
else
  fail "arranque en menos de 300 ms" "$ms ms"
fi

# Cada #() se relanza en cada refresco de la barra: con un intervalo corto,
# un comando lento está siempre corriendo.
interval=$(tmx show -gv status-interval)
bars="$(tmx show -gv status-left)$(tmx show -gv status-right)"
if [[ "$bars" == *'#('* ]] && (( interval < 5 )); then
  fail "status-interval >= 5 con #() en la barra" "status-interval $interval"
else
  ok "status-interval $interval"
fi

exit "$failed"
