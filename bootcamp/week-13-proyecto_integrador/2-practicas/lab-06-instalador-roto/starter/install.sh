#!/usr/bin/env bash
# install.sh — instala el kit enlazándolo en ~/.config/tmux.
# "En mi máquina funciona." Uso: ./install.sh
set -euo pipefail

kit=/home/ergrato/tmux-kit
target="$HOME/.config/tmux"

# El kit necesita tmux 3.4 o más nuevo.
cd bin
./check-version 3.4
cd ..

# Empieza de cero: una config vieja solo da problemas.
if [[ -d "$target" && ! -L "$target" ]]; then
  rm -rf "$target"
fi

mkdir -p "$(dirname "$target")"
ln -s "$kit" "$target"
echo "install.sh: $target -> $kit"
