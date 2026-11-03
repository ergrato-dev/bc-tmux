# Lab 04 — Teclas extendidas

⏱ Duración estimada: ~60 min

## Objetivo

Hacer que `C-Enter` llegue a tmux como una tecla distinta de `Enter` combinando `extended-keys` y la feature `extkeys`, y comprobar cada pieza por separado.

## Contexto

- En una terminal clásica, `C-Enter` y `Enter` mandan el mismo byte (`^M`): nadie puede distinguirlas. Las **teclas extendidas** son un modo que la terminal activa a petición y en el que manda `C-Enter`, `C-Tab`... como secuencias propias.
- Hacen falta dos cosas en tmux: `extended-keys on` (entenderlas) y la feature `extkeys` en el cliente (pedírselas a la terminal). Y una tercera fuera de tmux: que tu terminal sepa mandarlas.
- `send-keys -K -c CLIENTE tecla` inyecta una tecla como si la hubiera pulsado ese cliente: prueba tus bindings sin depender de la terminal.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-04-teclas-extendidas
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **Qué manda tu terminal** (terminal B, fuera de tmux):
   ```bash
   cat -v
   ```
   Pulsa `Enter`, luego `C-Enter`, luego `Tab` y `C-Tab`, y al final `C-c`
   para salir. Lo normal: `Enter` y `C-Enter` hacen lo mismo (salto de
   línea), y `Tab` y `C-Tab` también (un tabulador). Tu terminal no las
   distingue mientras nadie le pida el modo extendido. Si `C-Enter`
   imprime algo como `^[[13;5u` o `^[[27;5;13~`, tu terminal ya manda
   teclas extendidas por su cuenta.

2. **Arranca y mira los valores** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab show -sv extended-keys
   tmux -L lab list-keys -T root C-Enter; echo $?
   tmux -L lab set -s extended-keys foo; echo $?
   ```
   ```
   0
   off
   unknown key: C-Enter
   1
   unknown value: foo
   1
   ```
   `unknown key` aquí significa "no hay binding para esa tecla": el nombre
   `C-Enter` sí existe. `extended-keys` solo acepta `off`, `on` y
   `always`.

3. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` (imprime
   `0`).

   1. **TODO 1: el binding.** Pista:
      `bind -n C-Enter display-message 'C-Enter llegó'`.
      ```bash
      tmux -L lab list-keys -T root C-Enter
      ```
      ```
      bind-key -T root C-Enter display-message "C-Enter llegó"
      ```
      Pruébalo sin la terminal. En la B:
      ```bash
      tmux -L lab attach -t api
      ```
      En la A, busca el cliente e inyéctale la tecla:
      ```bash
      C=$(tmux -L lab list-clients -F '#{client_name}'); echo "$C"
      tmux -L lab send-keys -K -c "$C" C-Enter; echo $?
      tmux -L lab show-messages -t "$C" | grep -m2 'C-Enter'
      ```
      Algo como (cambian la hora y el `pts`):
      ```
      /dev/pts/1
      0
      02:47: /dev/pts/1 message: C-Enter llegó
      02:47: /dev/pts/1 key C-Enter: display-message "C-Enter llegó"
      ```
      La barra de la B muestra `C-Enter llegó` un momento. El binding
      funciona. Ahora pulsa **tú** `C-Enter` en la B: la shell recibe un
      `Enter` (prompt nuevo) y no sale ningún mensaje. Vuelve a la A:
      ```bash
      tmux -L lab show-messages -t "$C" | grep -c 'key C-Enter'
      ```
      ```
      1
      ```
      Solo cuenta la tecla inyectada. Sal de la B con `C-b` `d`
      (`[detached (from session api)]`).
   2. **Una terminal que sí manda teclas extendidas.** Para no depender de
      la tuya, usa otro tmux como terminal de fuera. En la B:
      ```bash
      tmux -L fuera -f /dev/null new -s fuera
      ```
      La B está ahora dentro del servidor `fuera`. Dentro de ella,
      conéctate al lab (`env -u TMUX` porque tmux no deja anidar sin
      querer; `TERM=xterm-256color` para que case el patrón `xterm*`):
      ```bash
      env -u TMUX TERM=xterm-256color tmux -L lab attach -t api
      ```
      Ves dos barras: la del lab encima de la de `fuera`. En la A, pulsa
      `C-Enter` en `fuera` con `send-keys` (la tecla entra por la terminal,
      como si la pulsaras) y cuenta:
      ```bash
      tmux -L fuera send-keys -t fuera C-Enter
      sleep 0.5; tmux -L lab show-messages | grep -c 'key C-Enter'
      ```
      ```
      1
      ```
      No llegó: el lab tiene `extended-keys off`. Desconecta el cliente del
      lab desde la A (la B vuelve a la shell de `fuera`):
      ```bash
      tmux -L lab detach-client -s api
      ```
   3. **TODO 2: `extended-keys on`.** Pista: `set -s extended-keys on`.
      ```bash
      tmux -L lab show -sv extended-keys
      ```
      ```
      on
      ```
   4. **TODO 3: la feature `extkeys`.** Pista: `set -su terminal-features`
      y luego `set -sa terminal-features 'xterm*:extkeys'`.
      ```bash
      tmux -L lab show -s terminal-features
      ```
      ```
      terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
      terminal-features[1] screen*:title
      terminal-features[2] rxvt*:ignorefkeys
      terminal-features[3] xterm*:extkeys
      ```
      Las features se calculan al conectarse. En la B (shell de `fuera`),
      vuelve a conectarte con el comando `env -u TMUX ...` del paso 3.2. En
      la A:
      ```bash
      tmux -L lab list-clients -F '#{client_termname} #{client_termfeatures}'
      tmux -L fuera send-keys -t fuera C-Enter
      sleep 0.5; tmux -L lab show-messages | grep -c 'key C-Enter'
      ```
      ```
      xterm-256color 256,bpaste,ccolour,clipboard,hyperlinks,cstyle,extkeys,focus,mouse,overline,RGB,strikethrough,title,usstyle
      2
      ```
      `extkeys` está y la cuenta subió: la B muestra `C-Enter llegó`.
      Salen muchas features más porque tmux reconoce a `fuera` como otro
      tmux y le añade las suyas. Si repites el paso con solo uno de los dos
      TODOs, la cuenta no sube: hacen falta los dos.

      Cierra el servidor `fuera` (terminal A):
      ```bash
      tmux -L lab detach-client -s api
      tmux -L fuera kill-server
      ```
      La B imprime `[server exited]` y vuelve a tu shell.

4. **Con tu terminal de verdad.** En la B:
   ```bash
   tmux -L lab attach -t api
   ```
   Pulsa `C-Enter`. Dos resultados posibles:
   - Sale `C-Enter llegó` en la barra: tu terminal manda teclas extendidas
     cuando tmux se las pide.
   - La shell recibe un `Enter`: tu terminal no las manda (o no en el modo
     que pide tmux 3.4). La config está bien; el límite es la terminal.

   Compruébalo desde la A: `tmux -L lab show-messages | grep -c 'key C-Enter'`
   imprime `3` en el primer caso y `2` en el segundo. Sal de la B con
   `C-b` `d`.

5. **Limpia.** En la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `C-Enter` y `Enter` hacen lo mismo en `cat -v` fuera de tmux (paso 1)
- [ ] `tmux -L lab list-keys -T root C-Enter` muestra tu binding y `send-keys -K` lo dispara (paso 3.1)
- [ ] `tmux -L lab show -sv extended-keys` imprime `on` (paso 3.3)
- [ ] Con la B reconectada, `#{client_termfeatures}` incluye `extkeys` y la tecla que entra por `fuera` dispara el binding (paso 3.4)
- [ ] Explicas qué aporta cada pieza: el binding, `extended-keys`, `extkeys` y la terminal (pasos 3.2 a 4)
- [ ] Sabes decir si tu terminal manda `C-Enter` y cómo lo has comprobado (paso 4)

## Reto extra

Cambia `extended-keys` a `always`, reconecta y, dentro de tmux, abre
`cat -v` y pulsa `C-Enter` en tu terminal (o mándala por `fuera`). ¿Qué ves
en lugar de un salto de línea? Explica por qué `always` rompe programas como
`bash` que no esperan esas secuencias y por qué `on` es el valor del kit.
