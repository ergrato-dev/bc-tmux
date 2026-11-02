#!/usr/bin/env bash
# Lab 01 — instala un directorio de config como ~/.config/tmux (un enlace)
# (SOLUCIÓN).
# Uso: instalar.sh DIR
# Salida: 0 instalado o ya estaba, 1 el destino ya existe, 2 uso incorrecto.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: instalar.sh DIR" >&2; exit 2; }

destino="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

if [[ ! -f "$1/tmux.conf" ]]; then
  echo "instalar.sh: $1 no tiene tmux.conf" >&2
  exit 2
fi
# Un enlace guarda la ruta tal cual: relativa, se resolvería desde
# ~/.config/, no desde donde ejecutaste el script.
dir=$(cd "$1" && pwd)

if [[ -L "$destino" && "$(readlink "$destino")" == "$dir" ]]; then
  echo "ya instalado: $destino -> $dir"
elif [[ -e "$destino" || -L "$destino" ]]; then
  # Nunca se borra la config de nadie: que la mueva quien sabe qué es.
  echo "instalar.sh: ya existe $destino: muévelo tú antes" >&2
  exit 1
else
  mkdir -p "$(dirname "$destino")"
  ln -s "$dir" "$destino"
  echo "instalado: $destino -> $dir"
fi

# tmux carga ~/.tmux.conf y después la de ~/.config/tmux: lo que la tuya no
# pise, sigue viniendo del archivo viejo.
if [[ -e "$HOME/.tmux.conf" ]]; then
  echo "aviso: $HOME/.tmux.conf también se carga, antes que la tuya" >&2
fi
