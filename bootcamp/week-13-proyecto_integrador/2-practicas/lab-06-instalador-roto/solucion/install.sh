#!/usr/bin/env bash
# install.sh — instala el kit enlazando su directorio en
# ${XDG_CONFIG_HOME:-$HOME/.config}/tmux. Repetirlo no cambia nada.
# Uso: ./install.sh
set -euo pipefail

# Fallo 2: la ruta del kit se calcula, no se escribe. Física y absoluta para
# que el enlace funcione desde cualquier sitio.
kit=$(cd "$(dirname "$0")" && pwd -P)
# Fallo 5: quien define XDG_CONFIG_HOME tiene ahí su config.
target="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Fallo 1: rutas desde $kit, nunca desde el cwd de quien lo lanza.
"$kit/bin/check-version" 3.4

# Fallo 3: lo que ya es nuestro no se vuelve a tocar.
if [[ -L "$target" && "$(readlink "$target")" == "$kit" ]]; then
  echo "install.sh: ya instalado en $target"
  exit 0
fi

# Fallo 4: la config del usuario se aparta con fecha, nunca se borra. -L
# cubre también un enlace a otro sitio o roto.
if [[ -e "$target" || -L "$target" ]]; then
  backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
  echo "install.sh: $target ya existe, lo muevo a $backup"
  mv "$target" "$backup"
fi

mkdir -p "$(dirname "$target")"
# Fallo 3: -n reemplaza un enlace a directorio en vez de crear otro dentro.
ln -sfn "$kit" "$target"
echo "install.sh: $target -> $kit"
