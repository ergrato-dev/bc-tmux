# Lab 02 — Consultar con formatos

⏱ Duración estimada: ~60 min

## Objetivo

Leer el estado del servidor desde un script con `list-* -F` y `-f`, recorrerlo línea a línea sin romper nombres con espacios y validar un target con el único comando que falla cuando no existe.

## Contexto

- `-F` elige qué imprime cada línea (los `#{...}` de la semana 07) y `-f` filtra: solo salen las líneas cuyo format da algo distinto de vacío o `0`.
- La salida de tmux se lee con `while IFS= read -r`: un `for` sobre `$(...)` parte por espacios.
- `display -p -t X` **no falla** si `X` no existe: sale con 0 y enseña otro objeto, o nada. `list-panes -t X` sí falla.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-02-consultar-con-formatos
   ```
   Arranca el servidor `-L lab` como dice [Antes de cada lab](../README.md#antes-de-cada-lab)
   (paso 3).

1. **Tres sesiones de prueba**, una con espacio en el nombre:
   ```bash
   tmux -L lab new-session -d -s api -n editor -c /tmp/lab09 \; new-window -d -n run -c /tmp/lab09 \; split-window -d -t api:run -c /tmp/lab09 \; new-session -d -s api-2 -c /tmp/lab09 \; new-session -d -s 'con espacio' -c /tmp/lab09
   tmux -L lab list-sessions -F '#{session_id} #{session_name} #{session_windows}'
   ```
   ```
   $0 api 2
   $1 api-2 1
   $2 con espacio 1
   ```

2. **Filtrar con `-f`.** `#{m:patrón,valor}` compara con comodines;
   `#{==:a,b}`, igualdad; `#{&&:x,y}`, las dos cosas:
   ```bash
   tmux -L lab list-sessions -F '#{session_name}' -f '#{m:api*,#{session_name}}'
   tmux -L lab list-windows -a -F '#{session_name}:#{window_index} #{window_name} #{window_panes}'
   tmux -L lab list-windows -a -F '#{session_name}:#{window_index}' -f '#{==:#{window_name},run}'
   tmux -L lab list-panes -a -F '#{pane_id} #{session_name}:#{window_name}' -f '#{&&:#{==:#{session_name},api},#{pane_active}}'
   ```
   ```
   api
   api-2
   api:0 editor 1
   api:1 run 2
   api-2:0 bash 1
   con espacio:0 bash 1
   api:1
   %0 api:editor
   %1 api:run
   ```
   `-a` recorre todo el servidor. El último es "el panel activo de cada
   ventana de `api`". Una ventana sin `-n` se llama como su programa
   (`bash`, o `zsh` si es tu shell).

3. **`for` frente a `while read`:**
   ```bash
   for s in $(tmux -L lab list-sessions -F "#{session_name}"); do echo "[$s]"; done
   tmux -L lab list-sessions -F "#{session_name}" | while IFS= read -r s; do echo "[$s]"; done
   ```
   ```
   [api]
   [api-2]
   [con]
   [espacio]
   [api]
   [api-2]
   [con espacio]
   ```
   El `for` ve cuatro sesiones. `IFS=` conserva los espacios de los
   extremos y `-r` las barras invertidas.

4. **`display -p` no valida; `list-panes` sí:**
   ```bash
   tmux -L lab display -p -t noexiste '[#{session_name}]'; echo $?
   tmux -L lab display -p -t api:run.5 '#{pane_id}'; echo $?
   tmux -L lab list-panes -t noexiste -F '#{pane_id}'; echo $?
   tmux -L lab list-panes -t api:run.5 -F '#{pane_id}'; echo $?
   tmux -L lab list-panes -t api:run.1 -F '#{pane_id}'; echo $?
   ```
   ```
   []
   0
   %1
   0
   can't find window: noexiste
   1
   can't find pane: 5
   1
   %1
   %2
   0
   ```
   `api:run.5` no existe y `display -p` contesta `%1` con 0: un script que
   validara así escribiría en otro panel. `list-panes` lista todos los
   paneles de la ventana, así que sirve para validar, no para elegir uno.

5. **Completa `starter/inspect`.** Sin tocar nada:
   ```bash
   ./starter/inspect tree; echo $?
   ./starter/inspect pane api:run.1; echo $?
   ```
   ```
   sin implementar
   0
   sin implementar: api:run.1
   0
   ```

   1. **TODOs 1 y 2 — `show_tree`.** Sustituye el `echo "sin implementar"`
      de `show_tree` (bórralo) por el bucle
      `tmx list-sessions -F '#{session_name}' | while IFS= read -r session; do ... done`.
      Dentro: `echo "$session"` y
      `tmx list-windows -t "=$session" -F '  #{window_index} #{window_name} paneles: #{window_panes}'`.
      El `=` es "nombre exacto": sin él, la sesión `api` también
      aceptaría `api-2` si `api` no existiera.
      ```bash
      ./starter/inspect tree; echo $?
      ```
      ```
      api
        0 editor paneles: 1
        1 run paneles: 2
      api-2
        0 bash paneles: 1
      con espacio
        0 bash paneles: 1
      0
      ```
   2. **TODO 3 — validar.** En `show_pane`, borra el
      `echo "sin implementar: $target"` y valida con
      `tmx list-panes -t "$target" -F '#{pane_id}' >/dev/null 2>&1 || { echo "inspect: no existe el target '$target'" >&2; exit 1; }`.
      ```bash
      ./starter/inspect pane api:run.5; echo $?
      ./starter/inspect pane noexiste; echo $?
      ```
      ```
      inspect: no existe el target 'api:run.5'
      1
      inspect: no existe el target 'noexiste'
      1
      ```
   3. **TODO 4 — el informe.** Después de validar:
      `tmx display -p -t "$target" '#{pane_id} #{pane_current_command} #{pane_current_path}'`.
      ```bash
      ./starter/inspect pane api:run.1; echo $?
      ```
      ```
      %2 bash /tmp/lab09
      0
      ```
      Con `zsh` como shell sale `zsh`.

6. **Uso y sin servidor:**
   ```bash
   ./starter/inspect; echo $?
   TMUX_SOCKET=nada ./starter/inspect tree; echo $?
   ```
   ```
   Uso: inspect tree           sesiones y ventanas, en árbol
        inspect pane TARGET    id, comando y ruta del panel TARGET
        TMUX_SOCKET=lab ./starter/inspect tree
   2
   error connecting to /tmp/tmux-1000/nada (No such file or directory)
   1
   ```
   `usage` imprime las líneas 4 a 6 de la cabecera del script. El `1000`
   es tu uid. `list-sessions` no arranca un servidor: falla, y `pipefail`
   hace que el bucle entero falle con él.

7. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `list-sessions -f '#{m:api*,#{session_name}}'` devuelve `api` y `api-2` y explicas cada operador del filtro del paso 2
- [ ] Explicas por qué el `for` del paso 3 ve cuatro sesiones
- [ ] Explicas por qué `display -p -t api:run.5` no sirve para validar y qué hace `list-panes` en su lugar (paso 4)
- [ ] `./starter/inspect tree` muestra `con espacio` como una sola sesión (paso 5.1)
- [ ] `./starter/inspect pane api:run.5` sale con 1 y `pane api:run.1` imprime `%2` (pasos 5.2 y 5.3)

## Reto extra

Añade `inspect busy`: los paneles de todo el servidor cuyo programa no es
una shell, con un solo `list-panes -a` y un filtro `-f` que use `#{!=:...}`
o `#{m:...}` sobre `#{pane_current_command}`. Pruébalo con
`tmux -L lab send-keys -t api:editor 'sleep 60' Enter`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Crear sin conectarse](../lab-01-crear-sin-conectarse/README.md) | [Lab 03 — Enviar teclas con cuidado](../lab-03-enviar-teclas-con-cuidado/README.md) → |

[↑ Semana 09](../../README.md)
