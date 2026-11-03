#!/usr/bin/env bash
# Lab 04 — comprueba que recargar una config dos veces da el mismo estado
# (SOLUCIÓN).
# Uso: compare-reload.sh CONF
# Salida: 0 idéntico, 1 la segunda recarga cambia algo (y lo muestra).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

conf="${1:?uso: compare-reload.sh CONF}"

if ! tmx list-sessions >/dev/null 2>&1; then
  echo "compare-reload.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}" >&2
  exit 1
fi

# Todo lo que una config puede cambiar a nivel global: opciones de los tres
# alcances y todas las tablas de teclas.
state() { tmx show -s; tmx show -g; tmx show -gw; tmx list-keys; }

# Arrancar y recargar pueden diferir con razón (un unbind de algo que ya no
# está, por ejemplo); recargar y recargar no deberían.
tmx source-file "$conf"
before=$(state)
tmx source-file "$conf"
after=$(state)

if [[ "$before" == "$after" ]]; then
  echo "idéntico: recargar $conf no cambia nada"
else
  diff <(printf '%s\n' "$before") <(printf '%s\n' "$after") || true
  exit 1
fi
