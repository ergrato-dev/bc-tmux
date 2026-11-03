#!/usr/bin/env bash
# Lab 05 — copia su entrada estándar al portapapeles de tu sistema (SOLUCIÓN).
# Uso: ... | copy.sh
# Salida: 0 copiado, 1 no hay portapapeles o falta la herramienta.
set -euo pipefail

has() { command -v "$1" >/dev/null 2>&1; }
missing() { echo "copy.sh: $1" >&2; exit 1; }

# El orden importa: WSL con WSLg también define WAYLAND_DISPLAY y DISPLAY,
# así que WSL se mira antes que Wayland y X11.
if [[ "$(uname)" == Darwin ]]; then
  pbcopy
elif [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
  # clip.exe lee la entrada con la página de códigos de Windows: la ñ y las
  # tildes llegan rotas. win32yank.exe respeta UTF-8.
  if has win32yank.exe; then win32yank.exe -i
  elif has clip.exe; then clip.exe
  else missing "no encuentro clip.exe: ¿está activada la interoperabilidad de WSL?"
  fi
elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
  has wl-copy || missing "instala wl-clipboard (sudo apt install wl-clipboard)"
  wl-copy
elif [[ -n "${DISPLAY:-}" ]]; then
  # Sin -selection clipboard, xclip escribe en PRIMARY: se pega con el botón
  # central, no con Ctrl+V.
  if has xclip; then xclip -selection clipboard
  elif has xsel; then xsel --clipboard --input
  else missing "instala xclip (sudo apt install xclip)"
  fi
else
  missing "no hay portapapeles gráfico (¿SSH o contenedor?): lo resuelve OSC 52, en el lab 06"
fi
