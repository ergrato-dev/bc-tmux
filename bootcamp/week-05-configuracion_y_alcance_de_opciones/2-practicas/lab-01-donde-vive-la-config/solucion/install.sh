#!/usr/bin/env bash
# Lab 01 — instala un directorio de config como ~/.config/tmux (un enlace)
# (SOLUCIÓN).
# Uso: install.sh DIR
# Salida: 0 instalado o ya estaba, 1 el destino ya existe, 2 uso incorrecto.
set -euo pipefail

[[ $# -eq 1 ]] || { echo "uso: install.sh DIR" >&2; exit 2; }

target="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

if [[ ! -f "$1/tmux.conf" ]]; then
  echo "install.sh: $1 no tiene tmux.conf" >&2
  exit 2
fi
# Un enlace guarda la ruta tal cual: relativa, se resolvería desde
# ~/.config/, no desde donde ejecutaste el script.
dir=$(cd "$1" && pwd)

if [[ -L "$target" && "$(readlink "$target")" == "$dir" ]]; then
  echo "ya instalado: $target -> $dir"
elif [[ -e "$target" || -L "$target" ]]; then
  # Nunca se borra la config de nadie: que la mueva quien sabe qué es.
  echo "install.sh: ya existe $target: muévelo tú antes" >&2
  exit 1
else
  mkdir -p "$(dirname "$target")"
  ln -s "$dir" "$target"
  echo "instalado: $target -> $dir"
fi

# tmux carga ~/.tmux.conf y después la de ~/.config/tmux: lo que la tuya no
# pise, sigue viniendo del archivo viejo.
if [[ -e "$HOME/.tmux.conf" ]]; then
  echo "aviso: $HOME/.tmux.conf también se carga, antes que la tuya" >&2
fi
