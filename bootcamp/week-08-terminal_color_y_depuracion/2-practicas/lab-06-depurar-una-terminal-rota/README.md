# Lab 06 — Depurar una terminal rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los cinco fallos de una config que carga sin errores, usando los síntomas, `show`, `show-messages -T`, los logs de `tmux -vvv` y un servidor limpio con `-f /dev/null`.

## Contexto

- `starter/tmux.conf` está **rota a propósito**: `source-file` la acepta, pero colores, subrayado, `TERM`, `Esc` y `C-Enter` fallan. Sus comentarios mienten; los valores, no.
- tmux acepta sin avisar un patrón de `terminal-features` que no casa con nada o una capacidad inventada en `terminal-overrides`. Por eso se depura mirando el **resultado** (features del cliente, capacidades cargadas, bytes), no la config.
- `tmux -vvv` escribe `tmux-server-PID.log` y `tmux-client-PID.log` en el **directorio actual**. Si no puede escribir allí, no crea nada y no avisa.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-06-depurar-una-terminal-rota
   mkdir -p /tmp/lab08
   ```
   El servidor es `-L lab`. La config no cambia el prefix: en este lab es
   **`C-b`**.

1. **Arranca con logs.** Los logs van a un directorio temporal, así que
   guarda antes la ruta absoluta de la config (terminal A):
   ```bash
   L=/tmp/lab08/logs; mkdir -p "$L"; C="$PWD/starter/tmux.conf"
   (cd "$L" && tmux -vvv -L lab -f "$C" new -d -s api); echo $?
   ls "$L"
   grep -m1 "server started" "$L"/tmux-server-*.log
   ```
   Algo como (cambian los PID y la marca de tiempo):
   ```
   0
   tmux-client-10.log
   tmux-out-12.log
   tmux-server-12.log
   1793674308.808924 server started (12): version 3.4, socket /tmp/tmux-1000/lab, protocol 8
   ```
   El paréntesis `( ... )` hace el `cd` en una subshell: tu terminal A
   sigue en la carpeta del lab. El servidor escribe ~17 000 líneas solo
   con arrancar (`wc -l "$L"/tmux-server-*.log`): se busca con `grep`, no
   se lee.

2. **Los síntomas.** En la B, conéctate grabando (lab-03):
   ```bash
   script -qfc 'tmux -L lab attach -t api' /tmp/lab08/b.raw
   ```
   En macOS: `script -q /tmp/lab08/b.raw tmux -L lab attach -t api`
   (graba al salir). Dentro de la B:
   ```bash
   clear; echo "dentro: $TERM"; printf '\e[38;2;255;100;0mNARANJA\e[0m \e[4:3mondulado\e[0m\n'
   ```
   En la B ves `dentro: xterm-256color`, `ondulado` con subrayado recto y,
   si te fijas, un naranja algo distinto del que pinta tu terminal fuera
   de tmux. Pulsa `C-Enter`: la shell recibe un `Enter`. En la A, los
   bytes que llegaron a tu terminal:
   ```bash
   grep -ao $'\e\\[\\(38;[25];[0-9;]*\\|4[:3]*\\)m[A-Za-z]\\+' /tmp/lab08/b.raw | sort -u | cat -v
   ```
   ```
   ^[[38;5;202mNARANJA
   ^[[4mondulado
   ```
   Cuatro síntomas: color aproximado (`38;5`), subrayado recto (`4`),
   `TERM` de dentro equivocado y `C-Enter` que no llega. El quinto, el
   `Esc` lento, se nota en cualquier programa que use `Esc` para salir de
   un modo: tarda medio segundo.

3. **Qué ve tmux del cliente** (terminal A):
   ```bash
   tmux -L lab list-clients -F '#{client_name} #{client_termname} #{client_termfeatures}'
   tmux -L lab display -p 'fuera:[#{client_termname}] #{version}'
   ```
   Algo como (cambia el `pts`):
   ```
   /dev/pts/1 xterm-256color bpaste,ccolour,clipboard,cstyle,focus,title
   fuera:[xterm-256color] 3.4
   ```
   El `TERM` de fuera es el esperado, pero en las features no hay `RGB`,
   `usstyle` ni `extkeys`. (Con la B conectada, `display -p` usa ese
   cliente; sin ninguno, `#{client_termname}` sale vacío.)

4. **Qué dice la config** (terminal A):
   ```bash
   tmux -L lab show -s default-terminal; tmux -L lab show -s escape-time; tmux -L lab show -s extended-keys
   tmux -L lab show -s terminal-overrides; tmux -L lab show -s terminal-features
   ```
   ```
   default-terminal xterm-256color
   escape-time 500
   extended-keys off
   terminal-overrides[0] xterm-256color:TC
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   terminal-features[3] xterm-265color:RGB:usstyle
   ```
   Hay un override y una feature para el color, y aun así no hay `RGB`.

5. **Qué capacidades cargó tmux.** `show-messages -T` (lo mismo que
   `tmux info`) necesita un cliente:
   ```bash
   C=$(tmux -L lab list-clients -F '#{client_name}')
   tmux -L lab show-messages -T -t "$C" | head -1
   tmux -L lab show-messages -T -t "$C" | grep -E ' (RGB|Tc|Smulx|Setulc): '
   ```
   ```
   Terminal 0: xterm-256color for /dev/pts/1, flags=0x20:
    199: RGB: [missing]
    211: Setulc: [missing]
    221: Smulx: [missing]
    227: Tc: [missing]
   ```
   `Tc: [missing]` aunque el override diga `TC`: los nombres de capacidad
   distinguen mayúsculas, y `TC` no existe. tmux no se queja.

6. **Qué dicen los logs.** El `TERM` que mandó cada cliente y el que se
   dio al panel:
   ```bash
   grep -a 'IDENTIFY_TERM ' "$L"/tmux-server-*.log | awk '{print $NF}' | sort | uniq -c
   grep -a 'spawn_pane: environment TERM=' "$L"/tmux-server-*.log | cut -d' ' -f2-
   grep -a 'xterm-265color' "$L"/tmux-server-*.log | cut -d' ' -f2- | head -3
   ```
   Algo como (el número cuenta cada comando que lanzaste desde la A, que
   también es un cliente):
   ```
        16 xterm-256color
   spawn_pane: environment TERM=xterm-256color
   yylex_token: xterm-265color:RGB:usstyle
   cmd_parse_build_commands 2:3: xterm-265color:RGB:usstyle
   args_parse: 3 = xterm-265color:RGB:usstyle (type STRING)
   ```
   El cliente dice `xterm-256color` y la entrada de features dice
   `xterm-265color`: no casan. Y el panel nació con `TERM=xterm-256color`.

7. **Aísla config o terminal.** Un servidor limpio, sin config, con tu
   misma terminal (terminal A):
   ```bash
   tmux -L limpio -f /dev/null new -d -s api; echo $?
   tmux -L limpio show -sv default-terminal
   ```
   ```
   0
   tmux-256color
   ```
   Sal de la B con `C-b` `d` (`[detached (from session api)]`) y conéctate
   al limpio: `tmux -L limpio attach -t api`. En la A:
   ```bash
   tmux -L limpio list-clients -F '#{client_termname} #{client_termfeatures}'
   ```
   ```
   xterm-256color bpaste,ccolour,clipboard,cstyle,focus,title
   ```
   Mismas features que con la config rota: las líneas de color no
   aportaban nada. Y sin config el `TERM` de dentro es el correcto: el
   `xterm-256color` lo puso la config. Sal de la B con `C-b` `d` y, en la A:
   ```bash
   tmux -L limpio kill-server
   ```

8. **Arregla `starter/tmux.conf`.** Tras cada arreglo, en la A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` (imprime
   `0`). Corrige también el comentario de cada línea: que diga el porqué.

   1. **`escape-time`.** Es lo que tmux espera tras un `Esc` para saber si
      empieza una tecla como `M-x`. Pista: `set -s escape-time 10`.
      ```bash
      tmux -L lab show -sv escape-time
      ```
      ```
      10
      ```
   2. **`extended-keys`.** Pista: `set -s extended-keys on` (lab-04).
      ```bash
      tmux -L lab show -sv extended-keys
      ```
      ```
      on
      ```
   3. **`default-terminal`.** Pista: `set -s default-terminal tmux-256color`.
      Solo lo ven los paneles nuevos:
      ```bash
      tmux -L lab show -sv default-terminal
      tmux -L lab split-window -t api
      sleep 0.5; tmux -L lab send-keys -t api 'echo "dentro: $TERM"' Enter
      sleep 0.5; tmux -L lab capture-pane -p -t api | grep '^dentro'
      ```
      ```
      tmux-256color
      dentro: tmux-256color
      ```
   4. **Override y features.** Borra la línea de `terminal-overrides` y
      cambia la de `terminal-features` por estas dos (`-u` para que
      recargar no la duplique; `extkeys` es la otra mitad del arreglo 2):
      `set -su terminal-features` y
      `set -sa terminal-features 'xterm*:RGB:usstyle:extkeys'`.
      ```bash
      tmux -L lab show -s terminal-features | tail -1
      tmux -L lab show -s terminal-overrides
      ```
      ```
      terminal-features[3] xterm*:RGB:usstyle:extkeys
      terminal-overrides[0] xterm-256color:TC
      ```
      El override sigue ahí: **borrar una línea y recargar no deshace lo
      que esa línea hizo**. La forma segura de probar la config entera es
      arrancar de cero.

9. **Arranca de cero y comprueba** (terminal A; la B está fuera de tmux):
   ```bash
   tmux -L lab kill-server
   sleep 1; tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab show -s terminal-overrides
   ```
   ```
   0
   terminal-overrides
   ```
   En la B, conéctate grabando (comando del paso 2) y repite el
   `clear; echo ...; printf ...` del paso 2: `dentro: tmux-256color`, el
   naranja exacto y la onda. En la A:
   ```bash
   tmux -L lab list-clients -F '#{client_termfeatures}'
   grep -ao $'\e\\[\\(38;[25];[0-9;]*\\|4[:3]*\\)m[A-Za-z]\\+' /tmp/lab08/b.raw | sort -u | cat -v
   C=$(tmux -L lab list-clients -F '#{client_name}')
   tmux -L lab send-keys -K -c "$C" C-Enter; tmux -L lab show-messages -t "$C" | grep -c 'key C-Enter'
   ```
   ```
   bpaste,ccolour,clipboard,cstyle,extkeys,focus,RGB,title,usstyle
   ^[[38;2;255;100;0mNARANJA
   ^[[4:3mondulado
   1
   ```
   Pulsa `C-Enter` en la B: si tu terminal manda teclas extendidas
   (lab-04), sale `C-Enter llegó`.

10. **Limpia.** Sal de la B con `C-b` `d`:
    ```
    [detached (from session api)]
    ```
    En la terminal A:
    ```bash
    tmux -L lab kill-server
    rm -rf /tmp/lab08
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Los logs de `-vvv` están en `/tmp/lab08/logs` y sabes por qué hace falta el `cd` (paso 1)
- [ ] Nombras los cinco síntomas y el comando que demuestra cada uno (pasos 2 a 5)
- [ ] Explicas, con `show-messages -T` y el log, por qué ni `TC` ni `xterm-265color` dan color de 24 bits (pasos 5 y 6)
- [ ] Explicas qué te dijo el servidor `-f /dev/null` sobre si el fallo era de la config o de la terminal (paso 7)
- [ ] Explicas por qué el override seguía tras borrarlo y recargar (paso 8.4)
- [ ] Arrancando de cero con tu config, `#{client_termfeatures}` incluye `RGB`, `usstyle` y `extkeys`, la grabación muestra `38;2` y `4:3`, y un panel nuevo tiene `TERM=tmux-256color` (pasos 8.3 y 9)

## Reto extra

No siempre puedes reiniciar el servidor con `-vvv`. Con el servidor ya en
marcha y sin logs, `kill -USR2` sobre su PID los activa en caliente (en el
directorio donde arrancó el servidor). Busca el PID con
`tmux -L lab display -p '#{pid}'`, actívalo, conecta la B y busca
`IDENTIFY_TERM` en el log nuevo. ¿Cómo lo desactivas?
