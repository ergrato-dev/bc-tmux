# Lab 03 — Layouts

⏱ Duración estimada: ~60 min

## Objetivo

Recorrer los cinco layouts predefinidos, ajustar el panel principal en porcentaje y guardar y restaurar un layout propio.

## Contexto

- Un **layout** es la forma en que se reparten los paneles de una ventana. tmux trae cinco: `even-horizontal`, `even-vertical`, `main-horizontal`, `main-vertical` y `tiled` (dibujados en [02-layouts-y-reorganizacion.md](../../1-teoria/02-layouts-y-reorganizacion.md)).
- Los `main-*` tienen un panel principal, el **primero** de la ventana. Su tamaño lo fijan las opciones de ventana `main-pane-width` y `main-pane-height`, en celdas o en porcentaje.
- Cualquier reparto, incluido uno hecho a mano, se puede leer como texto con `#{window_layout}` y volver a aplicar con `select-layout`.

## Instrucciones

- **Terminal A**: conectada a la sesión del lab; ahí pulsas las teclas.
- **Terminal B**: otra pestaña, fuera de tmux, para los comandos.

0. En **las dos** terminales, fuera de tmux (`echo "$TMUX"` imprime una línea
   vacía), entra en la carpeta del lab desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-03-layouts
   ```
   ```
   (sin salida)
   ```
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`: el prefix es
   **`C-b`**.

1. En la **terminal A**, abre una ventana con cuatro paneles:
   ```bash
   tmux -L lab -f /dev/null new -s layouts \; split-window \; split-window \; split-window
   ```
   En la **terminal B**, mira cómo quedaron:
   ```bash
   tmux -L lab list-panes -t layouts -F '#{pane_index} #{pane_id} #{pane_width}x#{pane_height}'
   ```
   Algo como (con una terminal de 80x25; la barra de abajo se come una fila):
   ```
   0 %0 80x12
   1 %1 80x5
   2 %2 80x2
   3 %3 80x2
   ```
   Cada panel sale más bajo que el anterior: tmux reparte el espacio del panel
   que parte, no el de toda la ventana.

2. **Recorre los layouts** en la terminal A:

   | Teclas | Layout |
   |---|---|
   | `C-b` `Alt`+`1` | `even-horizontal`: columnas iguales |
   | `C-b` `Alt`+`2` | `even-vertical`: filas iguales |
   | `C-b` `Alt`+`3` | `main-horizontal`: principal arriba, resto abajo |
   | `C-b` `Alt`+`4` | `main-vertical`: principal a la izquierda, resto a la derecha |
   | `C-b` `Alt`+`5` | `tiled`: cuadrícula |
   | `C-b` `Espacio` | El siguiente de la lista |
   | `C-b` `E` (mayúscula) | Reparte por igual sin cambiar la forma |

   Si `Alt`+número no llega a tmux (en macOS necesitas "Usar Opción como
   Meta" en Terminal o iTerm2), usa el prompt: `C-b` `:`, escribe
   `select-layout main-vertical` y Enter.

   Con `main-vertical` en una terminal de unas 80 columnas, los tres paneles de
   la derecha se quedan en **una columna**. No es un fallo: `main-pane-width`
   vale 80 celdas por defecto y el principal se come casi toda la ventana:
   ```bash
   tmux -L lab show -gw main-pane-width
   tmux -L lab list-panes -t layouts -F '#{pane_index} #{pane_width}x#{pane_height}'
   ```
   Algo como (con 80 columnas; en una terminal ancha el principal mide 80):
   ```
   main-pane-width 80
   0 78x24
   1 1x7
   2 1x7
   3 1x8
   ```

3. **Panel principal en porcentaje.** En la terminal B:
   ```bash
   tmux -L lab set -w -t layouts:0 main-pane-width 60%
   tmux -L lab select-layout -t layouts:0 main-vertical
   tmux -L lab list-panes -t layouts:0 -F '#{pane_index} #{pane_left} #{pane_width} de #{window_width}'
   ```
   Algo como (con 80 columnas):
   ```
   0 0 47 de 80
   1 48 32 de 80
   2 48 32 de 80
   3 48 32 de 80
   ```
   El 60 % de 80 son 48 columnas: 47 para el panel 0 y 1 para el borde; los
   demás empiezan en la columna 48. Con un porcentaje, el reparto se adapta si
   cambias el tamaño de la terminal; con un número fijo de celdas, no. Es la
   base del layout de tu proyecto.

4. **Cambiar el principal.** En la terminal A, ve al panel 2 (`C-b` `q` y,
   mientras se ven los números, `2`) y escribe `echo PRINCIPAL` y Enter, para
   reconocerlo. Pulsa `C-b` `{` (intercambia el panel activo con el anterior;
   el foco lo acompaña) y otra vez `C-b` `{`: son dos pulsaciones completas,
   prefix incluido. El panel de `PRINCIPAL` ocupa ahora la columna izquierda.
   Vuelve a aplicar `C-b` `Alt`+`4`. En la terminal B:
   ```bash
   tmux -L lab list-panes -t layouts:0 -F '#{pane_index} #{pane_id} #{pane_active}'
   ```
   ```
   0 %2 1
   1 %0 0
   2 %1 0
   3 %3 0
   ```
   El id `%2` viajó del índice 2 al 0: en `main-*`, el principal es siempre el
   índice 0.

5. **Tu propio layout.** En la terminal A, con el panel `PRINCIPAL` activo,
   mantén `Ctrl`, pulsa `b` y, sin soltar `Ctrl`, `←` ocho veces (el borde se
   mueve a la izquierda). Ve al panel 2 (`C-b` `q` `2`) y haz lo mismo con
   `↑` tres veces. Ya no es ninguno de los cinco layouts. Léelo en la
   terminal B:
   ```bash
   tmux -L lab display-message -p -t layouts:0 '#{window_layout}'
   ```
   Algo como (cambia con el tamaño de tu terminal y con cuánto moviste):
   ```
   1e56,80x24,0,0{39x24,0,0,2,40x24,40,0[40x7,40,0,0,40x4,40,8,1,40x11,40,13,3]}
   ```
   - `1e56`: suma de control (cuatro cifras hexadecimales).
   - `80x24,0,0`: tamaño total y esquina.
   - `{...}`: hijos en columnas; `[...]`: hijos en filas.
   - `39x24,0,0,2`: un panel como `ANCHOxALTO,X,Y,ID`. El ID es el número de
     `%2`. Los contenedores (`40x24,40,0[...]`) no llevan ID.

6. **Guardar y restaurar.** `starter/layout.sh save` escribe el layout en
   un archivo y `load` lo aplica. Trabaja en la terminal B.

   1. **TODO 1**: descomenta `tmx list-panes -t "$window" >/dev/null`. Con
      `set -e`, si la ventana no existe el script se para ahí. Borra también
      la última línea, `echo "layout.sh: $action sin implementar ..."`.
      ```bash
      ./starter/layout.sh save layouts:5 /tmp/mio.layout; echo $?
      ```
      ```
      can't find window: 5
      1
      ```
      Con `display-message -p -t layouts:5` no habría error: tmux cae en otra
      ventana y sale con 0.
   2. **TODO 2** (`save`): las dos líneas de la pista.
      ```bash
      ./starter/layout.sh save layouts:0 /tmp/mio.layout
      cat /tmp/mio.layout
      ```
      Algo como (el mismo texto que el paso 5):
      ```
      guardado en /tmp/mio.layout
      1e56,80x24,0,0{39x24,0,0,2,40x24,40,0[40x7,40,0,0,40x4,40,8,1,40x11,40,13,3]}
      ```
   3. **TODO 3** (`load`): `"$(<"$file")"` es el contenido del
      archivo como un solo argumento. Rompe el layout a propósito, restáuralo y
      compara con el `cat` de arriba:
      ```bash
      tmux -L lab select-layout -t layouts:0 tiled
      tmux -L lab display-message -p -t layouts:0 '#{window_layout}'
      ./starter/layout.sh load layouts:0 /tmp/mio.layout
      tmux -L lab display-message -p -t layouts:0 '#{window_layout}'
      ```
      Algo como:
      ```
      3855,80x24,0,0[80x11,0,0{39x11,0,0,2,40x11,40,0,0},80x12,0,12{39x12,0,12,1,40x12,40,12,3}]
      restaurado desde /tmp/mio.layout
      1e56,80x24,0,0{39x24,0,0,2,40x24,40,0[40x7,40,0,0,40x4,40,8,1,40x11,40,13,3]}
      ```
      La última línea es idéntica a `cat /tmp/mio.layout`, y en la terminal A
      la ventana vuelve al reparto que hiciste a mano.

7. Limpia. En la terminal A, `C-b` `d`:
   ```
   [detached (from session layouts)]
   ```
   En la terminal B:
   ```bash
   tmux -L lab kill-server; rm -f /tmp/mio.layout
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Pasaste por los cinco layouts y sabes cuál es el principal en `main-*` (pasos 2 y 4)
- [ ] Con `main-pane-width 60%` el panel principal ocupa el 60 % de la ventana, borde incluido (paso 3)
- [ ] Explicas qué significan los números de un `#{window_layout}` (paso 5)
- [ ] `layout.sh load` devuelve la ventana al layout guardado con `layout.sh save` (paso 6.3)

## Reto extra

Restaura el layout de 4 paneles en una ventana de 2 paneles. ¿Qué hace tmux?
¿Cómo lo detectarías antes de llamar a `select-layout`? (Es el punto 7 del
proyecto.)
