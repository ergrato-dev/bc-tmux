# Diagnóstico de terminal

Síntoma → causa → comando. Los comandos con `#{client_*}` o `show-messages`
se lanzan **desde dentro de tmux**: necesitan un cliente conectado.

<!-- TODO 9: una sección "## ..." por síntoma, cada una con causa, un comando
para comprobarlo (con su salida esperada) y el arreglo:
  - colores lavados o distintos que fuera de tmux
  - undercurl ausente
  - Esc llega tarde
  - C-Enter no llega al programa
  - portapapeles roto
Empieza con una sección para aislar el problema: kit-doctor, tmux -f /dev/null,
tmux -vvv y show-messages (lab-06-depurar-una-terminal-rota). -->
