# Lab 04 — Sesión, ventana y panel

⏱ Duración estimada: ~60 min

## Objetivo

Construir una sesión con varias ventanas y paneles, primero con el teclado y después con un script, e identificar cada objeto por su id.

## Contexto

- Una **sesión** tiene una o más **ventanas**; una ventana ocupa la pantalla entera y tiene uno o más **paneles**; cada panel ejecuta un programa.
- Cada objeto tiene un **id** que no cambia mientras exista: `$0` para sesiones, `@0` para ventanas, `%0` para paneles. Los índices (`0`, `1`) y los nombres sí pueden cambiar.
- Esta jerarquía es exactamente lo que dibuja `bin/kit-tree`, el script del proyecto.

Necesitas dos terminales: **A** (conectada a tmux) y **B** (fuera de tmux).
El servidor `lab` arranca con `-f /dev/null`: el prefix es `C-b`
(**Ctrl+b**, suelta, y la tecla).

## Instrucciones

0. **Prepara las dos terminales.** En A y en B, fuera de tmux y desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-04-sesion-ventana-panel
   echo "$TMUX"
   ```
   `echo` imprime una línea vacía. Solo en B, borra restos anteriores con
   `tmux -L lab kill-server` (si no había servidor imprime
   `no server running on ...` o `error connecting to ...`: es normal).

1. **Terminal A.** Abre una sesión cuya primera ventana se llama `editor`:
   ```bash
   tmux -L lab -f /dev/null new -s obra -n editor
   ```
   La status line dice `[obra] 0:editor*`.

2. **Terminal A, paneles.** Haz, en este orden:

   | Teclas | Qué hace | Qué ves |
   |---|---|---|
   | `C-b` `%` | Divide el panel en dos, uno al lado del otro | Una línea vertical; el cursor pasa al panel derecho |
   | `C-b` `←` | Pasa al panel de la izquierda (`→`, `↑`, `↓` igual) | El borde verde rodea el panel activo |
   | `C-b` `o` | Pasa al siguiente panel | El cursor vuelve al derecho |
   | `C-b` `q` | Muestra el número de cada panel durante un segundo | Un `0` y un `1` grandes |
   | `C-b` `"` | Divide el panel activo en dos, uno encima del otro | Tres paneles |
   | `C-b` `x` | Cierra el panel activo | Abajo, en amarillo, `kill-pane 2? (y/n)`: pulsa `y` |

   Tras `C-b` puedes pulsar varias flechas seguidas sin repetir el prefix
   (durante medio segundo). Al terminar, la ventana `editor` tiene **dos
   paneles lado a lado**.

3. **Terminal A, ventanas.**
   - `C-b` `c` crea la ventana `1`: la status line dice `0:editor- 1:bash*`.
   - `C-b` `,` abre el prompt `(rename-window) bash` **ya relleno** con el
     nombre actual. Bórralo con `C-u`, escribe `logs` y pulsa Enter:
     `0:editor- 1:logs*`.
   - `C-b` `0` y `C-b` `1` saltan entre ventanas.
   - `C-b` `w` muestra el árbol de la sesión:
     ```
     (0) - obra: 2 windows (attached)
     (1) ├─> + 0: editor-
     (2) └─>   1: logs*
     ```
     `↑`/`↓` mueven la selección, `→` despliega los paneles de una ventana
     (el `+`), Enter salta a la seleccionada y `q` sale sin cambiar nada.

4. **Terminal B.** Pide a tmux la lista completa de paneles con sus ids:
   ```bash
   tmux -L lab list-panes -a -F '#{session_id} #{window_id} #{pane_id}  #{session_name}:#{window_index}.#{pane_index}'
   ```
   ```
   $0 @0 %0  obra:0.0
   $0 @0 %1  obra:0.1
   $0 @1 %3  obra:1.0
   ```
   La ventana `logs` tiene `%3` y no `%2`: el `%2` era el panel que cerraste
   con `C-b` `x`, y los ids no se reutilizan. `obra:0.1` es el **target** de un panel:
   `sesión:ventana.panel`. Lo verás a fondo en la semana 03.

5. **Terminal B.** Cuenta sesiones y ventanas sin dibujar nada:
   ```bash
   tmux -L lab list-sessions -F '#{session_name} ventanas=#{session_windows}'
   ```
   ```
   obra ventanas=2
   ```
   Así se escribe cada línea `sesion ...` de `kit-tree`.

6. **Lo mismo con un script.** **Terminal B:** borra el servidor para que el
   script empiece de cero:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida en B). La terminal A recibe `[server exited]`: el servidor al
   que estaba conectada ya no existe. Abre `starter/build.sh`; cada TODO
   se prueba en B con el servidor vacío y se borra el servidor después.

   **TODO 1: la sesión.** Escribe debajo del comentario:
   ```bash
   tmx new-session -d -s obra -n editor
   ```
   ```bash
   ./starter/build.sh
   tmux -L lab list-windows -t obra -F '#{window_index}:#{window_name} paneles=#{window_panes}'
   tmux -L lab kill-server
   ```
   ```
   0:editor paneles=1
   ```

   **TODO 2: el segundo panel.** `split-window -h` divide en horizontal (lado
   a lado) y `-t obra:editor` dice qué ventana:
   ```bash
   tmx split-window -h -t obra:editor
   ```
   Repite los tres comandos de prueba del TODO 1:
   ```
   0:editor paneles=2
   ```

   **TODO 3: la ventana `logs`.** `-t obra:` (con dos puntos) significa "la
   siguiente ventana libre de la sesión `obra`"; `-d` no la activa:
   ```bash
   tmx new-window -d -t obra: -n logs
   ```
   Repite la prueba:
   ```
   0:editor paneles=2
   1:logs paneles=1
   ```

   **TODO 4: el listado.** `-s` lista los paneles de todas las ventanas de la
   sesión, no solo de la activa:
   ```bash
   tmx list-panes -s -t obra -F '#{window_name}.#{pane_index} #{pane_id}'
   ```
   Esta vez ejecuta solo el script (sin `kill-server` después):
   ```bash
   ./starter/build.sh
   ```
   ```
   editor.0 %0
   editor.1 %1
   logs.0 %2
   ```
   La sangría de `kit-tree` (sesión, dos espacios para ventana, cuatro para
   panel) es esta misma estructura escrita en forma de árbol.

7. **Terminal A.** Conéctate a lo que construyó el script:
   ```bash
   tmux -L lab attach -t obra
   ```
   Comprueba con `C-b` `w` (sal con `q`) que es igual a lo que hiciste a mano
   en los pasos 2 y 3. Sal con `C-b` `d`:
   `[detached (from session obra)]`.

8. Limpia, desde B:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida)

## Criterios de éxito

- [ ] Construiste a mano la ventana `editor` con dos paneles y la ventana `logs` (pasos 2 y 3)
- [ ] El comando del paso 4 muestra tres paneles con ids `%` distintos y sin el `%2` que cerraste
- [ ] `./starter/build.sh` en un servidor vacío imprime exactamente las tres líneas del TODO 4 (paso 6)
- [ ] Puedes explicar qué cambia y qué no cambia si renombras una ventana: su nombre, su índice y su id

## Reto extra

Con la sesión del paso 6 viva, cierra el panel `%0` con
`tmux -L lab kill-pane -t %0` y vuelve a ejecutar el `list-panes -s` del TODO
4. ¿Qué pasó con el índice del panel que quedaba? ¿Y con su id?
