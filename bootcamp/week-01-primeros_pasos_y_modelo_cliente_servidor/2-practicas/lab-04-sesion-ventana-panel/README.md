# Lab 04 — Sesión, ventana y panel

⏱ Duración estimada: ~60 min

## Objetivo

Construir una sesión con varias ventanas y paneles, primero con el teclado y después con un script, e identificar cada objeto por su id.

## Contexto

- Una **sesión** tiene una o más **ventanas**; una ventana ocupa la pantalla entera y tiene uno o más **paneles**; cada panel ejecuta un programa.
- Cada objeto tiene un **id** que no cambia mientras exista: `$0` para sesiones, `@0` para ventanas, `%0` para paneles. Los índices (`0`, `1`) y los nombres sí pueden cambiar.
- Esta jerarquía es exactamente lo que dibuja `bin/kit-tree`, el script del proyecto.

## Instrucciones

1. Abre una sesión: `tmux -L lab new -s obra -n editor`.

2. Crea paneles y muévete entre ellos:

   | Teclas | Qué hace |
   |---|---|
   | `prefix` `%` | Divide el panel en dos, uno al lado del otro |
   | `prefix` `"` | Divide el panel en dos, uno encima del otro |
   | `prefix` flechas | Pasa al panel de esa dirección |
   | `prefix` `o` | Pasa al siguiente panel |
   | `prefix` `q` | Muestra el número de cada panel durante un segundo |
   | `prefix` `x` | Cierra el panel activo (pide confirmación con `y`) |

   Deja la ventana `editor` con **dos paneles lado a lado**.

3. Crea una segunda ventana y ponle nombre:
   - `prefix` `c` crea la ventana `1`.
   - `prefix` `,` la renombra: escribe `logs` y Enter.
   - `prefix` `0` y `prefix` `1` saltan entre ventanas; `prefix` `w` muestra el árbol de sesiones y ventanas.

4. Desde otra terminal, pide a tmux la lista completa de paneles con sus ids:
   ```bash
   tmux -L lab list-panes -a -F '#{session_id} #{window_id} #{pane_id}  #{session_name}:#{window_index}.#{pane_index}'
   ```
   ```
   $0 @0 %0  obra:0.0
   $0 @0 %1  obra:0.1
   $0 @1 %2  obra:1.0
   ```
   `obra:0.1` es el **target** de un panel: `sesión:ventana.panel`. Lo verás a
   fondo en la semana 03.

5. Cuenta sesiones y ventanas sin dibujar nada:
   ```bash
   tmux -L lab list-sessions -F '#{session_name} ventanas=#{session_windows}'
   ```
   ```
   obra ventanas=2
   ```
   Así se escribe cada línea `sesion ...` de `kit-tree`.

6. Ahora lo mismo **con un script**. Cierra todo (`tmux -L lab kill-server`),
   abre `starter/construir.sh` y resuelve los `TODO`: crea en segundo plano
   la sesión `obra` con la ventana `editor` partida en dos y la ventana `logs`,
   y termina listando los paneles con su ventana, índice e id. Ejecútalo:
   ```bash
   ./starter/construir.sh
   ```
   ```
   editor.0 %0
   editor.1 %1
   logs.0 %2
   ```
   La sangría de `kit-tree` (sesión, dos espacios para ventana, cuatro para
   panel) es esta misma estructura escrita en forma de árbol.

7. Conéctate (`tmux -L lab attach -t obra`) y comprueba que lo que construyó
   el script es igual a lo que hiciste a mano en los pasos 2 y 3.

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Construiste a mano la ventana `editor` con dos paneles y la ventana `logs`
- [ ] El comando del paso 4 muestra tres paneles con ids `%` distintos
- [ ] `./starter/construir.sh` en un servidor vacío imprime exactamente las tres líneas del paso 6
- [ ] Puedes explicar qué cambia y qué no cambia si renombras una ventana: su nombre, su índice y su id

## Reto extra

Cierra el panel `%0` con `tmux -L lab kill-pane -t %0` y vuelve a listar los
paneles. ¿Qué pasó con el índice del panel que quedaba? ¿Y con su id?
