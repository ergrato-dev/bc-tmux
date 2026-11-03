#!/usr/bin/env bash
# install.sh — instala tmux-kit enlazando este directorio como config de tmux.
#
# Uso: install.sh                enlaza el kit en ${XDG_CONFIG_HOME:-~/.config}/tmux
#      install.sh --dry-run      dice lo que haría, sin tocar nada (vale con --uninstall)
#      install.sh --uninstall    quita el enlace, solo si apunta a este kit, y restaura el último backup
#      install.sh -h | --help    esta ayuda
# Salida: 0 bien (también si no había nada que hacer), 1 tmux viejo, enlace ajeno o fallo, 2 uso incorrecto.
set -euo pipefail

usage() { sed -n '4,8s/^# \{0,1\}//p' "$0"; }
die() { echo "install.sh: $*" >&2; exit 1; }

dry=0
mode=install
while (( $# )); do
  case "$1" in
    --dry-run) dry=1 ;;
    --uninstall) mode=uninstall ;;
    -h | --help) usage; exit 0 ;;
    *) echo "install.sh: opción desconocida: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

# pwd -P da la ruta real del kit aunque lances el script desde otro directorio
# o por un camino con enlaces. readlink -f no existe en el macOS de serie.
kit=$(cd "$(dirname "$0")" && pwd -P)
dest="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"

# Imprime cada cambio y, salvo con --dry-run, lo hace.
run() {
  if (( dry )); then
    echo "(dry-run) $*"
  else
    echo "$*"
    "$@"
  fi
}

# Solo un enlace que lleva a este kit es "nuestro": un directorio real o un
# enlace a otro sitio es config de alguien y nunca se borra.
is_ours() {
  [[ -L "$dest" ]] && [[ "$(cd "$dest" 2>/dev/null && pwd -P)" == "$kit" ]]
}

exists() { [[ -e "$1" || -L "$1" ]]; }

# Backup con fecha y hora; el sufijo -N evita pisar otro del mismo segundo.
backup_name() {
  local base name n=1
  base="$dest.bak.$(date +%Y%m%d-%H%M%S)"
  name=$base
  while exists "$name"; do
    name="$base-$n"
    n=$(( n + 1 ))
  done
  echo "$name"
}

install_kit() {
  # check-version explica el problema por stderr; aquí solo importa si cumple.
  "$kit/bin/check-version" >/dev/null || exit 1

  if is_ours; then
    echo "tmux-kit ya está instalado: $dest -> $kit"
  else
    if exists "$dest"; then
      run mv "$dest" "$(backup_name)"
    fi
    run mkdir -p "$(dirname "$dest")"
    # -n: si $dest ya fuera un enlace a un directorio, sin -n ln crearía el
    # enlace DENTRO de ese directorio en vez de reemplazarlo.
    run ln -sfn "$kit" "$dest"
  fi

  # tmux carga todos los archivos de config que existen, y ~/.tmux.conf va
  # antes que el de XDG: lo que tenga se mezcla con el kit.
  if [[ -e "$HOME/.tmux.conf" ]]; then
    echo "aviso: también existe ~/.tmux.conf y tmux lo carga junto al kit; muévelo si no lo quieres" >&2
  fi
}

uninstall_kit() {
  if ! exists "$dest"; then
    echo "tmux-kit no está instalado en $dest: nada que hacer"
    return
  fi
  is_ours || die "$dest no es un enlace a este kit ($kit): no lo toco"

  run rm "$dest"
  # El glob sale ordenado y la fecha va de año a segundo: el último es el más
  # nuevo. Sin ${backups[-1]}: el bash 3.2 de macOS no lo entiende.
  local backups
  shopt -s nullglob
  backups=("$dest".bak.*)
  if (( ${#backups[@]} )); then
    run mv "${backups[${#backups[@]}-1]}" "$dest"
  fi
}

case "$mode" in
  install) install_kit ;;
  uninstall) uninstall_kit ;;
esac
