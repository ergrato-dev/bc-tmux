# Lab 03 — Layouts

⏱ Duración estimada: ~60 min

## Objetivo

Recorrer los cinco layouts predefinidos, ajustar el panel principal en porcentaje y guardar y restaurar un layout propio.

## Contexto

- Un **layout** es la forma en que se reparten los paneles de una ventana. tmux trae cinco: `even-horizontal`, `even-vertical`, `main-horizontal`, `main-vertical` y `tiled` (dibujados en [02-layouts-y-reorganizacion.md](../../1-teoria/02-layouts-y-reorganizacion.md)).
- Los `main-*` tienen un panel principal, el **primero** de la ventana. Su tamaño lo fijan las opciones de ventana `main-pane-width` y `main-pane-height`, en celdas o en porcentaje.
- Cualquier reparto, incluido uno hecho a mano, se puede leer como texto con `#{window_layout}` y volver a aplicar con `select-layout`.

## Instrucciones

1. Abre una ventana con cuatro paneles:
   ```bash
   tmux -L lab new -s layouts \; split-window \; split-window \; split-window
   ```
   Los paneles salen cada vez más bajos: tmux reparte el espacio del panel
   que parte, no el de toda la ventana.

2. Recorre los layouts:

   | Teclas | Layout |
   |---|---|
   | `prefix` `Alt`+`1` | `even-horizontal`: columnas iguales |
   | `prefix` `Alt`+`2` | `even-vertical`: filas iguales |
   | `prefix` `Alt`+`3` | `main-horizontal`: principal arriba, resto abajo |
   | `prefix` `Alt`+`4` | `main-vertical`: principal a la izquierda, resto a la derecha |
   | `prefix` `Alt`+`5` | `tiled`: cuadrícula |
   | `prefix` `Espacio` | El siguiente de la lista |
   | `prefix` `E` | Reparte por igual sin cambiar la forma |

   Si `Alt`+número no llega a tmux, usa el prompt: `prefix` `:` y
   `select-layout main-vertical`.

3. Con `main-vertical` activo, cambia qué panel es el principal: ve al panel 2
   y pulsa `prefix` `{` dos veces (intercambia con el anterior) hasta que
   quede el primero. Vuelve a aplicar `prefix` `Alt`+`4`.

4. **Panel principal en porcentaje.** Desde otra terminal:
   ```bash
   tmux -L lab set -w -t layouts:0 main-pane-width 60%
   tmux -L lab select-layout -t layouts:0 main-vertical
   tmux -L lab list-panes -t layouts:0 -F '#{pane_index} #{pane_left} #{pane_width} de #{window_width}'
   ```
   El panel 0 empieza en la columna 0 y ocupa el 60 % del ancho (menos el
   borde). Con un porcentaje, el reparto se adapta si cambias el tamaño de la
   terminal; con un número fijo de celdas, no. Es la base del layout de tu
   proyecto.

5. **Tu propio layout.** Ajusta los bordes a mano con `prefix` `Ctrl`+flechas
   hasta tener un reparto que no sea ninguno de los cinco. Léelo:
   ```bash
   tmux -L lab display-message -p -t layouts:0 '#{window_layout}'
   ```
   ```
   b25f,80x24,0,0{40x24,0,0,0,39x24,41,0[39x11,41,0,1,39x5,41,12,2,39x6,41,18,3]}
   ```
   Los cuatro primeros caracteres son una suma de control; después va el
   tamaño total y, entre `{}` (columnas) o `[]` (filas), cada panel como
   `ANCHOxALTO,X,Y,ID`.

6. **Guardar y restaurar.** Completa `starter/layout.sh`: con `guardar`
   escribe el layout de la ventana en un archivo; con `restaurar` lo aplica.
   ```bash
   ./starter/layout.sh guardar layouts:0 /tmp/mio.layout
   tmux -L lab select-layout -t layouts:0 tiled     # lo rompes a propósito
   ./starter/layout.sh restaurar layouts:0 /tmp/mio.layout
   ```
   La ventana vuelve exactamente al reparto que hiciste a mano. Compara
   `#{window_layout}` antes y después: son iguales.

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Pasaste por los cinco layouts y sabes cuál es el principal en `main-*`
- [ ] Con `main-pane-width 60%` el panel principal mide el 60 % de la ventana
- [ ] Explicas qué significan los números de un `#{window_layout}`
- [ ] `layout.sh restaurar` devuelve la ventana al layout guardado con `layout.sh guardar`

## Reto extra

Restaura el layout de 4 paneles en una ventana de 2 paneles. ¿Qué hace tmux?
¿Cómo lo detectarías antes de llamar a `select-layout`? (Es el punto 7 del
proyecto.)
