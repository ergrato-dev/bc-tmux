# Diagnóstico de terminal

Síntoma → causa → comando. Los comandos con `#{client_*}` o `show-messages`
se lanzan **desde dentro de tmux**: necesitan un cliente conectado.

## Antes de nada: aísla el problema

```bash
bin/kit-doctor                               # una línea ok|aviso|fallo por tema
tmux -L limpio -f /dev/null new -s limpio    # tmux sin ninguna config
tmux -L limpio kill-server
```

Si en el tmux limpio el fallo sigue, el problema es tu terminal o el `TERM` de
fuera; si desaparece, es tu config. Para ver qué hace tmux por dentro:

```bash
tmux -vvv -L dbg -f /dev/null new -s dbg     # deja tmux-server-PID.log y tmux-client-PID.log aquí
tmux -L dbg kill-server
grep IDENTIFY_TERM tmux-server-*.log          # el TERM de fuera que recibió el servidor
```

Los logs se escriben en el directorio actual; si no puedes escribir en él, no
se crean y tmux no avisa. Dentro de tmux, `tmux show-messages` lista los
últimos mensajes y comandos, y `tmux show-messages -T` las capacidades que tmux
usa de tu terminal (`RGB: [missing]` es que no hay color de 24 bits).

## Colores lavados o distintos que fuera de tmux

- **Causa:** tmux no sabe que tu terminal tiene color de 24 bits y aproxima
  cada `#rrggbb` a la paleta de 256.
- **Comprueba:**
  ```bash
  tmux display -p '#{client_termname} #{client_termfeatures}'   # ¿sale RGB?
  printf '\e[38;2;255;100;0mnaranja de 24 bits\e[0m\n'          # dentro y fuera
  ```
- **Arreglo:** la feature `RGB` para tu `TERM` de fuera
  (`set -sa terminal-features "TU-TERM:RGB"` en `local.conf`) y vuelve a
  conectarte: las features se leen al hacer `attach`.

## Undercurl ausente (subrayado ondulado)

- **Causa:** falta la feature `usstyle`: tmux no manda a tu terminal el
  subrayado ondulado ni su color, y Neovim enseña un subrayado recto o nada.
- **Comprueba:**
  ```bash
  tmux display -p '#{client_termfeatures}'           # ¿sale usstyle?
  printf '\e[4:3mondulado\e[0m \e[4:1mrecto\e[0m\n'  # dentro de tmux
  ```
- **Arreglo:** `usstyle` en `terminal-features` para tu `TERM` de fuera. Si
  fuera de tmux tampoco se ve ondulado, tu terminal no lo soporta.

## Esc llega tarde (Neovim tarda en salir de insertar)

- **Causa:** `escape-time`. Tras cada `Esc`, tmux espera por si empieza una
  secuencia (una flecha, Alt+tecla); en 3.4 espera 500 ms.
- **Comprueba:** `tmux show -sv escape-time`
- **Arreglo:** `set -s escape-time 10`. Por SSH lento, si una flecha llega
  partida, súbelo.

## C-Enter no llega al programa

- **Causa:** `extended-keys` en `off`, tu terminal sin la feature `extkeys`,
  o una terminal que manda lo mismo con `C-Enter` que con `Enter`.
- **Comprueba:**
  ```bash
  tmux show -sv extended-keys                         # on
  tmux display -p '#{client_termfeatures}'            # ¿sale extkeys?
  tmux bind -n C-Enter display 'llega C-Enter'        # pulsa C-Enter
  tmux unbind -n C-Enter
  ```
- **Arreglo:** `set -s extended-keys on` y `extkeys` en `terminal-features`.
  Si con todo eso el mensaje no sale, la tecla no sale de tu terminal: mira
  sus opciones de teclado (o usa otra tecla).

## Portapapeles roto (y copia, pero no pega)

- **Causa:** `set-clipboard` no está en `on`, tu terminal no tiene la feature
  `clipboard`, o no acepta OSC 52.
- **Comprueba:**
  ```bash
  tmux show -sv set-clipboard                          # on
  tmux display -p '#{client_termfeatures}'             # ¿sale clipboard?
  printf '\e]52;c;%s\a' "$(printf hola | base64)"     # fuera de tmux: ¿pegas hola?
  ```
- **Arreglo:** si la última prueba no pega, tu terminal no admite OSC 52:
  en local, `bin/kit-copy` usa la herramienta del sistema (semana 04).

## Falta tmux-256color

- **Síntoma:** `unknown terminal "tmux-256color"` o `missing or unsuitable
  terminal` al arrancar un programa dentro de tmux.
- **Comprueba:** `infocmp tmux-256color`
- **Arreglo:** en Ubuntu 24.04 viene en `ncurses-base`; en sistemas más
  viejos, `sudo apt install ncurses-term`. En macOS, el ncurses del sistema no
  lo trae: cópialo del de Homebrew a tu `~/.terminfo`:
  ```bash
  brew install ncurses
  "$(brew --prefix ncurses)/bin/infocmp" -x tmux-256color > /tmp/tmux-256color.src
  /usr/bin/tic -x -o ~/.terminfo /tmp/tmux-256color.src
  ```
