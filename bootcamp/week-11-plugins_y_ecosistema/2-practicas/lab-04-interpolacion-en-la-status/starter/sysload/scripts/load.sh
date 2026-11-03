#!/usr/bin/env bash
# load.sh — carga media del último minuto. La ejecuta tmux desde #(...) cada
# status-interval segundos.
set -euo pipefail

if [[ -r /proc/loadavg ]]; then
  read -r one _ </proc/loadavg
else
  # macOS: "{ 1.52 1.61 1.70 }"
  one=$(sysctl -n vm.loadavg | awk '{print $2}')
fi
printf '%s\n' "$one"
