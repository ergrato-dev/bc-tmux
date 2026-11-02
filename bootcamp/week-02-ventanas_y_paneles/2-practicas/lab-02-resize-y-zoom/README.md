# Lab 02 — Tamaño y zoom

⏱ Duración estimada: ~60 min

## Objetivo

Cambiar el tamaño de un panel con el teclado y con medidas exactas (celdas y porcentajes), y usar el zoom para concentrarte en un panel sin perder los demás.

## Contexto

- El tamaño se mide en **celdas**: columnas de ancho y filas de alto. Un panel de 80x24 tiene 80 columnas y 24 filas.
- `resize-pane` acepta direcciones (`-L -R -U -D` y un número de celdas) o medidas absolutas (`-x` ancho, `-y` alto), en celdas o en porcentaje de la ventana.
- El **zoom** (`prefix` `z`) agranda un panel a toda la ventana. Los demás siguen corriendo, ocultos. `prefix` `z` otra vez lo devuelve a su sitio.

## Instrucciones

1. Abre una sesión con dos paneles lado a lado:
   ```bash
   tmux -L lab new -s medidas \; split-window -h
   ```
   El `\;` encadena dos comandos de tmux en una sola llamada.

2. Cambia el tamaño con el teclado:

   | Teclas | Qué hace |
   |---|---|
   | `prefix` `Ctrl`+flecha | Mueve el borde 1 celda (repite sin volver a pulsar el prefix) |
   | `prefix` `Alt`+flecha | Mueve el borde 5 celdas |

   Si `Alt`+flecha no hace nada, tu terminal se queda esas teclas: en
   Windows Terminal y en macOS hay que configurarlo. Usa la versión con
   `Ctrl`.

3. Ahora con medidas exactas, desde otra terminal:
   ```bash
   tmux -L lab resize-pane -t medidas:0.0 -x 30
   tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}x#{pane_height}'
   tmux -L lab resize-pane -t medidas:0.0 -x 70%
   tmux -L lab list-panes -t medidas -F '#{pane_index} #{pane_width}x#{pane_height} de #{window_width}'
   ```
   El panel 0 mide 30 columnas y después el 70 % del ancho de la ventana (una
   columna menos: el borde también ocupa una).

4. **Zoom.** En el panel 1 ejecuta `top` y pulsa `prefix` `z`. El panel ocupa
   toda la ventana y en la status line aparece `Z` junto al nombre de la
   ventana. Compruébalo desde fuera:
   ```bash
   tmux -L lab display-message -p -t medidas '#{window_zoomed_flag}'   # 1
   ```
   Pulsa `prefix` `z` otra vez: vuelve todo a su sitio y `top` siguió
   actualizándose mientras tanto. Moverte a otro panel con `prefix` flechas
   también quita el zoom.

5. Completa `starter/ajustar.sh`: recibe un panel y un porcentaje, ajusta el
   **ancho** del panel a ese porcentaje y dice cuánto mide ahora.
   ```bash
   ./starter/ajustar.sh medidas:0.0 25
   ```
   ```
   medidas:0.0 mide 19 de 80 columnas (25 %)
   ```
   (Los números dependen del ancho de tu terminal.) Debe rechazar un
   porcentaje que no esté entre 10 y 90 con un mensaje y código de salida 2.

6. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Cambias el tamaño con `prefix` `Ctrl`+flecha repitiendo la flecha sin volver a pulsar el prefix
- [ ] `resize-pane -x 30` deja el panel exactamente en 30 columnas
- [ ] `#{window_zoomed_flag}` vale 1 con zoom y 0 sin él
- [ ] `./starter/ajustar.sh medidas:0.0 25` deja el panel en torno al 25 % y `ajustar.sh medidas:0.0 95` sale con 2

## Reto extra

Con dos clientes de tamaños distintos conectados a `medidas` (lab 02 de la
semana 01), ¿los porcentajes se calculan sobre qué ancho? Pruébalo con
`ajustar.sh` desde cada terminal.
