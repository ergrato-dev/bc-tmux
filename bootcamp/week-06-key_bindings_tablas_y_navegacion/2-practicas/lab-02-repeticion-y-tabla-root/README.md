# Lab 02 — Repetición y la tabla root

⏱ Duración estimada: ~60 min

## Objetivo

Decidir qué teclas se repiten con `-r` y cuáles van en la tabla `root` con `-n`, midiendo lo que ganas y lo que robas a la shell.

## Contexto

- `bind -r` deja la tecla "abierta" durante `repeat-time` (500 ms): la misma u otra tecla con `-r` de esa tabla no necesita prefix. Pasado ese tiempo, o con una tecla sin `-r`, todo vuelve a la normalidad.
- `bind -n` pone la tecla en la tabla `root`: se mira **antes** de que el programa del panel la reciba. Lo que pongas ahí ya no llega a bash, a `less` ni a nada.
- Por eso `-n` se reserva para combinaciones que casi ningún programa usa (`M-` + flecha) y nunca para `Tab`, `Enter` o letras.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-02-repeticion-y-tabla-root
   ```
   El servidor es `-L lab`. Ni `-f /dev/null` ni el starter cambian el
   prefix: en este lab es **`C-b`**.

1. **Lo que trae tmux.** En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s lab
   tmux -L lab list-keys -T prefix Up
   tmux -L lab list-keys -T prefix M-Up
   tmux -L lab list-keys -T prefix | grep -c -- "-r "
   tmux -L lab show -gv repeat-time
   tmux -L lab list-keys -T prefix K
   tmux -L lab list-keys -T prefix L
   ```
   ```
   bind-key -r -T prefix Up select-pane -U
   bind-key -r -T prefix M-Up resize-pane -U 5
   18
   500
   unknown key: K
   bind-key -T prefix L switch-client -l
   ```
   18 teclas de serie llevan `-r`, entre ellas las flechas. `K` está libre;
   `L` salta a la última sesión (el TODO 1 la pisa).
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

2. **El problema del `-r` en las flechas.** Arranca con el starter (todavía
   no cambia nada) y parte la ventana en dos, uno encima del otro (terminal
   A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab split-window -v
   tmux -L lab list-panes -F '#{pane_index} #{pane_height} #{pane_active}'
   ```
   Algo como (la altura depende de tu terminal):
   ```
   0 15 0
   1 14 1
   ```
   Estás en el panel 1, el de abajo (`pane_active` 1). En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   Escribe `echo historia` y `Enter`. Pulsa `C-b` `↑`: vas al panel de
   arriba. Ahora vuelve con `C-b` `↓` y, **enseguida** (menos de medio
   segundo), pulsa `↑` para recuperar `echo historia` del historial. En la
   terminal A:
   ```bash
   tmux -L lab display -p '#{pane_index}'
   ```
   ```
   0
   ```
   El `↑` no llegó a la shell: el `-r` lo convirtió en otro `C-b` `↑` y
   volviste arriba. Deja la B conectada.

3. **Los TODOs del starter.** Cada uno se prueba recargando con
   `source-file` en la terminal A.

   1. **TODO 1: redimensionar repetible.** Debajo del comentario `TODO 1`:
      ```tmux
      bind -r -N "lab: borde a la izquierda" H resize-pane -L 5
      bind -r -N "lab: borde abajo"          J resize-pane -D 5
      bind -r -N "lab: borde arriba"         K resize-pane -U 5
      bind -r -N "lab: borde a la derecha"   L resize-pane -R 5
      ```
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix K
      tmux -L lab list-keys -N -T prefix K
      ```
      ```
      0
      bind-key -r -T prefix K resize-pane -U 5
      K lab: borde arriba
      ```
      En la B, en el panel de abajo (`C-b` `↓` si no estás), pulsa `C-b`
      `K` `K` `K` seguidos: el borde sube 15 celdas con un solo prefix. En
      A:
      ```bash
      tmux -L lab list-panes -F '#{pane_index} #{pane_height} #{pane_active}'
      ```
      Algo como (el panel de arriba no baja de 1 línea):
      ```
      0 1 0
      1 28 1
      ```
      Ahora `C-b` `J`, espera un segundo y pulsa `J` otra vez: el borde baja
      5 y la segunda `J` aparece escrita en la shell (`$ J`): la ventana de
      500 ms se había cerrado. Bórrala con `Backspace`.
      ```bash
      tmux -L lab list-panes -F '#{pane_index} #{pane_height} #{pane_active}'
      ```
      ```
      0 6 0
      1 23 1
      ```
   2. **TODO 2: flechas sin `-r`.** Pista: `bind Up select-pane -U` y las
      otras tres (`Down -D`, `Left -L`, `Right -R`). Un `bind` sin `-r`
      sobre la misma tecla sustituye al de serie.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix Up
      ```
      ```
      0
      bind-key -T prefix Up select-pane -U
      ```
      Repite la prueba del paso 2 en la B: `C-b` `↑`, y después `C-b` `↓`
      y enseguida `↑`. Te quedas abajo y la shell muestra `echo historia`
      en la línea (el `↑` llegó a ella). Vacía la línea con `C-u`. En A:
      ```bash
      tmux -L lab display -p '#{pane_index}'
      ```
      ```
      1
      ```

4. **`repeat-time` es de todos.** Es una opción de sesión: afecta a todas
   las teclas con `-r`. Con 0, `-r` no repite (terminal A):
   ```bash
   tmux -L lab set -g repeat-time 0
   ```
   ```
   (sin salida)
   ```
   En la B, en el panel de abajo, `C-b` `K` `K`: el borde sube una
   vez y la segunda `K` aparece en la shell. Bórrala con `Backspace`.
   Vuelve al valor por defecto:
   ```bash
   tmux -L lab set -gu repeat-time
   tmux -L lab show -gv repeat-time
   ```
   ```
   500
   ```

5. **TODO 3: navegar sin prefix.** Pista: `bind -n M-Up select-pane -U` y
   las otras tres. `-n` es lo mismo que `-T root`.
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T root M-Up
   ```
   ```
   0
   bind-key -T root M-Up select-pane -U
   ```
   En la B, `Alt`+`↑` y `Alt`+`↓` cambian de panel sin prefix. En A, tras
   `Alt`+`↓`:
   ```bash
   tmux -L lab display -p '#{pane_index}'
   ```
   ```
   1
   ```
   Si tu terminal usa `Alt`+flecha para otra cosa (algunas cambian de
   pestaña), tmux no la recibe: prueba en otra terminal o cambia el atajo
   de la terminal. En macOS, la Terminal necesita "Usar Opción como tecla
   Meta".

6. **Robar una tecla de verdad.** En la B, en el panel de abajo, escribe
   `ech` y pulsa `Tab`: bash completa `echo`. Vacía la línea con `C-u`.
   Ahora, en la terminal A:
   ```bash
   tmux -L lab bind -n Tab display 'Tab robada'
   tmux -L lab list-keys -T root Tab
   ```
   ```
   bind-key -T root Tab display-message "Tab robada"
   ```
   En la B, `ech` + `Tab`: no se completa nada y la barra muestra
   `Tab robada`. Ningún programa de ningún panel recibe ya `Tab`. Vacía la
   línea con `C-u` y devuélvela (terminal A):
   ```bash
   tmux -L lab unbind -n Tab
   tmux -L lab list-keys -T root Tab
   ```
   ```
   unknown key: Tab
   ```
   En la B, `ech` + `Tab` vuelve a completar. Sal con `C-b` `d`:
   ```
   [detached (from session lab)]
   ```

7. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué en el paso 2 el `↑` no llegó al historial de la shell
- [ ] `tmux -L lab list-keys -T prefix K` muestra `bind-key -r -T prefix K resize-pane -U 5` y `C-b` `K` `K` `K` mueve el borde tres veces (paso 3.1)
- [ ] `tmux -L lab list-keys -T prefix Up` ya no tiene `-r` y `↑` tras `C-b` `↑` llega a la shell (paso 3.2)
- [ ] Con `repeat-time 0` la segunda `K` llega a la shell (paso 4)
- [ ] `tmux -L lab list-keys -T root M-Up` muestra `select-pane -U` (paso 5)
- [ ] `bind -n Tab` deja a bash sin autocompletado y `unbind -n Tab` lo devuelve (paso 6)

## Reto extra

Con `-r`, ¿qué pasa si pulsas `C-b` `K` y, dentro del medio segundo, una
tecla **sin** `-r` como `c`? ¿Y una que no está en la tabla `prefix`, como
`a`? Pruébalo y explica qué ves en cada caso.
