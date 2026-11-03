#!/usr/bin/env bash
# share.sh — comparte la sesión pair con otro usuario, en solo lectura.
#
# Uso (como alumno, desde la carpeta del lab): ./starter/share.sh USUARIO
# Repetirlo no debe romper nada: reutiliza el servidor y deja al usuario en (R).
# Cerrar: tmux -S /tmp/lab-pair/pair kill-server; rm -rf /tmp/lab-pair
set -euo pipefail

user=${1:?uso: share.sh USUARIO}
dir=/tmp/lab-pair
sock=$dir/pair

# -L no sirve para compartir: vive en /tmp/tmux-UID, un directorio 0700.
tmx() { tmux -S "$sock" "$@"; }

echo "share.sh: compartiendo pair con $user"
mkdir -p "$dir"

# TODO 1: el directorio, del grupo pair y en modo 0710 (el grupo lo atraviesa
# pero no lo lista). Dos órdenes: chgrp pair "$dir"  y  chmod ...

# TODO 2: arranca el servidor solo si no existe la sesión, con la config de
# esta carpeta. Patrón idempotente:
#   if ! tmx has-session -t "=pair" 2>/dev/null; then
#     tmx -f "$(cd "$(dirname "$0")" && pwd)/tmux.conf" new-session -d -s pair
#   fi

# TODO 3: el socket ("$sock"), del grupo pair, con rw para el grupo y nada
# para el resto. chmod relativo (g+rw,o=): tmux pone y quita la x él solo.

# TODO 4: deja entrar a "$user" en solo lectura con server-access -a -r. Si
# ya estaba, -a falla: en ese caso server-access -r (sin -a) cambia el modo.
#   tmx server-access -a -r "$user" 2>/dev/null || tmx server-access ...
# Termina listando quién entra: tmx server-access -l
