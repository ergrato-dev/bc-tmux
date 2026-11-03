#!/usr/bin/env bash
# Lab 06 — copia su entrada estándar al portapapeles de tu terminal con OSC 52.
# Uso: ... | osc52.sh
# OSC52_TTY cambia el destino (para ver la secuencia en un archivo).
set -euo pipefail

data=$(base64)
printf '\033]52;c;%s\a' "$data" >"${OSC52_TTY:-/dev/tty}"
