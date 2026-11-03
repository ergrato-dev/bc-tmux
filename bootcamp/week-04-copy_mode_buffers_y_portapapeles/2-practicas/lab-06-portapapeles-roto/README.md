# Lab 06 — El portapapeles roto

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de una config que copia con OSC 52, usando `show-options`, `show-messages -T` y la propia secuencia.

## Contexto

Un compañero preparó `starter/tmux.conf` y `starter/osc52.sh` para trabajar
por SSH: nada de `xclip` ni `pbcopy`, todo con OSC 52, que atraviesa la
conexión hasta tu terminal. "En mi máquina funcionaba". Tú copias con `y` y
`Ctrl+V` no pega nada. Hay **cuatro errores reales**.

El laboratorio sirve: el OSC 52 sale del contenedor hacia tu terminal igual
que por SSH. Lo que hace falta es una terminal que lo soporte (paso 1).

## Instrucciones

0. Abre **dos terminales fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía): la **A** se conectará al lab, la **B** se queda fuera. Si usas el
   laboratorio: `docker compose up -d lab` una vez y
   `docker compose exec lab bash` en cada terminal. En las dos, desde la raíz
   del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-06-portapapeles-roto
   ```
   Servidor aparte: `-L lab`. Para pegar fuera de tmux, usa un sitio
   cualquiera donde escribir: la barra del navegador, por ejemplo.

1. **¿Tu terminal acepta OSC 52?** Antes de culpar a tmux, en la terminal B
   (fuera de tmux), envía la secuencia a mano:
   ```bash
   printf '\e]52;c;%s\a' "$(printf hola | base64)"
   ```
   ```
   (sin salida)
   ```
   Pega con `Ctrl+V` (`Cmd+V` en macOS). Si pega `hola`, sigue. Si no, tu
   terminal no lo soporta o lo tiene desactivado: Windows Terminal, kitty,
   WezTerm, Alacritty y foot lo aceptan; en iTerm2 activa *Applications in
   terminal may access clipboard*; Terminal.app de macOS y GNOME Terminal no
   lo soportan. Cambia de terminal para este lab.

2. **Reproduce el fallo.** En la terminal A, arranca con la config rota y
   quédate conectado (sin `new -d`):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf"
   ```
   El prefix es `C-b`: el starter no define otro. Dentro, `echo copiame`, y
   copia: `C-b` `[`, `?` `copiame` `Enter` (el cursor va a la salida
   `copiame`), `v` (empieza), `e` (fin de palabra), `y` (copia y sale). Pega
   fuera de tmux: nada, o lo que tuvieras antes. El texto sí está en tmux; en
   la terminal B:
   ```bash
   tmux -L lab list-buffers
   ```
   ```
   buffer0: 7 bytes: "copiame"
   ```
   Desde aquí, cada vez que cambies la config, recarga en la terminal B con
   `tmux -L lab source-file "$PWD/starter/tmux.conf"` (ruta absoluta:
   `@lab-dir` sale de ella).

3. **Error 1: ¿envía tmux algo?** En la terminal B:
   ```bash
   tmux -L lab show -sv set-clipboard
   ```
   ```
   off
   ```
   El comentario dice "que los programas no toquen mi portapapeles", pero
   `off` apaga **también** el OSC 52 que envía tmux al copiar. Cambia `off`
   por `on` en `starter/tmux.conf` y recarga:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show -sv set-clipboard
   ```
   ```
   on
   ```
   Con `on`, tmux envía el OSC 52 al copiar y acepta el de los programas del
   panel; con `external`, solo el suyo. Copia otra vez en la terminal A (las
   mismas teclas del paso 2): sigue sin pegar.

4. **Error 2: ¿sabe tmux cómo enviarlo?** La receta es la capacidad `Ms` de
   terminfo. En la terminal B:
   ```bash
   tmux -L lab show-messages -T | grep ' Ms:'
   ```
   ```
    193: Ms: [missing]
   ```
   (El número puede cambiar.) Mira tu terminfo en la terminal B, **fuera de
   tmux** (dentro, `TERM` es `tmux-256color` y verías el de tmux, no el de tu
   terminal):
   ```bash
   echo "$TERM"; infocmp -x | grep -o 'Ms=[^,]*'
   ```
   ```
   xterm-256color
   Ms=\E]52;%p1%s;%p2%s\007
   ```
   Tu terminfo la tiene (y si no, tmux la añade para `xterm*` con la feature
   `clipboard`: `tmux -L lab show -s terminal-features`). Quien la quita es
   esta línea del starter:
   ```tmux
   set -ga terminal-overrides ',*:Ms@'
   ```
   `@` borra una capacidad, y `*` lo hace para cualquier terminal. Era el
   apaño para una terminal vieja que imprimía basura. Bórrala y recarga:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show -s terminal-overrides
   ```
   ```
   terminal-overrides[0] *:Ms@
   terminal-overrides[1] *:Ms@
   ```
   Sigue ahí, y duplicada: recargar no devuelve las opciones a su valor por
   defecto, solo ejecuta otra vez el archivo. El `-ga` (añadir) se ejecutó
   al arrancar y otra vez en la recarga del paso 3. Vacíala a mano (`-u`
   devuelve la opción a su valor por defecto, que es una lista vacía):
   ```bash
   tmux -L lab set -su terminal-overrides
   tmux -L lab show -s terminal-overrides
   ```
   ```
   terminal-overrides
   ```
   Las capacidades se calculan al conectar el cliente. En la terminal A, sal
   con `C-b` `d` (`[detached (from session 0)]`) y vuelve a entrar con
   `tmux -L lab attach`. En la terminal B:
   ```bash
   tmux -L lab show-messages -T | grep ' Ms:'
   ```
   ```
    193: Ms: (string) \033]52;%p1%s;%p2%s\a
   ```
   Copia en la terminal A (`C-b` `[`, `?` `copiame` `Enter`, `v`, `e`, `y`) y
   pega fuera de tmux: `copiame`. Prueba también un programa del panel que
   emite OSC 52; en la terminal A:
   ```bash
   printf '\e]52;c;%s\a' "$(printf hola | base64)"
   ```
   Pega fuera: `hola`, y `tmux -L lab list-buffers` en la B lo muestra
   arriba. Con `set-clipboard external` tmux lo habría descartado.

5. **Error 3: `prefix` `Y`.** El atajo debería mandar el último buffer al
   portapapeles. En la terminal B, `tmux -L lab set-buffer desde-Y`; en la
   A, pulsa `C-b` `Y`. El panel entra en modo vista con algo como:
   ```
   'tmux save-buffer - | "/ruta/al/lab-06-portapapeles-roto/starter/osc52.sh"' returned 1
   ```
   Sal con `q`. tmux no muestra el error del script; para verlo, ejecútalo
   sin terminal, como lo ejecuta `run-shell`. En la terminal B (Linux o
   laboratorio; `setsid` no existe en macOS):
   ```bash
   printf hola | setsid -w ./starter/osc52.sh; echo $?
   ```
   ```
   ./starter/osc52.sh: line 8: /dev/tty: No such device or address
   1
   ```
   `run-shell` ejecuta el comando sin terminal: no hay `/dev/tty` donde
   escribir. Dentro de tmux, el script debe pedirle a tmux que envíe él la
   secuencia. En `starter/osc52.sh`, justo después de `set -euo pipefail` y
   **antes** de `datos=$(base64)` (que se comería la entrada), añade:
   ```bash
   if [[ -n "${TMUX:-}" ]]; then
     exec tmux load-buffer -w -
   fi
   ```
   `run-shell` define `TMUX`, así que ese `tmux` habla con el servidor del
   lab. `load-buffer -w` guarda el texto en un buffer y lo envía con OSC 52 a
   la terminal exterior, respetando `set-clipboard` y `terminal-features`.
   No hace falta recargar: el script se lee en cada `C-b` `Y`. Repite: en la
   terminal B `tmux -L lab set-buffer desde-Y`, en la A `C-b` `Y` (ya sin
   mensaje), y pega fuera: `desde-Y`. En la terminal B:
   ```bash
   tmux -L lab list-buffers | head -2
   ```
   ```
   buffer3: 7 bytes: "desde-Y"
   buffer2: 7 bytes: "desde-Y"
   ```
   (Los números pueden variar.) Dos iguales: el de `set-buffer` y el que creó
   `load-buffer -w`.

6. **Error 4: textos largos.** En la terminal B (fuera de tmux: `TMUX` está
   vacía y el script escribe en `/dev/tty`), copia algo corto y algo largo:
   ```bash
   printf corto | ./starter/osc52.sh
   seq 1 100 | ./starter/osc52.sh
   ```
   ```
   (sin salida)
   ```
   Después del primero, pegar da `corto`; después del segundo, nada nuevo (o
   basura). Mira la secuencia en un archivo:
   ```bash
   seq 1 100 | OSC52_TTY=/tmp/osc ./starter/osc52.sh; wc -l < /tmp/osc
   ```
   ```
   5
   ```
   `base64` parte su salida cada 76 caracteres, y la secuencia OSC 52 debe ir
   en **una** línea. Cambia `datos=$(base64)` por
   `datos=$(base64 | tr -d '\n')` (`base64 -w0` no existe en macOS) y repite:
   ```bash
   seq 1 100 | OSC52_TTY=/tmp/osc ./starter/osc52.sh; wc -l < /tmp/osc
   seq 1 100 | ./starter/osc52.sh
   ```
   ```
   0
   ```
   Pega fuera: los números del 1 al 100.

7. Limpia, en la terminal B (la terminal A muestra `[server exited]`):
   ```bash
   tmux -L lab kill-server; rm -f /tmp/osc
   ```

## Criterios de éxito

- [ ] Los cuatro errores identificados (pasos 3 a 6), con una línea por cada uno explicando el síntoma y la causa
- [ ] Paso 3: `tmux -L lab show -sv set-clipboard` imprime `on`
- [ ] Paso 4: `tmux -L lab show-messages -T | grep ' Ms:'` muestra la secuencia, no `[missing]`, y explicas por qué recargar no bastaba
- [ ] Paso 5: `prefix` `Y` copia el último buffer sin mensaje de error
- [ ] Paso 6: `seq 1 100 | OSC52_TTY=/tmp/osc ./starter/osc52.sh; wc -l < /tmp/osc` imprime `0`
- [ ] Paso 4: copias en copy mode y pegas fuera de tmux con `Ctrl+V`

## Reto extra

Por SSH a otra máquina con tmux, ejecuta `printf remoto | ./osc52.sh` dentro
de un panel y pega en local. ¿Qué piezas tienen que estar bien en el tmux
**remoto** y cuáles en el local, si también usas tmux en tu máquina?
