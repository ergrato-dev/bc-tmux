#!/usr/bin/env bash
# Lab 04 — comprueba que recargar una config dos veces da el mismo estado
# (SOLUCIÓN).
# Uso: comparar-recarga.sh CONF
# Salida: 0 idéntico, 1 la segunda recarga cambia algo (y lo muestra).
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

conf="${1:?uso: comparar-recarga.sh CONF}"

if ! tmx list-sessions >/dev/null 2>&1; then
  echo "comparar-recarga.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}" >&2
  exit 1
fi

# Todo lo que una config puede cambiar a nivel global: opciones de los tres
# alcances y todas las tablas de teclas.
estado() { tmx show -s; tmx show -g; tmx show -gw; tmx list-keys; }

# Arrancar y recargar pueden diferir con razón (un unbind de algo que ya no
# está, por ejemplo); recargar y recargar no deberían.
tmx source-file "$conf"
antes=$(estado)
tmx source-file "$conf"
despues=$(estado)

if [[ "$antes" == "$despues" ]]; then
  echo "idéntico: recargar $conf no cambia nada"
else
  diff <(printf '%s\n' "$antes") <(printf '%s\n' "$despues") || true
  exit 1
fi
