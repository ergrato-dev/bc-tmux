# Lab 03 — Color de 24 bits

⏱ Duración estimada: ~60 min

## Objetivo

Activar el color de 24 bits con `terminal-features` y comprobar, en lo que ves y en los bytes que tmux manda a tu terminal, la diferencia entre un color exacto (`38;2;R;G;B`) y su aproximación de 256 (`38;5;N`).

## Contexto

- Un programa pide un color exacto con `\e[38;2;R;G;Bm` (letra) o `\e[48;2;R;G;Bm` (fondo). tmux lo guarda tal cual, pero al dibujarlo en tu terminal solo lo manda así si el cliente tiene la feature `RGB`. Si no, lo cambia por el más cercano de la paleta de 256 (`\e[38;5;Nm`).
- `RGB` llega por terminfo (lab-02) o por `terminal-features`, que asocia un patrón del `TERM` de fuera con features. Es una lista: `-a` añade, `-u` la devuelve a las tres entradas de fábrica.
- Para ver los bytes usas `script`: graba en un archivo todo lo que tmux escribe en tu terminal.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-03-color-de-24-bits
   mkdir -p /tmp/lab08
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **TODO de `starter/color-strip`: la franja.** Ahora mismo:
   ```bash
   ./starter/color-strip; echo $?
   ```
   ```
   sin implementar
   1
   ```
   Escribe el bucle de la pista del TODO y **borra** las dos líneas
   `echo "sin implementar"` y `exit 1`. Prueba (terminal A):
   ```bash
   ./starter/color-strip 4 | cat -v
   ./starter/color-strip 1; echo $?
   ```
   ```
   ^[[48;2;255;0;0m ^[[48;2;170;170;85m ^[[48;2;85;170;170m ^[[48;2;0;0;255m ^[[0m
   uso: color-strip [ANCHO>=2]
   2
   ```
   Si tienes `shellcheck` (`sudo apt install shellcheck` /
   `brew install shellcheck`): `shellcheck starter/color-strip` no imprime
   nada.

2. **La franja sin tmux** (terminal B, fuera de tmux):
   ```bash
   ./starter/color-strip
   ```
   Lo que deberías ver: 64 columnas que pasan de rojo a verde y a azul sin
   saltos. Eso es tu terminal pintando 24 bits. Si ves franjas anchas de
   color (bandas), tu terminal no tiene color de 24 bits (Terminal.app de
   macOS, por ejemplo) y el resto del lab te enseñará bandas siempre.

3. **Arranca y conéctate grabando** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab show -s terminal-features
   ```
   ```
   0
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   ```
   Las tres de fábrica: ninguna dice `RGB`. En la terminal B, conéctate
   dentro de `script`, que graba en `/tmp/lab08/b.raw` (`-q` sin
   mensajes, `-f` escribe al momento, `-c` el comando):
   ```bash
   script -qfc 'tmux -L lab attach -t api' /tmp/lab08/b.raw
   ```
   En macOS el `script` es otro: `script -q /tmp/lab08/b.raw tmux -L lab attach -t api`.
   En la A:
   ```bash
   tmux -L lab list-clients -F '#{client_termname} #{client_termfeatures}'
   ```
   En el laboratorio Docker (en tu equipo puede salir alguna feature más;
   si ya sale `RGB`, tmux reconoció tu terminal y la añadió solo):
   ```
   xterm-256color bpaste,ccolour,clipboard,cstyle,focus,title
   ```
   En la B, dentro de tmux:
   ```bash
   clear; ./starter/color-strip 4; printf '\e[38;2;255;100;0mNARANJA\e[0m\n'
   ```
   Sal de la B con `C-b` `d` (`[detached (from session api)]`) y mira
   qué colores mandó tmux de verdad (terminal A):
   ```bash
   grep -ao $'\e\\[[34]8;[25];[0-9;]*m' /tmp/lab08/b.raw | sort -u | cat -v
   ```
   ```
   ^[[38;5;202m
   ^[[48;5;143m
   ^[[48;5;196m
   ^[[48;5;21m
   ^[[48;5;73m
   ```
   Pediste `255;100;0` y tmux mandó `38;5;202`, el naranja más cercano de
   256. Ahora sin grabar: conéctate con `tmux -L lab attach -t api` y
   escribe `./starter/color-strip`. La franja sale **a bandas**. Sal con
   `C-b` `d`.

4. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` (imprime
   `0`).

   1. **TODO 1: la barra con hex.** Pista:
      `set -g status-style 'bg=#161b22,fg=#3fb950'`.
      ```bash
      tmux -L lab show -gv status-style
      ```
      ```
      bg=#161b22,fg=#3fb950
      ```
      En la B, conéctate grabando otra vez (el comando `script` del paso
      3) y sal enseguida con `C-b` `d`. En la A, el mismo `grep` del paso 3:
      ```
      ^[[38;5;202m
      ^[[38;5;71m
      ^[[48;5;143m
      ^[[48;5;196m
      ^[[48;5;21m
      ^[[48;5;234m
      ^[[48;5;73m
      ```
      La franja vieja sigue en el panel y tmux la redibujó al conectarte.
      Lo nuevo es la barra: `#3fb950` salió como `38;5;71` y `#161b22`
      como `48;5;234`. Es la status line "lavada" del proyecto.
   2. **TODO 2: la feature `RGB`.** Antes de recargar, conecta la B
      **sin** grabar: `tmux -L lab attach -t api`. Pista del TODO:
      `set -su terminal-features` y luego
      `set -sa terminal-features 'xterm*:RGB'`. Recarga y, en la A:
      ```bash
      tmux -L lab show -s terminal-features
      tmux -L lab list-clients -F '#{client_termfeatures}'
      ```
      ```
      terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
      terminal-features[1] screen*:title
      terminal-features[2] rxvt*:ignorefkeys
      terminal-features[3] xterm*:RGB
      bpaste,ccolour,clipboard,cstyle,focus,title
      ```
      La opción cambió, el cliente **no**: tmux calcula las features al
      conectarse. Sal de la B con `C-b` `d` y conéctate grabando (comando
      `script` del paso 3). En la A:
      ```bash
      tmux -L lab list-clients -F '#{client_termfeatures}'
      ```
      ```
      bpaste,ccolour,clipboard,cstyle,focus,RGB,title
      ```
      En la B: `clear; ./starter/color-strip 4; printf '\e[38;2;255;100;0mNARANJA\e[0m\n'`
      y sal con `C-b` `d`. En la A, el `grep` del paso 3:
      ```
      ^[[38;2;255;100;0m
      ^[[38;2;63;185;80m
      ^[[48;2;0;0;255m
      ^[[48;2;170;170;85m
      ^[[48;2;22;27;34m
      ^[[48;2;255;0;0m
      ^[[48;2;85;170;170m
      ```
      Todo `38;2`/`48;2`: los colores llegan exactos. Conéctate sin grabar
      y escribe `./starter/color-strip`: la franja ya es continua, como en
      el paso 2. Sal con `C-b` `d`.

5. **Por qué `-u` antes de `-a`.** Simula dos recargas de una config que
   solo tuviera `-sa` (terminal A):
   ```bash
   tmux -L lab set -sa terminal-features 'xterm*:RGB'
   tmux -L lab set -sa terminal-features 'xterm*:RGB'
   tmux -L lab show -s terminal-features
   ```
   ```
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   terminal-features[3] xterm*:RGB
   terminal-features[4] xterm*:RGB
   terminal-features[5] xterm*:RGB
   ```
   Cada recarga apila otra copia. Tu config, con `-u` delante, lo arregla
   tantas veces como la cargues:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab show -s terminal-features
   ```
   ```
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   terminal-features[3] xterm*:RGB
   ```

6. **Limpia.** En la terminal A (la B ya está fuera de tmux):
   ```bash
   tmux -L lab kill-server
   rm -f /tmp/lab08/b.raw
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `./starter/color-strip 4 | cat -v` imprime cuatro `48;2;...` y `color-strip 1` sale con 2 (paso 1)
- [ ] Sin `RGB`, la grabación muestra `38;5;202` para el naranja `255;100;0` y explicas por qué (paso 3)
- [ ] Con el TODO 1, la grabación muestra `38;5;71` y `48;5;234` para los hex de la barra (paso 4.1)
- [ ] Explicas por qué `#{client_termfeatures}` no cambió hasta reconectar (paso 4.2)
- [ ] Con el TODO 2 y la B reconectada, la grabación solo tiene `38;2`/`48;2` y la franja se ve continua (paso 4.2)
- [ ] `show -s terminal-features` tiene 4 entradas aunque recargues varias veces (paso 5)

## Reto extra

La forma antigua de pedir lo mismo es `terminal-overrides` con la
capacidad `Tc`. Quita el TODO 2, añade
`set -as terminal-overrides ',xterm-256color:Tc'`, recarga y reconecta:
¿sale `RGB` en `#{client_termfeatures}`? Escribe en un comentario por qué
`terminal-features` es mejor (pista: ¿qué pasa si alguien escribe `TC` o
`xterm-265color`? El lab-06 lo responde).
