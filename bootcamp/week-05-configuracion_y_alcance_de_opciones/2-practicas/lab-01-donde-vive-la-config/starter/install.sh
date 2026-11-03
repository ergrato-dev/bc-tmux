#!/usr/bin/env bash
# Lab 01 — instala un directorio de config como ~/.config/tmux (un enlace).
# Uso: install.sh DIR
# Salida: 0 instalado o ya estaba, 1 el destino ya existe, 2 uso incorrecto.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: install.sh DIR" >&2; exit 2; }

target="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# TODO 1: si DIR no tiene tmux.conf, imprime por stderr
#         "install.sh: DIR no tiene tmux.conf" y sal con 2.
#         Después: dir=$(cd "$1" && pwd). Un enlace relativo apuntaría a otro
#         sitio.
# TODO 2: if: si $target es un enlace (-L) y "$(readlink "$target")" es
#         "$dir", imprime "ya instalado: DESTINO -> DIR" y NO salgas (el aviso
#         del TODO 4 tiene que verse igual).
#         elif: si existe y es otra cosa (-e o -L), imprime por stderr
#         "install.sh: ya existe DESTINO: muévelo tú antes" y sal con 1.
# TODO 3: else: mkdir -p del directorio padre, ln -s "$dir" "$target" e
#         imprime "instalado: DESTINO -> DIR".
# TODO 4: fuera del if: si existe "$HOME/.tmux.conf", imprime por stderr
#         "aviso: HOME/.tmux.conf también se carga, antes que la tuya".
#         Borra las dos líneas de abajo.
echo "install.sh: sin implementar ($1 -> $target)" >&2
exit 1
