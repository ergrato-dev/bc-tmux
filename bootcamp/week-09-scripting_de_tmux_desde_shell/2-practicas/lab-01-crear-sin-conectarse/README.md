# Lab 01 — Crear sin conectarse

⏱ Duración estimada: ~60 min

## Objetivo

Crear desde un script una sesión con dos ventanas y tres paneles en un directorio y un tamaño dados, sin conectarse, y capturar el id de cada panel para seguir trabajando con él.

## Contexto

- Un script no tiene terminal. `new-session` sin `-d` intenta conectarse y falla; con `-d` crea la sesión y vuelve.
- `-P -F '#{pane_id}'` imprime el id del objeto recién creado. Un id (`%3`) no cambia aunque renombres la ventana o tu config use otro `base-index`: es el target más seguro.
- `-x`/`-y` fijan el tamaño solo mientras ningún cliente está conectado; el primero que se conecta impone el suyo.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-01-crear-sin-conectarse
   ```
   Arranca el servidor `-L lab` como dice [Antes de cada lab](../README.md#antes-de-cada-lab)
   (paso 3). El prefix es **`C-b`**.

1. **Sin `-d` no hay sesión.** `</dev/null` simula un script sin terminal:
   ```bash
   tmux -L lab new-session -s x </dev/null; echo $?
   ```
   ```
   open terminal failed: not a terminal
   1
   ```

2. **Crear y capturar ids.** Una sesión `api` con la ventana `editor`, en
   `/tmp/lab09/api`, de 120x30:
   ```bash
   mkdir -p /tmp/lab09/api
   tmux -L lab new-session -d -s api -n editor -c /tmp/lab09/api -x 120 -y 30 -P -F '#{session_id} #{window_id} #{pane_id}'
   tmux -L lab display -p -t %0 '#{session_name}:#{window_name} #{pane_current_path} #{window_width}x#{window_height}'
   ```
   ```
   $0 @0 %0
   api:editor /tmp/lab09/api 120x30
   ```
   `$` es sesión, `@` ventana y `%` panel. El `-t %0` del segundo comando
   usa el id que imprimió el primero.

3. **Más ventanas y paneles, por id.** `api:` (con dos puntos) es "la
   sesión api, índice libre". `-d` crea sin cambiar la ventana o el panel
   activos:
   ```bash
   tmux -L lab new-window -d -t api: -n run -c /tmp/lab09/api -P -F '#{window_id} #{pane_id}'
   tmux -L lab split-window -h -d -t %1 -c /tmp/lab09/api -P -F '#{pane_id}'
   tmux -L lab list-panes -s -t =api -F '#{window_name} #{pane_id} #{pane_width}x#{pane_height} #{pane_current_path}'
   ```
   ```
   @1 %1
   %2
   editor %0 120x30 /tmp/lab09/api
   run %1 60x30 /tmp/lab09/api
   run %2 59x30 /tmp/lab09/api
   ```
   60 + 59 + el borde = 120. `-c` hace falta en cada `new-window` y
   `split-window`: sin él, el panel nuevo nace en el directorio desde el
   que ejecutas el comando (el de tu terminal o el del script), no en el de
   la sesión.

4. **Todo en una invocación.** `\;` encadena comandos en una sola llamada
   a tmux; los `new-window` sin `-t` van a la sesión recién creada:
   ```bash
   tmux -L lab kill-session -t =api
   tmux -L lab new-session -d -s api -n editor -c /tmp/lab09/api \; new-window -d -n run -c /tmp/lab09/api \; list-windows -t =api -F '#{window_index} #{window_name}'
   tmux -L lab kill-session -t =api
   ```
   ```
   0 editor
   1 run
   ```
   Es más rápido que una llamada por comando, pero no te deja guardar un id
   a mitad de camino: para eso, el script del paso 5.

5. **Completa `starter/make-workspace`.** Sin tocar nada, imprime ids
   vacíos:
   ```bash
   ./starter/make-workspace api /tmp/lab09/api; echo $?
   ```
   ```
   api en /tmp/lab09/api
   editor 
   run  
   0
   ```
   Cada prueba empieza por cerrar la sesión de la prueba anterior (la
   primera vez no existe: el `2>/dev/null` calla el aviso).

   1. **TODO 1 — la sesión.** Cambia `editor=""` por
      `editor=$(tmx new-session -d -s "$name" -n editor -c "$dir" -x 120 -y 30 -P -F '#{pane_id}')`.
      ```bash
      tmux -L lab kill-session -t =api 2>/dev/null; ./starter/make-workspace api /tmp/lab09/api
      tmux -L lab list-panes -s -t =api -F '#{window_name} #{pane_id} #{window_width}x#{window_height} #{pane_current_path}'
      ```
      Algo como (el número tras `%` crece con cada panel que crea el
      servidor):
      ```
      api en /tmp/lab09/api
      editor %5
      run  
      editor %5 120x30 /tmp/lab09/api
      ```
   2. **TODO 2 — la ventana run.** Cambia `run=""` por
      `run=$(tmx new-window -d -t "$name:" -n run -c "$dir" -P -F '#{pane_id}')`.
      ```bash
      tmux -L lab kill-session -t =api 2>/dev/null; ./starter/make-workspace api /tmp/lab09/api
      tmux -L lab list-panes -s -t =api -F '#{window_name} #{pane_id} #{pane_current_path}'
      ```
      Algo como:
      ```
      api en /tmp/lab09/api
      editor %6
      run %7 
      editor %6 /tmp/lab09/api
      run %7 /tmp/lab09/api
      ```
   3. **TODO 3 — partir run.** Cambia `run_right=""` por
      `run_right=$(tmx split-window -h -d -t "$run" -c "$dir" -P -F '#{pane_id}')`.
      El `-t "$run"` es el id que guardó el TODO 2.
      ```bash
      tmux -L lab kill-session -t =api 2>/dev/null; ./starter/make-workspace api /tmp/lab09/api
      tmux -L lab list-panes -s -t =api -F '#{window_name} #{pane_id} #{pane_width}x#{pane_height} #{pane_current_path}'
      ```
      Algo como:
      ```
      api en /tmp/lab09/api
      editor %8
      run %9 %10
      editor %8 120x30 /tmp/lab09/api
      run %9 60x30 /tmp/lab09/api
      run %10 59x30 /tmp/lab09/api
      ```

6. **Errores y códigos de salida:**
   ```bash
   ./starter/make-workspace api /tmp/lab09/api; echo $?
   ./starter/make-workspace api /tmp/lab09/nada; echo $?
   ./starter/make-workspace api; echo $?
   ```
   ```
   duplicate session: api
   1
   make-workspace: no existe el directorio '/tmp/lab09/nada'
   1
   uso: make-workspace NAME DIR
   2
   ```
   La primera falla porque `api` ya existe: `set -euo pipefail` corta el
   script en el primer comando que falla. El lab 05 lo hace idempotente.

7. **Conéctate después.** En la **terminal B** (fuera de tmux), desde la
   raíz del repositorio:
   ```bash
   tmux -L lab attach -t =api
   ```
   Ves la ventana `editor`. `C-b` `n` pasa a `run`, con sus dos paneles. En
   la terminal A:
   ```bash
   tmux -L lab list-clients -F '#{client_name} #{client_session} #{client_width}x#{client_height}'
   tmux -L lab display -p -t =api:editor '#{window_width}x#{window_height}'
   ```
   Algo como (cambian el `pts` y el tamaño, que es el de tu terminal B):
   ```
   /dev/pts/3 api 100x25
   100x24
   ```
   La ventana ya no mide 120x30: manda el cliente (una línea menos por la
   barra de estado). Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `new-session` sin `-d` falla en un script (paso 1)
- [ ] `display -p -t %0` enseña `/tmp/lab09/api 120x30` sin haberte conectado (paso 2)
- [ ] Apuntas a un panel por el id que devolvió `-P -F` y no por su índice (pasos 3 y 5.3)
- [ ] `./starter/make-workspace api /tmp/lab09/api` imprime tres ids y `list-panes -s -t =api` muestra `editor` y `run` (dos paneles), todos en `/tmp/lab09/api` (paso 5)
- [ ] Explicas por qué el tamaño cambia al conectarte (paso 7)

## Reto extra

Añade un tercer argumento opcional, `CMD`, que se ejecute como comando
inicial del panel derecho de `run`
(`split-window ... -P -F '#{pane_id}' "$cmd"`). Pruébalo con `'top'` y
comprueba con `display -p -t "$run_right" '#{pane_current_command}'`. ¿Qué
pasa con ese panel cuando sales de `top` con `q`?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Consultar con formatos](../lab-02-consultar-con-formatos/README.md) → |

[↑ Semana 09](../../README.md)
