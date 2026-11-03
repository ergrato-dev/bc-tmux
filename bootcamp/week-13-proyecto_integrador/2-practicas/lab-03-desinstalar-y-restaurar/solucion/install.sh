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
    --uninstall) mode=uninstall ;;
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
  if [[ ! -e "$target" && ! -L "$target" ]]; then
    echo "install.sh: no hay nada que desinstalar en $target"
    return 0
  fi
  # Solo se borra lo que este kit creó: una config real o el enlace de otro
  # kit no son nuestros.
  if ! is_ours; then
    echo "install.sh: $target no es un enlace a este kit, no lo toco" >&2
    return 1
  fi
  run rm "$target"
  echo "install.sh: enlace borrado: $target"

  # El nombre lleva la fecha (AAAAMMDD-HHMMSS): el glob, ordenado por
  # nombre, deja el más reciente al final. nullglob: sin backups, lista vacía.
  shopt -s nullglob
  local backups=("$target".bak.*)
  if (( ${#backups[@]} > 0 )); then
    local last="${backups[${#backups[@]}-1]}"
    run mv "$last" "$target"
    echo "install.sh: restaurado $last"
  fi
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
