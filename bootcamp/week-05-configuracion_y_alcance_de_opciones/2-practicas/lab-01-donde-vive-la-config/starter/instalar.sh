#!/usr/bin/env bash
# Lab 01 — instala un directorio de config como ~/.config/tmux (un enlace).
# Uso: instalar.sh DIR
# Salida: 0 instalado o ya estaba, 1 el destino ya existe, 2 uso incorrecto.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: instalar.sh DIR" >&2; exit 2; }

destino="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# TODO 1: si DIR no tiene tmux.conf, imprime por stderr
#         "instalar.sh: DIR no tiene tmux.conf" y sal con 2.
#         Después: dir=$(cd "$1" && pwd). Un enlace relativo apuntaría a otro
#         sitio.
# TODO 2: if: si $destino es un enlace (-L) y "$(readlink "$destino")" es
#         "$dir", imprime "ya instalado: DESTINO -> DIR" y NO salgas (el aviso
#         del TODO 4 tiene que verse igual).
#         elif: si existe y es otra cosa (-e o -L), imprime por stderr
#         "instalar.sh: ya existe DESTINO: muévelo tú antes" y sal con 1.
# TODO 3: else: mkdir -p del directorio padre, ln -s "$dir" "$destino" e
#         imprime "instalado: DESTINO -> DIR".
# TODO 4: fuera del if: si existe "$HOME/.tmux.conf", imprime por stderr
#         "aviso: HOME/.tmux.conf también se carga, antes que la tuya".
#         Borra las dos líneas de abajo.
echo "instalar.sh: sin implementar ($1 -> $destino)" >&2
exit 1
