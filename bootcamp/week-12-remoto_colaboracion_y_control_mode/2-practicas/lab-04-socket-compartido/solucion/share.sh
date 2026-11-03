#!/usr/bin/env bash
# share.sh — comparte la sesión pair con otro usuario, en solo lectura.
#
# Uso (como alumno, desde la carpeta del lab): ./solucion/share.sh USUARIO
# Repetirlo no rompe nada: reutiliza el servidor y deja al usuario en (R).
# Cerrar: tmux -S /tmp/lab-pair/pair kill-server; rm -rf /tmp/lab-pair
set -euo pipefail

user=${1:?uso: share.sh USUARIO}
dir=/tmp/lab-pair
sock=$dir/pair
conf=$(cd "$(dirname "$0")" && pwd)/tmux.conf

# -L no sirve para compartir: vive en /tmp/tmux-UID, un directorio 0700.
tmx() { tmux -S "$sock" "$@"; }

echo "share.sh: compartiendo pair con $user"
mkdir -p "$dir"

# 710: el grupo pair atraviesa el directorio hasta el socket, pero no lo lista.
chgrp pair "$dir"
chmod 0710 "$dir"

if ! tmx has-session -t "=pair" 2>/dev/null; then
  tmx -f "$conf" new-session -d -s pair
fi

# tmux crea el socket 600 y le pone o quita la x según haya clientes: chmod
# relativo para no tocar esa x. o= deja fuera a quien no esté en pair.
chgrp pair "$sock"
chmod g+rw,o= "$sock"

# Los permisos solo dejan llegar al servidor; quién entra y cómo lo decide
# server-access. -a sin -r daría escritura. Si ya estaba, -a falla y -r
# solo cambia el modo.
tmx server-access -a -r "$user" 2>/dev/null || tmx server-access -r "$user"
tmx server-access -l
