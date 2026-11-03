#!/usr/bin/env bash
# Simula un trabajo largo: escribe una línea por segundo en un log.
# Uso: long-task.sh <log> [segundos]   (sin segundos: hasta que la paren)
set -euo pipefail

log="${1:?uso: long-task.sh <log> [segundos]}"
total="${2:-0}"

n=0
while (( total == 0 || n < total )); do
  n=$(( n + 1 ))
  printf '%s  paso %d\n' "$(date +%T)" "$n" | tee -a "$log"
  sleep 1
done
