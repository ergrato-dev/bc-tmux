#!/usr/bin/env bash
# Lab 01 — instala un directorio de config como ~/.config/tmux (un enlace).
# Uso: instalar.sh DIR
# Salida: 0 instalado o ya estaba, 1 el destino ya existe, 2 uso incorrecto.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: instalar.sh DIR" >&2; exit 2; }

destino="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# TODO 1: si DIR no tiene tmux.conf, avisa y sal con 2. Convierte DIR en ruta
#         absoluta (cd "$1" && pwd): un enlace relativo apuntaría a otro sitio.
# TODO 2: si $destino ya es un enlace a DIR (readlink), di "ya instalado:
#         DESTINO -> DIR" y sal con 0. Si existe y es otra cosa, sal con 1 sin
#         tocarlo: "ya existe DESTINO: muévelo tú antes".
# TODO 3: crea el directorio padre, enlaza y di "instalado: DESTINO -> DIR".
# TODO 4: si existe ~/.tmux.conf, avisa por stderr de que también se carga,
#         antes que la tuya.
echo "instalar.sh: sin implementar ($1 -> $destino)" >&2
exit 1
