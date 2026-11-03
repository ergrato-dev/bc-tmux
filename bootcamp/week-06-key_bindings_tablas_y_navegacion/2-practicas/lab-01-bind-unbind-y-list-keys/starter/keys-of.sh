#!/usr/bin/env bash
# Lab 01 — teclas de una tabla que tienen nota (bind -N).
# Uso: keys-of.sh TABLA
# Imprime "TECLA NOTA" por cada tecla con nota y, al final,
# "con nota: N de M".
# Salida: 0 bien, 1 sin servidor o tabla inexistente, 2 uso incorrecto.
set -euo pipefail

tmx() { tmux -L "${TMUX_SOCKET:-lab}" "$@"; }

# TODO 1: exactamente un argumento. Si no: "uso: keys-of.sh TABLA" por
#         stderr y exit 2. Pista: if [[ $# -ne 1 ]]; then ...; fi
#         Después: table="$1"

# TODO 2: hay servidor. Pista: tmx list-sessions >/dev/null 2>&1 || { ...; }
#         Si falla: "keys-of.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}"
#         por stderr y exit 1.

# TODO 3: la tabla existe. list-keys -T con una tabla que no existe falla.
#         Pista: if ! all=$(tmx list-keys -T "$table" 2>/dev/null); then ...
#         Si falla: "keys-of.sh: no existe la tabla TABLA" por stderr y exit 1.

# TODO 4: imprime las teclas con nota (tmx list-keys -N -T "$table") y la
#         línea "con nota: N de M": N con list-keys -N ... | wc -l y M con
#         printf '%s\n' "$all" | wc -l. Borra las dos líneas de abajo.
echo "keys-of.sh: sin implementar" >&2
exit 1
