# Lab 05 — Passthrough y estilos

⏱ Duración estimada: ~60 min

## Objetivo

Hacer llegar a la terminal de fuera una secuencia que tmux se quedaría (el título de la ventana) con `allow-passthrough`, y el subrayado ondulado con la feature `usstyle`, midiendo el riesgo de cada uno.

## Contexto

- tmux es una terminal: lee lo que escriben los programas y lo vuelve a dibujar a su manera. Una secuencia que no es de dibujo (cambiar el título, mostrar una imagen) se la queda o la descarta.
- **Passthrough**: el programa envuelve la secuencia en `\ePtmux;` … `\e\\` (con cada `\e` de dentro duplicado) y tmux la manda tal cual a tu terminal, solo si el panel tiene `allow-passthrough`. Lo que pasa así tmux **no lo filtra**.
- El subrayado ondulado (`\e[4:3m`, el de los errores de un corrector) necesita la feature `usstyle`; sin ella tmux lo dibuja recto.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-05-passthrough-y-estilos
   mkdir -p /tmp/lab08
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **Sin tmux** (terminal A, para ver los bytes):
   ```bash
   ./starter/outer-title hola-fuera | cat -v; echo
   ./starter/outer-title; echo $?
   ./starter/outer-title $'mal\e]2;x\a' | cat -v; echo
   ```
   ```
   ^[]2;hola-fuera^G
   uso: outer-title TEXTO
   2
   ^[]2;mal]2;x^G
   ```
   `\e]2;TEXTO\a` (OSC 2) cambia el título de la ventana. El script borra
   los caracteres de control del texto: sin eso, un título con `\a` dentro
   cerraría la secuencia y lo que siguiera llegaría a tu terminal como
   órdenes.

   Ahora en la terminal B (fuera de tmux):
   ```bash
   ./starter/outer-title hola-fuera
   printf '\e[4:3mondulado\e[0m \e[4mrecto\e[0m\n'
   ```
   Lo que deberías ver: el título de la ventana o pestaña de la B pasa a
   `hola-fuera` y la primera palabra sale subrayada con una onda. Si las
   dos salen con subrayado recto, tu terminal no dibuja subrayado
   ondulado y el paso 4 te enseñará los bytes pero no la onda.

2. **Arranca y conéctate grabando** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab show -gwv allow-passthrough
   tmux -L lab display -p '#{pane_title}'
   ```
   Algo como (el título inicial es el nombre de tu máquina):
   ```
   0
   off
   bc-tmux-lab
   ```
   En la B, conéctate dentro de `script` (lab-03), que graba en
   `/tmp/lab08/b.raw` todo lo que tmux manda a tu terminal:
   ```bash
   script -qfc 'tmux -L lab attach -t api' /tmp/lab08/b.raw
   ```
   En macOS: `script -q /tmp/lab08/b.raw tmux -L lab attach -t api`
   (graba al salir: haz los `grep` después de `C-b` `d`).

   Dentro de la B:
   ```bash
   clear; ./starter/outer-title desde-tmux
   ```
   El título de tu ventana **no** cambia. En la A:
   ```bash
   tmux -L lab display -p '#{pane_title}'
   ```
   ```
   desde-tmux
   ```
   tmux se quedó la secuencia: es el título del **panel**, no el de tu
   terminal.

3. **Los TODOs.** Tras cada TODO de `starter/tmux.conf`, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` (imprime
   `0`).

   1. **TODO de `starter/outer-title`: la envoltura.** Dentro de tmux
      (`$TMUX` no vacío), sustituye el `printf` por las dos líneas de la
      pista. Prueba en la B:
      ```bash
      clear; ./starter/outer-title prueba | cat -v; echo
      ```
      ```
      ^[Ptmux;^[^[]2;prueba^G^[\
      ```
      `^[P` abre el DCS, `tmux;` dice para quién es, el `^[` de la OSC va
      doble y `^[\` cierra. Ahora mándalo de verdad (en la B):
      ```bash
      clear; ./starter/outer-title desde-dentro
      ```
      En la A:
      ```bash
      tmux -L lab display -p '#{pane_title}'
      grep -ac $'\e]2;desde-dentro\a' /tmp/lab08/b.raw
      ```
      ```
      desde-tmux
      0
      ```
      tmux no la cogió como título del panel (va envuelta) y tampoco la
      pasó a tu terminal: `allow-passthrough` vale `off` y la descartó.
      Si `shellcheck` está instalado, `shellcheck starter/outer-title` no
      imprime nada.
   2. **TODO 1: `allow-passthrough on`.** Pista:
      `setw -g allow-passthrough on`. Recarga y comprueba:
      ```bash
      tmux -L lab show -gwv allow-passthrough
      ```
      ```
      on
      ```
      Repite en la B `clear; ./starter/outer-title desde-dentro`. El
      título de tu ventana pasa a `desde-dentro`. En la A:
      ```bash
      tmux -L lab display -p '#{pane_title}'
      grep -ac $'\e]2;desde-dentro\a' /tmp/lab08/b.raw
      ```
      ```
      desde-tmux
      1
      ```
      La secuencia llegó a tu terminal sin pasar por tmux: el título del
      panel sigue igual.

4. **El subrayado ondulado.** En la B:
   ```bash
   clear; printf '\e[4:3mondulado\e[0m \e[4mrecto\e[0m\n'
   ```
   Las dos palabras salen con subrayado **recto**. En la A:
   ```bash
   grep -ao $'\e\\[4[:3]*m[a-z]\\+' /tmp/lab08/b.raw | sort -u | cat -v
   tmux -L lab list-clients -F '#{client_termfeatures}'
   ```
   ```
   ^[[4mondulado
   ^[[4mrecto
   bpaste,ccolour,clipboard,cstyle,focus,title
   ```
   El programa pidió `4:3` y tmux mandó `4`: sin `usstyle`, lo cambia por
   lo más parecido que la terminal seguro que sabe hacer.

   **TODO 2: la feature `usstyle`.** Pista: `set -su terminal-features` y
   luego `set -sa terminal-features 'xterm*:usstyle'`. Recarga, sal de la
   B con `C-b` `d` (`[detached (from session api)]`) y vuelve a conectarte
   grabando (el comando `script` del paso 2): las features se leen al
   conectarse. En la A:
   ```bash
   tmux -L lab show -s terminal-features | tail -1
   tmux -L lab list-clients -F '#{client_termfeatures}'
   ```
   ```
   terminal-features[3] xterm*:usstyle
   bpaste,ccolour,clipboard,cstyle,focus,title,usstyle
   ```
   En la B repite el `printf` de arriba: `ondulado` ya sale con onda (si tu
   terminal la dibuja, paso 1). En la A, el mismo `grep`:
   ```
   ^[[4:3mondulado
   ^[[4mrecto
   ```

5. **El riesgo.** `allow-passthrough` acepta `off`, `on` y `all`. Con `on`
   solo pasa lo que escribe un panel visible; con `all`, también lo de los
   paneles y ventanas que no estás mirando. Lo que pasa, tmux no lo ve: un
   programa del panel puede cambiar tu título, mostrar imágenes o mandar
   un OSC 52 que escribe en tu portapapeles aunque tengas
   `set-clipboard off`. Por eso el valor por defecto es `off` y el kit usa
   `on`, nunca `all`.

6. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   rm -f /tmp/lab08/b.raw
   ```
   ```
   (sin salida)
   ```
   El título de la ventana de la B puede quedarse en `desde-dentro` hasta
   que tu shell lo vuelva a poner.

## Criterios de éxito

- [ ] `./starter/outer-title $'mal\e]2;x\a' | cat -v` imprime `^[]2;mal]2;x^G` y explicas por qué se borran los controles (paso 1)
- [ ] Explicas por qué `./starter/outer-title` dentro de tmux cambia `#{pane_title}` y no el título de tu ventana (paso 2)
- [ ] Dentro de tmux, `./starter/outer-title prueba | cat -v` imprime `^[Ptmux;^[^[]2;prueba^G^[\` (paso 3.1)
- [ ] Con `allow-passthrough on`, `grep -ac` encuentra la secuencia en la grabación y tu título cambia; con `off`, no (pasos 3.1 y 3.2)
- [ ] Con `usstyle` y la B reconectada, la grabación muestra `^[[4:3mondulado` (paso 4)
- [ ] Explicas la diferencia entre `on` y `all` y un riesgo concreto de activar passthrough (paso 5)

## Reto extra

Añade a `starter/tmux.conf` un estilo con subrayado ondulado de color en la
ventana activa: `set -g window-status-current-style 'curly-underscore,us=red'`.
Reconecta grabando y busca en `/tmp/lab08/b.raw` la secuencia del color del
subrayado (empieza por `\e[58`). ¿Qué pasa con la barra si quitas
`usstyle` de `terminal-features`?
