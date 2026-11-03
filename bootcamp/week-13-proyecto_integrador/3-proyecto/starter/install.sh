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

# TODO 1 (lab-01-enlaces-y-xdg): kit = ruta absoluta y real del directorio de
# este script, válida aunque lo lances desde otro directorio o como
# ./install.sh: $(cd "$(dirname "$0")" && pwd -P). dest = la carpeta tmux
# dentro de ${XDG_CONFIG_HOME:-$HOME/.config}.
kit=""
dest=""

# TODO 4 (lab-02-instalador-idempotente): con --dry-run (dry=1), imprime
# "(dry-run) " y el comando, sin ejecutarlo. Sin --dry-run, imprime el comando
# y lo ejecuta ("$@"). Borra el : "$dry", que solo calla a shellcheck.
run() { : "$dry"; "$@"; }

exists() { [[ -e "$1" || -L "$1" ]]; }

# TODO 2 (lab-03-desinstalar-y-restaurar): is_ours sale con 0 solo si $dest es
# un enlace (-L) y, entrando en él, pwd -P da $kit. Un directorio real o un
# enlace a otro sitio es config de alguien: nunca se borra.
is_ours() { false; }

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
  # TODO 5 (lab-05-auditoria-del-kit): antes de nada, "$kit/bin/check-version"
  # (su salida a /dev/null); si falla, exit 1. Al final, si existe
  # "$HOME/.tmux.conf", un aviso por stderr que lo nombre: tmux lo carga
  # junto al kit.

  # TODO 3 (lab-02-instalador-idempotente): si is_ours, solo dilo (exit 0). Si
  # no y $dest existe, run mv a "$(backup_name)". Después run mkdir -p del
  # directorio padre y run ln -sfn "$kit" "$dest". Borra el : "$kit" y el die.
  : "$kit"
  die "instalar sin implementar"
}

uninstall_kit() {
  # TODO 6 (lab-03-desinstalar-y-restaurar): si $dest no existe, dilo y
  # return (sale con 0). Si no es is_ours, die. Si lo es, run rm "$dest" y,
  # si hay backups ("$dest".bak.* con shopt -s nullglob), run mv del último
  # a "$dest". Sin ${array[-1]}: el bash 3.2 de macOS no lo entiende.
  die "--uninstall sin implementar"
}

case "$mode" in
  install) install_kit ;;
  uninstall) uninstall_kit ;;
esac
