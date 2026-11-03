#!/usr/bin/env bash
# TODO 5 la necesita: borra esta línea y la siguiente al terminar el TODO 5.
# shellcheck disable=SC2034
# install.sh — instala este kit enlazando su directorio en
# ${XDG_CONFIG_HOME:-$HOME/.config}/tmux. Repetirlo no debe cambiar nada.
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

# TODO 1: ruta absoluta y física del kit (el directorio de este script),
# funcione desde el cwd que sea:  kit=$(cd "$(dirname "$0")" && pwd -P)
kit=.

# TODO 2: respeta XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-$HOME/.config}/tmux
target="$HOME/.config/tmux"

# TODO 5: con --dry-run, imprime "haría: $*" en vez de ejecutar "$@".
#   if (( dry_run )); then ...; else "$@"; fi
run() {
  "$@"
}

# TODO 3: si "$target" ya es un enlace (-L) y readlink "$target" es "$kit",
# imprime "install.sh: ya instalado en $target" y sal con 0.

# TODO 4: si "$target" existe (-e) o es un enlace (-L, cubre el enlace roto),
# apártalo: backup="$target.bak.$(date +%Y%m%d-%H%M%S)", un echo que diga
# "install.sh: $target ya existe, lo muevo a $backup" y run mv ... .

run mkdir -p "$(dirname "$target")"
run ln -sfn "$kit" "$target"
echo "install.sh: $target -> $kit"
