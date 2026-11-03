# Glosario — Semana 08

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **TERM de fuera** | El `TERM` de tu terminal, que el cliente lee al conectarse y tmux guarda en `#{client_termname}` | `xterm-256color` |
| **TERM de dentro** | El `TERM` con que nace cada panel, fijado por `default-terminal` | `set -s default-terminal tmux-256color` |
| **terminfo** | Base de datos que describe qué secuencias entiende cada tipo de terminal | `/usr/share/terminfo/t/tmux-256color` |
| **capacidad** | Entrada de terminfo: booleana, número o cadena con su secuencia | `colors#256`, `Smulx=\E[4:%p1%dm` |
| **infocmp** | Imprime una entrada terminfo; `-x` incluye las capacidades extendidas | `infocmp -x tmux-256color` |
| **tic** | Compila una entrada terminfo; con `TERMINFO=dir` la deja fuera del sistema | `TERMINFO=/tmp/ti tic -x kit.ti` |
| **terminal-features** | Opción de servidor que añade features a los TERM de fuera que casan con un patrón | `set -sa terminal-features 'xterm*:RGB'` |
| **terminal-overrides** | Forma antigua de lo mismo, escribiendo capacidades terminfo a mano | `set -sa terminal-overrides ',xterm*:Tc'` |
| **`client_termfeatures`** | Las features que tmux usa con un cliente concreto, leídas al conectarse | `display -p '#{client_termfeatures}'` |
| **RGB (24 bits)** | Feature para mandar colores `#rrggbb` tal cual; sin ella tmux los aproxima a 256 | `\e[38;2;255;100;0m` |
| **usstyle** | Feature de estilos de subrayado (ondulado, punteado) y color de subrayado | `\e[4:3m` |
| **extended-keys** | Opción para recibir y entregar teclas que la terminal clásica no distingue, con la feature `extkeys` | `set -s extended-keys on` |
| **escape-time** | Milisegundos que tmux espera tras `Esc` por si es el inicio de una secuencia | `set -s escape-time 10` |
| **passthrough** | Secuencia envuelta en `\ePtmux;...\e\\` que tmux reenvía a la terminal de fuera si `allow-passthrough` lo permite | `setw -g allow-passthrough on` |
| **`show-messages -T`** | Lista cada capacidad terminfo que tmux usa con un cliente, con `[missing]` si falta | `show-messages -T -t /dev/pts/1` |
