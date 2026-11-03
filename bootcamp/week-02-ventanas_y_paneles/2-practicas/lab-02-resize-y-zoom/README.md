# Lab 02 — Tamaño y zoom

⏱ Duración estimada: ~60 min

## Objetivo

Cambiar el tamaño de un panel con el teclado y con medidas exactas (celdas y porcentajes), y usar el zoom para concentrarte en un panel sin perder los demás.

## Contexto

- El tamaño se mide en **celdas**: columnas de ancho y filas de alto. Un panel de 80x24 tiene 80 columnas y 24 filas.
- `resize-pane` acepta direcciones (`-L -R -U -D` y un número de celdas) o medidas absolutas (`-x` ancho, `-y` alto), en celdas o en porcentaje de la ventana.
- El **zoom** (`prefix` `z`) agranda un panel a toda la ventana. Los demás siguen corriendo, ocultos. `prefix` `z` otra vez lo devuelve a su sitio.

## Instrucciones

- **Terminal A**: conectada a la sesión del lab; ahí pulsas las teclas.
- **Terminal B**: otra pestaña, fuera de tmux, para los comandos.

0. En **las dos** terminales, fuera de tmux (`echo "$TMUX"` imprime una línea
   vacía), entra en la carpeta del lab desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-02-resize-y-zoom
   ```
   ```
   (sin salida)
   ```
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`, sin config: el
   prefix es **`C-b`**.

1. En la **terminal A**, abre una sesión con dos paneles lado a lado:
   ```bash
   tmux -L lab -f /dev/null new -s medidas \; split-window -h
   ```
   El `\;` encadena dos comandos de tmux en una sola llamada. El panel activo
   es el de la derecha (el recién creado).

2. **Con el teclado.** Cada combinación mueve el borde del panel activo **en
   la dirección de la flecha**:

   | Teclas | Qué hace |
   |---|---|
   | `C-b` `Ctrl`+flecha | Mueve el borde 1 celda |
   | `C-b` `Alt`+flecha | Mueve el borde 5 celdas |

   Las dos se repiten sin volver a pulsar el prefix durante 500 ms. Secuencia
   exacta: mantén `Ctrl`, pulsa `b`, y sin soltar `Ctrl` pulsa `←` tres veces
   seguidas. El borde se mueve 3 columnas a la izquierda: el panel de la
   derecha crece. Compruébalo en la **terminal B**:
   ```bash
   tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}x#{pane_height} #{pane_active}'
   ```
   Algo como (con una terminal de 80 columnas; antes medían 40 y 39):
   ```
   0 37x24 0
   1 42x24 1
   ```
   Ahora `C-b` `Alt`+`→`: el borde vuelve 5 columnas a la derecha (`42` y `37`).

   **Si no pasa nada:** tu terminal se queda la tecla antes de que llegue a
   tmux. En macOS, `Ctrl`+flecha es de Mission Control (Ajustes del Sistema >
   Teclado > Atajos de teclado > Mission Control) y `Alt`+flecha necesita
   "Usar Opción como Meta" en Terminal o iTerm2. Sin tocar nada, usa el
   prompt de tmux: `C-b` `:`, escribe `resize-pane -L 3` y Enter.

3. **Con medidas exactas**, en la terminal B:
   ```bash
   tmux -L lab resize-pane -t medidas:0.0 -x 30
   tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}x#{pane_height}'
   ```
   Algo como (el `49` es lo que queda en tu terminal):
   ```
   0 30x24
   1 49x24
   ```
   `30 + 1 (el borde) + 49 = 80`. Ahora en porcentaje:
   ```bash
   tmux -L lab resize-pane -t medidas:0.0 -x 70%
   tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}x#{pane_height} de #{window_width}'
   ```
   ```
   0 56x24 de 80
   1 23x24 de 80
   ```
   El porcentaje se calcula sobre el ancho **de la ventana** (70 % de 80 = 56);
   la columna del borde se la quita el otro panel.

4. **Zoom.** En la terminal A, ve al panel de la derecha con `C-b` `→`,
   ejecuta `top` y pulsa `C-b` `z`. El panel ocupa toda la ventana y en la
   barra de abajo aparece `Z` junto al nombre de la ventana (`0:top*Z`).
   Compruébalo en la terminal B:
   ```bash
   tmux -L lab display-message -p -t medidas '#{window_zoomed_flag}'
   ```
   ```
   1
   ```
   Pulsa `C-b` `z` otra vez en A: todo vuelve a su sitio y `top` siguió
   actualizándose. En B, el mismo comando imprime ahora:
   ```
   0
   ```
   Moverte de panel también quita el zoom: `C-b` `z` y después `C-b` `←`.
   El `display-message` vuelve a imprimir `0`. Vuelve a `top` con `C-b` `→` y
   ciérralo con `q`.

5. **El script.** `starter/resize.sh` recibe un panel y un porcentaje, ajusta
   el **ancho** del panel a ese porcentaje y dice cuánto mide. Trabaja en la
   terminal B, con la sesión `medidas` viva.

   1. **TODO 1**: valida el porcentaje (número entre 10 y 90, ambos
      incluidos) y si no, mensaje por stderr y `exit 2`. La pista del starter
      trae el `if`. Borra también la última línea, `echo "resize.sh: sin implementar ..."`.
      ```bash
      ./starter/resize.sh medidas:0.0 95; echo $?
      ./starter/resize.sh medidas:0.0 25; echo $?
      ```
      ```
      el porcentaje debe ser un número entre 10 y 90: '95'
      2
      0
      ```
   2. **TODO 2**: `tmx resize-pane -t "$pane" -x "${percent}%"`.
      ```bash
      ./starter/resize.sh medidas:0.0 25
      tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}'
      ```
      Algo como (con 80 columnas):
      ```
      0 20
      1 59
      ```
   3. **TODO 3**: `tmx display-message -p -t "$pane" "$pane mide #{pane_width} de #{window_width} columnas ($percent %)"`.
      Las comillas dobles dejan que bash ponga `$pane` y `$percent`; los
      `#{...}` los rellena tmux.
      ```bash
      ./starter/resize.sh medidas:0.0 25
      ```
      Algo como (los números dependen del ancho de la terminal A):
      ```
      medidas:0.0 mide 20 de 80 columnas (25 %)
      ```

6. Limpia. En la terminal A, `C-b` `d`:
   ```
   [detached (from session medidas)]
   ```
   Y en la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Cambias el tamaño con `C-b` `Ctrl`+flecha repitiendo la flecha sin volver a pulsar el prefix (paso 2)
- [ ] `resize-pane -x 30` deja el panel exactamente en 30 columnas (paso 3)
- [ ] `#{window_zoomed_flag}` vale 1 con zoom y 0 sin él (paso 4)
- [ ] `./starter/resize.sh medidas:0.0 25` deja el panel en el 25 % y `resize.sh medidas:0.0 95` sale con 2 (paso 5)

## Reto extra

Con dos clientes de tamaños distintos conectados a `medidas` (lab 02 de la
semana 01), ¿los porcentajes se calculan sobre qué ancho? Pruébalo con
`resize.sh` mientras cambias cuál de las dos terminales usaste por última vez
(pista: `tmux -L lab show -gv window-size`).
