# Lab 04 — Mover paneles y ventanas

⏱ Duración estimada: ~60 min

## Objetivo

Sacar un panel a su propia ventana, meterlo en otra, e intercambiar paneles y ventanas sin cerrar ningún programa.

## Contexto

- Un panel no está atado a su ventana: puedes **sacarlo** (`break-pane`) a una ventana nueva o **unirlo** (`join-pane`) a otra ventana. El programa sigue corriendo durante el viaje.
- `swap-pane` intercambia dos paneles de sitio; `rotate-window` los gira todos. `swap-window` y `move-window` hacen lo mismo con ventanas.
- `join-pane -s ORIGEN -t DESTINO`: `-s` (source) es lo que mueves, `-t` (target) es dónde lo pones.

## Instrucciones

- **Terminal A**: conectada a la sesión del lab; ahí pulsas las teclas.
- **Terminal B**: otra pestaña, fuera de tmux, para los comandos.

0. En **las dos** terminales, fuera de tmux (`echo "$TMUX"` imprime una línea
   vacía), entra en la carpeta del lab desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-04-mover-paneles-y-ventanas
   ```
   ```
   (sin salida)
   ```
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`: el prefix es
   **`C-b`**.

1. En la **terminal A**, prepara dos ventanas con un programa en cada una:
   `top` en `codigo` y un contador en `logs`:
   ```bash
   tmux -L lab -f /dev/null new -s mover -n codigo \; send-keys 'top' Enter \; new-window -n logs \; send-keys 'n=0; while sleep 1; do n=$((n+1)); echo "paso $n"; done' Enter
   ```
   La terminal A muestra la ventana `logs` con `paso 1`, `paso 2`... En la
   **terminal B**:
   ```bash
   tmux -L lab list-windows -t mover -F '#{window_index} #{window_name} #{window_panes}'
   ```
   ```
   0 codigo 1
   1 logs 1
   ```

2. **Unir.** En la terminal B, mete el panel de `logs` en `codigo`, a la derecha:
   ```bash
   tmux -L lab join-pane -h -s mover:logs -t mover:codigo
   tmux -L lab list-windows -t mover -F '#{window_index} #{window_name} #{window_panes}'
   tmux -L lab list-panes -t mover:codigo -F '#{pane_index} #{pane_id} #{pane_current_command} #{pane_active}'
   ```
   ```
   0 codigo 2
   0 %0 top 0
   1 %1 sleep 1
   ```
   La ventana `logs` desaparece (se quedó sin paneles). En la terminal A ves
   `codigo` con `top` a la izquierda y el contador a la derecha, que **no se
   reinició**: sigue en el número donde iba. (`sleep` es lo que el bucle
   está ejecutando en ese instante.)

3. **Sacar.** El panel del contador quedó activo (el `1` del final). En la
   terminal A pulsa `C-b` `!`: el panel se va a una ventana nueva para él solo,
   con un nombre automático (`bash` o `sleep`). Renómbrala con `C-b` `,`: el
   prompt viene **relleno** con el nombre actual; bórralo con `C-u`, escribe
   `logs` y Enter. En la terminal B:
   ```bash
   tmux -L lab list-windows -t mover -F '#{window_index} #{window_name} #{window_panes}'
   ```
   ```
   0 codigo 1
   1 logs 1
   ```

4. **Marcar y unir con el teclado.** En la terminal A, en la ventana `logs`,
   pulsa `C-b` `m`: el panel queda **marcado** (borde resaltado). Ve a
   `codigo` con `C-b` `0` (o `C-b` `p`, la ventana anterior): ves `top` solo.
   Pulsa `C-b` `:`, escribe `join-pane -h` y Enter. Sin `-s`, `join-pane` usa
   el panel marcado, y la marca se borra al usarla. En la terminal B:
   ```bash
   tmux -L lab list-panes -t mover:codigo -F '#{pane_index} #{pane_id} #{pane_current_command} #{pane_marked}'
   ```
   ```
   0 %0 top 0
   1 %1 sleep 0
   ```

5. **Intercambiar paneles.** En la terminal A, con los dos paneles de `codigo`:

   | Teclas | Qué hace |
   |---|---|
   | `C-b` `{` / `C-b` `}` | Intercambia el panel activo con el anterior / el siguiente |
   | `C-b` `Ctrl`+`o` | Gira todos los paneles una posición |

   Pulsa `C-b` `{` y repite el `list-panes` en la terminal B:
   ```bash
   tmux -L lab list-panes -t mover:codigo -F '#{pane_index} #{pane_id} #{pane_current_command}'
   ```
   ```
   0 %1 sleep
   1 %0 top
   ```
   El **id** (`%1`) viaja con el panel; el **índice** se recalcula según la
   posición. `C-b` `Ctrl`+`o` lo devuelve a `0 %0 top` / `1 %1 sleep`.

6. **Mover e intercambiar ventanas.** Necesitas al menos dos. En la terminal A:
   1. `C-b` `c` crea una ventana nueva (índice 1). Renómbrala: `C-b` `,`,
      `C-u`, `notas`, Enter.
   2. `C-b` `.`: abajo aparece un prompt vacío que pide el índice de destino.
      Escribe `5` y Enter. La ventana `notas` pasa al índice 5.
   3. `C-b` `<`: se abre el menú de la ventana. Pulsa `l` (`Swap Left`):
      `notas` se intercambia con la ventana de su izquierda. Sal de cualquier
      menú sin elegir nada con `Esc` o `q`.

   En la terminal B:
   ```bash
   tmux -L lab list-windows -t mover -F '#{window_index} #{window_name}'
   ```
   ```
   0 notas
   5 codigo
   ```

7. **El script.** `starter/reorganizar.sh` une el panel de `logs` a `codigo`,
   cuenta los paneles y lo devuelve a su ventana, usando el id del panel: es
   lo único que no cambia durante el viaje. Necesita un escenario limpio:
   primero desconéctate en la terminal A con `C-b` `d`:
   ```
   [detached (from session mover)]
   ```
   Cada prueba, en la terminal B, recrea el escenario desde cero. El
   `sleep 1` da tiempo a que el servidor viejo termine de salir: `kill-server`
   vuelve antes, y un `new` inmediato choca con él (`server exited unexpectedly`).

   1. **TODO 1**: las dos líneas de la pista. Borra también la última línea,
      `echo "reorganizar.sh: sin implementar"`. Como el TODO no imprime nada,
      pruébalo con `bash -x`, que muestra cada asignación:
      ```bash
      tmux -L lab kill-server; sleep 1
      tmux -L lab -f /dev/null new -d -s mover -n codigo \; new-window -d -n logs
      bash -x ./starter/reorganizar.sh 2>&1 | grep '^+ panel='
      ```
      ```
      + panel=%1
      ```
   2. **TODO 2**: `join-pane` con `-d` (el foco no se mueve) y el
      `display-message` que cuenta.
      ```bash
      tmux -L lab kill-server; sleep 1
      tmux -L lab -f /dev/null new -d -s mover -n codigo \; new-window -d -n logs
      ./starter/reorganizar.sh
      ```
      ```
      codigo tiene 2 paneles
      ```
   3. **TODO 3**: `break-pane -s` es el panel que sacas (con `-t` sería la
      ventana de destino) y `-n logs` el nombre de la ventana nueva.
      ```bash
      tmux -L lab kill-server; sleep 1
      tmux -L lab -f /dev/null new -d -s mover -n codigo \; new-window -d -n logs
      ./starter/reorganizar.sh
      ```
      ```
      codigo tiene 2 paneles
      ventanas: codigo logs
      ```

8. Limpia en la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] El contador sobrevive a `join-pane` y a `break-pane` sin reiniciarse (pasos 2 y 3)
- [ ] Usaste `C-b` `m` para marcar un panel y unirlo con `join-pane` sin `-s` (paso 4)
- [ ] Explicas por qué el id de un panel no cambia al moverlo y su índice sí (paso 5)
- [ ] Moviste una ventana de índice con `C-b` `.` y la intercambiaste con `C-b` `<` (paso 6)
- [ ] `./starter/reorganizar.sh` imprime las dos líneas del paso 7.3

## Reto extra

`break-pane -d -n nombre` saca el panel sin cambiar tu foco. ¿Para qué te
serviría en un script que reorganiza la ventana de otra persona en pair
programming?
