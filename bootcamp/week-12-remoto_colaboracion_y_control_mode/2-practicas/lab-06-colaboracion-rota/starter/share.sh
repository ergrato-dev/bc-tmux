#!/usr/bin/env bash
# share.sh — comparte la sesión pair con un compañero "en solo lectura".
# ROTO A PROPÓSITO (lab-06): pasa shellcheck y funciona, pero no protege nada.
#
# Uso (como alumno, desde la carpeta del lab): ./starter/share.sh USUARIO
# Cerrar: tmux -S /tmp/lab-roto/pair kill-server; rm -rf /tmp/lab-roto
set -euo pipefail

user=${1:?uso: share.sh USUARIO}
dir=/tmp/lab-roto
sock=$dir/pair

tmx() { tmux -S "$sock" "$@"; }

mkdir -p "$dir"
chmod 0777 "$dir"

if ! tmx has-session -t "=pair" 2>/dev/null; then
  tmx -f /dev/null new-session -d -s pair
fi

# Así entra cualquiera, sin líos de grupos.
chmod 0777 "$sock"

# El invitado se conecta con attach -r: solo puede mirar.
tmx server-access -a "$user" 2>/dev/null || true
tmx server-access -l
echo "$user: tmux -S $sock attach -r -t pair"
