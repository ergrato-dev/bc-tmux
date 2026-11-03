# Lab 01 — Partir y moverte entre paneles

⏱ Duración estimada: ~60 min

## Objetivo

Partir una ventana en paneles, moverte entre ellos sin ratón, abrir cada panel en el directorio correcto y ponerles título.

## Contexto

- `prefix` `%` parte **a lo ancho** (un panel al lado del otro) y `prefix` `"` parte **a lo alto** (uno encima del otro). Por debajo los dos son `split-window`, con `-h` o sin él.
- Un panel creado con el teclado empieza en el directorio donde se creó la **sesión**, no en el del panel que partes. Para heredar el directorio actual hay que pedirlo: `-c '#{pane_current_path}'`.
- `split-window -P -F '#{pane_id}'` imprime el id del panel que acaba de crear. Es la forma segura de seguir trabajando con él desde un script.

## Instrucciones

Vas a usar dos terminales, las dos **fuera de tmux**:

- **Terminal A**: la que se conecta a la sesión del lab y donde pulsas las teclas.
- **Terminal B**: otra pestaña o ventana de tu emulador, para los comandos de comprobación.

0. En **las dos** terminales comprueba que no estás dentro de tmux y entra en la
   carpeta del lab (desde la raíz del repositorio):
   ```bash
   echo "$TMUX"
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-01-split-y-navegacion
   ```
   ```
   (línea vacía)
   ```
   Si `echo "$TMUX"` imprime algo, estás dentro de tmux: abre una pestaña nueva.
   Todo el lab va contra un servidor aparte, `-L lab`, arrancado con
   `-f /dev/null` (sin ninguna config). Por eso el prefix es el de fábrica,
   **`C-b`**: `Ctrl`+`b`, sueltas, y después la tecla.

1. En la **terminal A**, crea la sesión y conéctate:
   ```bash
   tmux -L lab -f /dev/null new -s paneles
   ```
   La terminal A pasa a mostrar la sesión `paneles`, con una barra verde abajo.

2. **Partir.** En la terminal A pulsa `C-b` `%` y después `C-b` `"`. Quedan tres
   paneles: uno a la izquierda y dos apilados a la derecha; el activo (borde
   verde) es el de abajo a la derecha. Compruébalo en la **terminal B**:
   ```bash
   tmux -L lab list-panes -t paneles -F '#{pane_index} #{pane_id} #{pane_left},#{pane_top} #{pane_width}x#{pane_height} #{pane_active}'
   ```
   Algo como (los tamaños dependen de tu terminal; esto es una de 80x25):
   ```
   0 %0 0,0 40x24 0
   1 %1 41,0 39x12 0
   2 %2 41,13 39x11 1
   ```
   `pane_left,pane_top` es la esquina del panel; la columna 40 es el borde.
   El `1` del final marca el panel activo.

3. **Moverte.** En la terminal A prueba cada fila:

   | Teclas | Qué hace |
   |---|---|
   | `C-b` `←` (o `↑` `→` `↓`) | Al panel de esa dirección |
   | `C-b` `o` | Al siguiente panel (por número) |
   | `C-b` `;` | Al último panel en el que estuviste |
   | `C-b` `q` | Dibuja el número de cada panel durante **1 segundo**; pulsa el número en ese segundo para ir a él |

   **Repetir sin prefix.** Las flechas están ligadas con `-r` (repetibles):
   tras `C-b` `←` tienes 500 ms (`repeat-time`) para pulsar otra flecha sin
   volver a pulsar `C-b`. Prueba esta secuencia exacta desde el panel de abajo
   a la derecha: `C-b`, `←`, `→` (rápido, sin soltar entre medias más de medio
   segundo). Acabas de vuelta abajo a la derecha. Si esperas más de medio
   segundo, la flecha ya no va a tmux sino a la shell (mueve el cursor o
   recupera un comando del historial). Para ver qué teclas repiten, en la
   terminal B:
   ```bash
   tmux -L lab list-keys -T prefix | grep '^bind-key -r .*select-pane'
   ```
   ```
   bind-key -r -T prefix Up      select-pane -U
   bind-key -r -T prefix Down    select-pane -D
   bind-key -r -T prefix Left    select-pane -L
   bind-key -r -T prefix Right   select-pane -R
   ```

4. **El directorio.** Vuelve al panel de abajo a la derecha (`C-b` `q` `2`).
   En él escribe `cd /tmp` y Enter. Ahora parte con `C-b` `%` y en el panel
   nuevo ejecuta `pwd`:
   ```
   /ruta/a/tu/repo/bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-01-split-y-navegacion
   ```
   No es `/tmp`: es el directorio donde creaste la sesión. Vuelve al panel de
   `/tmp` con `C-b` `;` y ábrelo bien desde el prompt de tmux: pulsa `C-b` `:`
   (aparece una línea amarilla abajo), escribe el comando y Enter:
   ```
   split-window -h -c "#{pane_current_path}"
   ```
   En ese panel nuevo, `pwd` imprime `/tmp`. Compruébalo en la terminal B:
   ```bash
   tmux -L lab list-panes -t paneles -F '#{pane_index} #{pane_id} #{pane_current_path}'
   ```
   ```
   0 %0 /ruta/a/tu/repo/bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-01-split-y-navegacion
   1 %1 /ruta/a/tu/repo/bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-01-split-y-navegacion
   2 %2 /tmp
   3 %4 /tmp
   4 %3 /ruta/a/tu/repo/bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-01-split-y-navegacion
   ```
   `%3` (el `pwd` equivocado) pasó al índice 4: el panel nuevo `%4` se colocó
   detrás de `%2` y los índices se renumeraron. Los ids no cambian. En la
   semana 06 ligarás `%` y `"` a la versión con `-c`.

5. **Cerrar paneles.** En la terminal A, en el panel activo (`%4`), pulsa
   `C-b` `x`. Abajo aparece `kill-pane 3? (y/n)`: responde `y`. Ve al panel
   del `pwd` equivocado, que ahora es el 3 (`C-b` `q` `3`), y escribe `exit`.
   Quedan tres paneles:
   ```bash
   tmux -L lab list-panes -t paneles -F '#{pane_index} #{pane_id}'
   ```
   ```
   0 %0
   1 %1
   2 %2
   ```

6. **Títulos.** Cada panel tiene un título (`#{pane_title}`), que por defecto
   es el nombre de la máquina. Los índices de los paneles los ves con
   `C-b` `q` o con el `list-panes` de arriba. En la terminal B:
   ```bash
   tmux -L lab select-pane -t paneles:0.0 -T editor
   tmux -L lab select-pane -t paneles:0.1 -T shell
   tmux -L lab select-pane -t paneles:0.2 -T logs
   tmux -L lab set -w -t paneles:0 pane-border-status top
   tmux -L lab list-panes -t paneles -F '#{pane_index} #{pane_title}'
   ```
   ```
   0 editor
   1 shell
   2 logs
   ```
   `paneles:0.1` es sesión `paneles`, ventana 0, panel 1. En la terminal A, el
   borde superior de cada panel muestra ahora su número y su título.

   > **Si el título se cambia solo.** Algunos prompts (oh-my-zsh, Starship y
   > otros) envían una secuencia de escape que cambia el título del panel cada
   > vez que se dibuja el prompt, y tu `editor` se convierte en el nombre del
   > directorio. Puedes reproducirlo a mano en el panel `shell`:
   > `printf '\033]2;pisado\033\\'` y Enter; `list-panes` muestra `1 pisado`.
   > En tmux 3.4 se arregla en el prompt: con oh-my-zsh, `DISABLE_AUTO_TITLE="true"`
   > en `~/.zshrc`; con bash, quita la secuencia `\e]0;` de tu `PS1` o
   > `PROMPT_COMMAND`. En tmux 3.5+ basta `set -p allow-set-title off`
   > (en 3.4 da `invalid option`). Con el bash del laboratorio no pasa.

   Desconéctate en la terminal A con `C-b` `d`:
   ```
   [detached (from session paneles)]
   ```
   Y cierra el servidor en la terminal B (lo necesitas vacío para el paso 7):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

7. **El script.** `starter/tres.sh` crea en segundo plano la sesión `tres`
   con tres paneles titulados, todos en el directorio que recibe, usando los
   ids que devuelve `-P -F '#{pane_id}'`, nunca índices. Trabaja en la
   **terminal B**. Cada prueba empieza con `kill-server` porque el script
   falla si la sesión `tres` ya existe (`duplicate session: tres`).
   El `2>/dev/null` calla el aviso cuando no hay servidor, y el `sleep 1` da
   tiempo a que el servidor viejo termine de salir: `kill-server` vuelve antes,
   y un `new-session` inmediato choca con él (`server exited unexpectedly`).

   1. **TODO 1**: crea la sesión y guarda el id de su panel. Pista:
      `editor=$(tmx new-session -d -P -F '#{pane_id}' -s tres -c "$dir")`.
      `-d` la crea sin conectarte; `-P -F` imprime el id y `$(...)` lo
      guarda. Borra también la última línea, `echo "tres.sh: sin implementar ..."`.
      ```bash
      tmux -L lab kill-server 2>/dev/null; sleep 1; ./starter/tres.sh /tmp; echo $?
      tmux -L lab list-panes -t tres -F '#{pane_id} #{pane_current_path}'
      ```
      ```
      0
      %0 /tmp
      ```
   2. **TODO 2**: dos `split-window`, cada uno con `-d` (el foco no cambia),
      `-P -F '#{pane_id}'`, `-c "$dir"` y `-t` con el id del panel que partes:
      `-h -t "$editor"` para `shell`, `-v -t "$shell"` para `logs`.
      ```bash
      tmux -L lab kill-server 2>/dev/null; sleep 1; ./starter/tres.sh /tmp
      tmux -L lab list-panes -t tres -F '#{pane_id} #{pane_left},#{pane_top} #{pane_current_path}'
      ```
      ```
      %0 0,0 /tmp
      %1 41,0 /tmp
      %2 41,13 /tmp
      ```
      Una sesión creada con `-d` mide 80x24 (`default-size`), así que estos
      números no dependen de tu terminal.
   3. **TODO 3**: `tmx select-pane -t "$editor" -T editor`, y lo mismo con
      `$shell` y `$logs`.
      ```bash
      tmux -L lab kill-server 2>/dev/null; sleep 1; ./starter/tres.sh /tmp
      tmux -L lab list-panes -t tres -F '#{pane_id} #{pane_title}'
      ```
      ```
      %0 editor
      %1 shell
      %2 logs
      ```
   4. **TODO 4**: `sleep 0.3` (sin él, a veces la shell aún no arrancó) y
      `tmx list-panes -t tres -F '#{pane_id} #{pane_title} #{pane_current_path}'`.
      ```bash
      tmux -L lab kill-server 2>/dev/null; sleep 1; ./starter/tres.sh /tmp
      ```
      ```
      %0 editor /tmp
      %1 shell /tmp
      %2 logs /tmp
      ```

8. Limpia en la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Te mueves entre tres paneles con `C-b` y flechas (repitiendo sin prefix), `o`, `;` y `q` (paso 3)
- [ ] El `list-panes` del paso 4 muestra un panel sin `-c` fuera de `/tmp` y uno con `-c '#{pane_current_path}'` en `/tmp`
- [ ] El `list-panes` del paso 6 imprime `editor`, `shell` y `logs`, y se ven en el borde con `pane-border-status top`
- [ ] `./starter/tres.sh /tmp` en un servidor vacío imprime las tres líneas del paso 7.4

## Reto extra

Cambia el texto del borde con
`tmux -L lab set -w -t tres:0 pane-border-format ' #{pane_index}: #{pane_title} (#{pane_current_command}) '`
y conéctate con `tmux -L lab attach -t tres` (sal con `C-b` `d`).
¿Qué pasa con el borde cuando ejecutas `top` en un panel? (Sal de `top` con `q`.)
