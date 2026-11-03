#!/usr/bin/env bash
# share.sh — comparte la sesión pair con un compañero en solo lectura.
#
# Uso (como alumno, desde la carpeta del lab): ./solucion/share.sh USUARIO
# Cerrar: tmux -S /tmp/lab-roto/pair kill-server; rm -rf /tmp/lab-roto
set -euo pipefail

user=${1:?uso: share.sh USUARIO}
dir=/tmp/lab-roto
sock=$dir/pair

tmx() { tmux -S "$sock" "$@"; }

mkdir -p "$dir"
# Fallo 1: con 0777 cualquier usuario de la máquina llega al servidor y solo
# lo para server-access. 710 y grupo pair: entra quien está en el grupo y
# nadie lista el directorio.
chgrp pair "$dir"
chmod 0710 "$dir"

if ! tmx has-session -t "=pair" 2>/dev/null; then
  tmx -f /dev/null new-session -d -s pair
fi

# Relativo: tmux pone y quita la x del socket según haya clientes.
chgrp pair "$sock"
chmod g+rw,o= "$sock"

# Fallo 2: attach -r es una petición del cliente, no un límite. Con (W) el
# invitado manda send-keys sin conectarse o se quita el -r con
# switch-client -r. Solo server-access -r lo impide.
tmx server-access -a -r "$user" 2>/dev/null || tmx server-access -r "$user"
tmx server-access -l
echo "$user: tmux -S $sock attach -t pair"
