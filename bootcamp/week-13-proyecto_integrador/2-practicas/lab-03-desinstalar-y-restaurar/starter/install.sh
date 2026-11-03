#!/usr/bin/env bash
# install.sh — instala este kit enlazando su directorio en
# ${XDG_CONFIG_HOME:-$HOME/.config}/tmux, y lo desinstala.
#
# Uso: ./install.sh [--dry-run] [--uninstall]
# Probar sin tocar tu HOME:
#   H=$(mktemp -d); env -u XDG_CONFIG_HOME HOME="$H" ./install.sh
# Códigos de salida: 0 bien, 1 el destino no es de este kit, 2 opción desconocida.
set -euo pipefail

dry_run=0
mode=install
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    # TODO 1: una rama más para --uninstall que ponga mode=uninstall.
    *) echo "install.sh: opción desconocida: $arg" >&2; exit 2 ;;
  esac
done

# Ruta física del kit: absoluta, sin depender del cwd ni de readlink -f
# (que no existe en macOS). Con una relativa el enlace quedaría roto.
kit=$(cd "$(dirname "$0")" && pwd -P)
target="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Con --dry-run imprime cada orden en vez de ejecutarla.
run() {
  if (( dry_run )); then echo "haría: $*"; else "$@"; fi
}

is_ours() { [[ -L "$target" && "$(readlink "$target")" == "$kit" ]]; }

uninstall() {
  # TODO 2: si "$target" no existe (! -e) y no es un enlace (! -L), imprime
  # "install.sh: no hay nada que desinstalar en $target" y return 0.

  # TODO 3: si no es nuestro (! is_ours), imprime en stderr (>&2)
  # "install.sh: $target no es un enlace a este kit, no lo toco" y return 1.

  # TODO 4: borra el enlace con run rm "$target" e imprime
  # "install.sh: enlace borrado: $target". Borra también el echo de abajo.
  echo "install.sh: --uninstall sin implementar" >&2

  # TODO 5: restaura el backup más reciente. shopt -s nullglob, luego
  # local backups=("$target".bak.*); si hay alguno (${#backups[@]} > 0), el
  # último es "${backups[${#backups[@]}-1]}": run mv "$last" "$target" y
  # echo "install.sh: restaurado $last".
}

if [[ "$mode" == uninstall ]]; then
  uninstall
  exit
fi

if is_ours; then
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
