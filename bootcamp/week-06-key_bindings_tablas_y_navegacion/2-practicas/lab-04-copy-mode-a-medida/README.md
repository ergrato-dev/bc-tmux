# Lab 04 — Copy mode a medida

⏱ Duración estimada: ~60 min

## Objetivo

Cambiar las teclas de la tabla `copy-mode-vi` y escribir bindings de varios comandos con `{}` y `if -F`, comprobando cada copia con `show-buffer`.

## Contexto

- En copy mode, las teclas se buscan en `copy-mode-vi` (con `mode-keys vi`) o en `copy-mode` (con `emacs`). Sus comandos son `send -X ACCION`: `begin-selection`, `copy-selection-and-cancel`, `cancel`...
- `{ ... }` agrupa varios comandos en un solo binding, uno por línea, sin `\;`. Dentro puede ir otro bloque: es lo que usan `if -F` y `command-prompt`.
- `if -F '#{formato}' { si } { no }` decide sin lanzar una shell: mira el formato (`#{selection_present}` es 1 si hay selección) y ejecuta uno de los dos bloques.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-04-copy-mode-a-medida
   ```
   El servidor es `-L lab`. Ni `-f /dev/null` ni el starter cambian el
   prefix: en este lab es **`C-b`**.

1. **Lo que trae tmux.** En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s lab
   tmux -L lab show -gwv mode-keys
   tmux -L lab list-keys -T copy-mode-vi Space
   tmux -L lab list-keys -T copy-mode-vi v
   tmux -L lab list-keys -T copy-mode-vi C-v
   tmux -L lab list-keys -T copy-mode-vi y
   tmux -L lab list-keys -T copy-mode-vi Enter
   tmux -L lab list-keys -T copy-mode-vi q
   tmux -L lab list-keys -T copy-mode-vi Escape
   ```
   ```
   emacs
   bind-key -T copy-mode-vi Space send-keys -X begin-selection
   bind-key -T copy-mode-vi v send-keys -X rectangle-toggle
   bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
   unknown key: y
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel
   bind-key -T copy-mode-vi q send-keys -X cancel
   bind-key -T copy-mode-vi Escape send-keys -X clear-selection
   ```
   `mode-keys` es `emacs` salvo que tu `$EDITOR` o `$VISUAL` contengan
   `vi`: entonces tmux arranca con `vi`. De serie, en `copy-mode-vi`, la
   selección empieza con `Space`, `v` y `C-v` hacen lo mismo (rectangular)
   e `y` no existe.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

2. **El copy mode de serie.** El starter solo fija `mode-keys vi` (terminal
   A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab show -gwv mode-keys
   ```
   ```
   vi
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   Escribe esto y pulsa `Enter`; es el texto que copiarás en todo el lab:
   ```bash
   clear; printf 'a1 b1\na2 b2\na3 b3\n'
   ```
   ```
   a1 b1
   a2 b2
   a3 b3
   ```
   Entra en copy mode con `C-b` `[`: arriba a la derecha aparece `[0/0]`.
   En la terminal A:
   ```bash
   tmux -L lab display -p '#{pane_in_mode} #{pane_mode} #{client_key_table}'
   ```
   ```
   1 copy-mode root
   ```
   El **cliente** sigue en `root`: la tabla `copy-mode-vi` es del panel, y
   tmux la consulta cuando `root` no tiene la tecla. En la B, dentro del
   copy mode: `k` `k` `k` (tres líneas arriba, a `a1 b1`), `0` (inicio de
   línea), `Space` (empieza la selección), `e` (fin de la palabra) y
   `Enter` (copia y sale). En A:
   ```bash
   tmux -L lab show-buffer; echo
   ```
   ```
   a1
   ```
   Ahora con `v`: `C-b` `[`, `k` `k` `k` `0` `v` `e` `Enter`. En A:
   ```bash
   tmux -L lab show-buffer; echo
   ```
   ```
   a1
   ```
   El mismo `a1` de antes: `v` no empezó ninguna selección y `Enter` no
   copió nada. Deja la B conectada.

3. **Los TODOs del starter.** Cada uno se prueba recargando con
   `source-file` en la terminal A y pulsando en la B.

   1. **TODO 1: `v` empieza la selección.** Pista:
      `bind -T copy-mode-vi v send -X begin-selection`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T copy-mode-vi v
      ```
      ```
      0
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      ```
      En la B: `C-b` `[`, `k` `k` `k` `0` `v` `e` `Enter`. Y la
      rectangular, que sigue en `C-v`: `C-b` `[`, `k` `k` `k` `0` `v` `C-v`
      `j` `j` `l` `Enter` (la primera columna de las tres líneas). En A,
      después de cada una:
      ```bash
      tmux -L lab show-buffer; echo
      ```
      ```
      a1
      ```
      ```
      a1
      a2
      a3
      ```
   2. **TODO 2: `y` con `if -F`.** Copia el bloque de la pista del starter
      (sin los `#`) debajo del comentario `TODO 2`. Las llaves de apertura
      van al final de la línea (`... {`) y las de cierre en su propia línea.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T copy-mode-vi y
      ```
      ```
      0
      bind-key -T copy-mode-vi y if-shell -F "#{selection_present}" { send-keys -X copy-selection-and-cancel ;; display-message copiado } { send-keys -X cancel }
      ```
      `list-keys` lo enseña en una línea: `;;` separa los comandos de un
      bloque. En la B: `C-b` `[`, `k` `k` (a `a2 b2`), `0` `w` (a `b2`),
      `v` `e` `y`: la barra muestra `copiado` y sales del copy mode. En A:
      ```bash
      tmux -L lab show-buffer; echo
      ```
      ```
      b2
      ```
      Sin selección: `C-b` `[` e `y`. Sales sin copiar nada. En A:
      ```bash
      tmux -L lab display -p '#{pane_in_mode}'
      tmux -L lab show-buffer; echo
      ```
      ```
      0
      b2
      ```
   3. **TODO 3: `C-b` `C-y`, varios comandos en un bloque.** Debajo del
      comentario `TODO 3`, añade:
      ```tmux
      bind C-y {
        copy-mode
        send -X cursor-up
        send -X select-line
        send -X copy-selection-and-cancel
        display 'línea copiada'
      }
      ```
      Al entrar en copy mode el cursor está en la línea del prompt:
      `cursor-up` sube a la última línea de salida.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix C-y
      ```
      ```
      0
      bind-key -T prefix C-y copy-mode \;\; send-keys -X cursor-up \;\; send-keys -X select-line \;\; send-keys -X copy-selection-and-cancel \;\; display-message "línea copiada"
      ```
      En la B, `C-b` `C-y`: la barra muestra `línea copiada`. En A, con
      `od -c` para ver el salto de línea final que añade `select-line`:
      ```bash
      tmux -L lab show-buffer | od -c | head -2
      ```
      ```
      0000000   a   3       b   3  \n
      0000006
      ```
   4. **TODO 4: `C-b` `/`, un bloque dentro de otro.** Debajo del
      comentario `TODO 4`:
      ```tmux
      bind / {
        copy-mode
        command-prompt -p 'buscar:' {
          send -X search-backward '%%'
        }
      }
      ```
      `command-prompt` cambia `%%` por lo que escribas.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix /
      ```
      ```
      0
      bind-key -T prefix / copy-mode \;\; command-prompt -p buscar: { send-keys -X search-backward "%%" }
      ```
      En la B, escribe `seq 200 | tail -n +5; echo fin` y `Enter` (los
      números del 5 al 200). Pulsa `C-b` `/`: la barra pide `buscar:`.
      Escribe `42` y `Enter`. Arriba a la derecha, `(2 results)`. En A:
      ```bash
      tmux -L lab display -p '#{copy_cursor_line}'
      ```
      ```
      142
      ```
      La coincidencia más cercana hacia arriba es `142`. En la B, pulsa `n`
      (siguiente coincidencia) y mira otra vez en A:
      ```bash
      tmux -L lab display -p '#{copy_cursor_line}'
      ```
      ```
      42
      ```
      Sal del copy mode con `q`. Y sal de la B con `C-b` `d`:
      ```
      [detached (from session lab)]
      ```

4. **Las teclas que usaste**, para tus notas: en `copy-mode-vi`, `h` `j`
   `k` `l` mueven el cursor, `0` va al inicio de la línea, `w` y `e` a la
   palabra siguiente y a su final, `v` empieza la selección (TODO 1),
   `C-v` la hace rectangular, `y` copia (TODO 2), `n` repite la búsqueda,
   `q` sale y `Escape` quita la selección sin salir.

5. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `v` no copió nada en el paso 2
- [ ] `tmux -L lab list-keys -T copy-mode-vi v` muestra `begin-selection` y `C-v` copia la columna `a1 a2 a3` (paso 3.1)
- [ ] `y` con selección copia `b2`, y sin selección sale del copy mode sin tocar el buffer (paso 3.2)
- [ ] `C-b` `C-y` deja en el buffer la última línea de salida con su salto de línea (paso 3.3)
- [ ] `C-b` `/` `42` deja el cursor en `142` y `n` salta a `42` (paso 3.4)

## Reto extra

Haz que `Y` (mayúscula) en `copy-mode-vi` copie desde el cursor hasta el
final de la línea **sin** salir del copy mode. Busca los nombres exactos en
`man tmux`, sección "WINDOWS AND PANES", lista de comandos de copy mode
(`begin-selection`, `end-of-line`, `copy-selection`...).
