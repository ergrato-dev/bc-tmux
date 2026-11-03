#!/usr/bin/env bash
# Lab 05 — copia su entrada estándar al portapapeles de tu sistema.
# Uso: ... | copiar.sh
# Salida: 0 copiado, 1 no hay portapapeles o falta la herramienta.
set -euo pipefail

hay() { command -v "$1" >/dev/null 2>&1; }
falta() { echo "copiar.sh: $1" >&2; exit 1; }

# El orden importa: WSL con WSLg también define WAYLAND_DISPLAY y DISPLAY,
# así que WSL se mira antes que Wayland y X11.
if [[ "$(uname)" == Darwin ]]; then
  pbcopy
elif [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  # TODO 1: borra la línea "falta ... sin implementar". win32yank.exe -i si
  #         está; si no, clip.exe; si no, falta con
  #         "no encuentro clip.exe: ¿está activada la interoperabilidad de WSL?"
  #         Pista: if hay win32yank.exe; then win32yank.exe -i
  #                elif hay clip.exe; then clip.exe
  #                else falta "..."; fi
  falta "WSL sin implementar"
elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  hay wl-copy || falta "instala wl-clipboard (sudo apt install wl-clipboard)"
  wl-copy
elif [[ -n "${DISPLAY:-}" ]]; then
  # TODO 2: borra la línea "falta ... sin implementar". xclip en la selección
  #         CLIPBOARD (xclip -selection clipboard) si está; si no,
  #         xsel --clipboard --input; si no, falta con
  #         "instala xclip (sudo apt install xclip)". Misma forma que el TODO 1.
  falta "X11 sin implementar"
else
  falta "no hay portapapeles gráfico (¿SSH o contenedor?): lo resuelve OSC 52, en el lab 06"
fi
