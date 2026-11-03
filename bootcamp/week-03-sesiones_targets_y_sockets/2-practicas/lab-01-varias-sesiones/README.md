# Lab 01 — Varias sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Crear y organizar varias sesiones, moverte entre ellas con `choose-tree` y cerrar las que sobran sin tocar las demás.

## Contexto

- Lo normal es **una sesión por proyecto o tarea**: `api`, `web`, `notas`. Cada una guarda sus ventanas, su directorio y su historia.
- `choose-tree` (`prefix` `s` y `prefix` `w`) muestra el árbol sesión > ventana > panel y permite saltar, cerrar o marcar elementos.
- `list-sessions` (`tmux ls`) solo pregunta: si no hay servidor falla, pero no arranca ninguno. `new-session` sí lo arranca.

## Instrucciones

0. Abre dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime nada en
   ninguna). En las dos, entra en la carpeta del lab:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-01-varias-sesiones
   ```
   La **terminal A** es la que conectarás a tmux; la **terminal B** se queda
   siempre fuera. Todo va contra un servidor aparte (`-L lab`) que arranca con
   `-f /dev/null`: sin configuración, así que el prefix es `C-b`.

1. En la terminal B, crea dos sesiones en segundo plano (`-d`):
   ```bash
   tmux -L lab -f /dev/null new -d -s web
   tmux -L lab new -d -s notas
   tmux -L lab ls
   ```
   ```
   notas: 1 windows (created Mon Nov  2 23:43:37 2026)
   web: 1 windows (created Mon Nov  2 23:43:37 2026)
   ```
   (Algo como: cambian las fechas.) `-f /dev/null` solo hace falta en el
   comando que arranca el servidor; los demás hablan con el que ya existe.

2. En la terminal A, crea una tercera sesión **conectada** (sin `-d`), con la
   primera ventana llamada `editor`:
   ```bash
   tmux -L lab new -s api -n editor
   ```
   La terminal A pasa a mostrar tmux. Abajo, la barra de estado empieza por
   `[api] 0:editor*`: estás en la sesión `api`, ventana 0. Las tres sesiones
   existen, pero solo `api` tiene un cliente (la última que creaste).

3. En la terminal A, abre el árbol de sesiones con `C-b` `s`:
   ```
   (0) + web: 1 windows
   (1) + notas: 1 windows
   (2) + api: 1 windows (attached)
   ```
   El cursor empieza en la sesión actual (`api`). Pulsa `→`: se despliega y
   aparece `(3) └─> 0: editor*`. Si la terminal es alta, debajo verás una
   vista previa de lo seleccionado. Pulsa `q` para salir sin elegir nada.

   Ahora `C-b` `w`: el mismo árbol, ya desplegado hasta las ventanas, con el
   cursor en `(5) └─> 0: editor*`. Pulsa `↑` cuatro veces hasta
   `(1) └─> 0: bash*` (la ventana de `web`) y `Enter`: la barra cambia a
   `[web] 0:bash*`. Vuelve con `C-b` `s`, `↓` `↓` hasta `api` y `Enter`.

   | Tecla dentro del árbol | Qué hace |
   |---|---|
   | `↑` `↓` | Mueve el cursor |
   | `→` / `←` | Despliega / pliega el elemento |
   | `Enter` | Salta al elemento |
   | `x` | Cierra el elemento (pide `y` para confirmar) |
   | `t` / `X` | Marca un elemento / cierra todos los marcados |
   | `O` | Cambia el orden: `index`, `name`, `time` |
   | `v` | Muestra u oculta la vista previa |
   | `q` | Sale sin elegir |

4. **Cerrar desde el árbol.** En la terminal B crea una sesión de usar y tirar:
   ```bash
   tmux -L lab new -d -s tmp-x
   ```
   En la terminal A pulsa `C-b` `s`; `tmp-x` aparece como `(3)`. Ponte encima
   con `↓` (el cursor sale de `api`) y pulsa `x`. Abajo aparece la pregunta:
   ```
   Kill session tmp-x?
   ```
   Responde `y`. `tmp-x` desaparece y el árbol se queda abierto; sal con `q`.
   Cuidado: si haces `x` sobre `api`, cierras la sesión en la que estás y la
   terminal A se desconecta.

5. **Renombrar.** En la terminal A pulsa `C-b` `$`. Abajo aparece el prompt
   **ya relleno** con el nombre actual:
   ```
   (rename-session) api
   ```
   Borra el texto con `C-u`, escribe `api-v2` y pulsa `Enter`: la barra dice
   `[api-v2]`. Desde la terminal B se hace con un comando; deja el nombre como
   estaba:
   ```bash
   tmux -L lab rename-session -t =api-v2 api
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   api
   notas
   web
   ```

6. **Más detalle.** En la terminal B:
   ```bash
   tmux -L lab ls -F '#{session_name}: #{session_windows} ventanas, #{session_attached} clientes, actividad #{t:session_activity}'
   ```
   ```
   api: 1 ventanas, 1 clientes, actividad Mon Nov  2 23:43:37 2026
   notas: 1 ventanas, 0 clientes, actividad Mon Nov  2 23:43:37 2026
   web: 1 ventanas, 0 clientes, actividad Mon Nov  2 23:43:37 2026
   ```
   (Algo como: cambian las fechas.) `session_attached` cuenta los clientes
   conectados; `t:` convierte la hora (segundos desde 1970) en fecha legible.

7. **Cerrar una sesión desde fuera.** En la terminal B:
   ```bash
   tmux -L lab kill-session -t =notas; echo $?
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   0
   api
   web
   ```
   Las demás siguen intactas. En la terminal A, desconéctate con `C-b` `d`:
   ```
   [detached (from session api)]
   ```

8. **Preguntar no arranca nada.** En la terminal B. `kill-server` deja el
   archivo del socket en `/tmp/tmux-UID/`; bórralo para ver quién lo crea:
   ```bash
   tmux -L lab kill-server
   rm -f /tmp/tmux-$(id -u)/lab
   tmux -L lab ls; echo $?
   tmux -L lab has-session; echo $?
   ls -F /tmp/tmux-$(id -u)/
   ```
   ```
   error connecting to /tmp/tmux-1000/lab (No such file or directory)
   1
   error connecting to /tmp/tmux-1000/lab (No such file or directory)
   1
   ```
   (Algo como: `1000` es tu uid, `id -u`.) `ls -F` no imprime nada: ni `ls`
   ni `has-session` crearon el socket. Ahora sí:
   ```bash
   tmux -L lab -f /dev/null new -d -s api; echo $?
   ls -F /tmp/tmux-$(id -u)/
   ```
   ```
   0
   lab=
   ```
   El `=` final de `ls -F` marca un socket. Un script que solo quiere listar
   no debe dejarte un servidor vacío: por eso pregunta con `list-sessions` o
   `has-session`, nunca con `new-session`.

9. **Prepara el escenario de `starter/cleanup.sh`.** El script cerrará las
   sesiones cuyo nombre empieza por un prefijo y que **no tienen clientes**.
   En la terminal B:
   ```bash
   tmux -L lab kill-server
   for s in tmp-1 tmp-2 tmpfiles api; do tmux -L lab -f /dev/null new -d -s "$s"; done
   ./starter/cleanup.sh tmp-; echo $?
   ```
   ```
   cleanup.sh: sin implementar (tmp-)
   0
   ```
   Abre `starter/cleanup.sh` con tu editor. Borra la línea
   `echo "cleanup.sh: sin implementar ..."` antes de empezar.

10. **TODO 1: leer la lista.** Guarda en una variable el nombre y los
    clientes de cada sesión, y de momento imprímela para comprobarla:
    ```bash
    sessions=$(tmx list-sessions -F '#{session_name} #{session_attached}')
    echo "$sessions"    # temporal: lo quitas en el TODO 2
    ```
    Se lee la lista entera antes de cerrar nada: así no recorres una lista
    que cambia mientras cierras. Prueba:
    ```bash
    ./starter/cleanup.sh tmp-
    ```
    ```
    api 0
    tmp-1 0
    tmp-2 0
    tmpfiles 0
    ```

11. **TODO 2: cerrar las que tocan.** Quita el `echo "$sessions"` y recorre la
    variable línea a línea:
    ```bash
    while read -r name clients; do
      if [[ "$name" == "$prefix"* ]] && (( clients == 0 )); then
        # ... kill-session y echo
      fi
    done <<<"$sessions"
    ```
    Dentro del `if`: `tmx kill-session -t "=$name"` y
    `echo "cerrada: $name"`. El `=` pide el nombre exacto (lo verás a fondo
    en el lab 02); las comillas en `"$prefix"` hacen que un `*` del prefijo
    sea literal. Prueba (el TODO 1 solo imprimía: las cuatro sesiones siguen
    vivas):
    ```bash
    ./starter/cleanup.sh tmp-
    tmux -L lab ls -F '#{session_name}'
    ```
    ```
    cerrada: tmp-1
    cerrada: tmp-2
    api
    tmpfiles
    ```
    `tmpfiles` no empieza por `tmp-`: se queda.

12. **TODO 3: decir qué queda.** Al final del script, imprime los nombres en
    una línea. Pista: `paste -sd' ' -` junta líneas con espacios:
    ```bash
    echo "quedan: $(tmx list-sessions -F '#{session_name}' 2>/dev/null | paste -sd' ' -)"
    ```
    El `2>/dev/null` es por si no queda ninguna sesión (el servidor se cierra
    al quedarse vacío). Prueba desde cero:
    ```bash
    tmux -L lab kill-server
    for s in tmp-1 tmp-2 tmpfiles api; do tmux -L lab -f /dev/null new -d -s "$s"; done
    ./starter/cleanup.sh tmp-
    ```
    ```
    cerrada: tmp-1
    cerrada: tmp-2
    quedan: api tmpfiles
    ```

13. **Una sesión con cliente no se toca.** En la terminal B crea `tmp-3`; en
    la terminal A conéctate a ella:
    ```bash
    tmux -L lab new -d -s tmp-3          # terminal B
    tmux -L lab attach -t =tmp-3         # terminal A
    ```
    En la terminal B:
    ```bash
    ./starter/cleanup.sh tmp-
    ```
    ```
    quedan: api tmp-3 tmpfiles
    ```
    No imprime ninguna línea `cerrada:`. En la terminal A, sal con `C-b` `d`:
    ```
    [detached (from session tmp-3)]
    ```

14. Limpia, en la terminal B:
    ```bash
    tmux -L lab kill-server
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Saltaste entre sesiones con `C-b` `s` / `C-b` `w` y cerraste `tmp-x` desde el árbol con `x` + `y` (pasos 3 y 4)
- [ ] Renombraste la sesión con `C-b` `$` borrando el texto relleno con `C-u` (paso 5)
- [ ] Mostraste que `ls` y `has-session` no crean el socket y `new-session` sí (paso 8)
- [ ] `./starter/cleanup.sh tmp-` imprime las tres líneas del paso 12
- [ ] Con un cliente en `tmp-3`, `cleanup.sh` no la cierra (paso 13)

## Reto extra

Con varias sesiones `tmp-*` creadas, abre el árbol filtrado solo con ellas:
`C-b` `:` y escribe `choose-tree -s -f '#{m:tmp-*,#{session_name}}'` +
`Enter`. Márcalas todas con `C-t`, ciérralas con `X` y confirma con `y`.
