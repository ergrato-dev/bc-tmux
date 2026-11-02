#!/usr/bin/env bash
# Imprime un número por segundo. Sirve para ver que un programa sigue
# corriendo aunque no estés conectado a la sesión. Ctrl+c para parar.
set -euo pipefail

n=0
while true; do
  n=$(( n + 1 ))
  printf '%s  segundo %d\n' "$(date +%T)" "$n"
  sleep 1
done
