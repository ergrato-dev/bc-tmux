#!/usr/bin/env bash
# install.sh — instala este kit enlazando su directorio en
# ${XDG_CONFIG_HOME:-$HOME/.config}/tmux. Repetirlo no cambia nada.
#
# Uso: ./install.sh [--dry-run]
# Probar sin tocar tu HOME:
#   H=$(mktemp -d); env -u XDG_CONFIG_HOME HOME="$H" ./install.sh
# Códigos de salida: 0 bien, 2 opción desconocida.
set -euo pipefail

dry_run=0
case "${1:-}" in
  "") ;;
  --dry-run) dry_run=1 ;;
  *) echo "install.sh: opción desconocida: $1" >&2; exit 2 ;;
esac

# Ruta física del kit: absoluta, sin depender del cwd ni de readlink -f
# (que no existe en macOS). Con una relativa el enlace quedaría roto.
kit=$(cd "$(dirname "$0")" && pwd -P)
target="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Con --dry-run imprime cada orden en vez de ejecutarla.
run() {
  if (( dry_run )); then echo "haría: $*"; else "$@"; fi
}

if [[ -L "$target" && "$(readlink "$target")" == "$kit" ]]; then
  echo "install.sh: ya instalado en $target"
  exit 0
fi

# Config real o enlace a otro sitio: se aparta, nunca se pisa. -L cubre
# también un enlace roto, que -e no ve.
if [[ -e "$target" || -L "$target" ]]; then
  backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
  echo "install.sh: $target ya existe, lo muevo a $backup"
  run mv "$target" "$backup"
fi

run mkdir -p "$(dirname "$target")"
# -n: si el destino es un enlace a un directorio, lo reemplaza en vez de
# crear el enlace dentro.
run ln -sfn "$kit" "$target"
echo "install.sh: $target -> $kit"
