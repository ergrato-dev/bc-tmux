# Lab 06 — Script roto

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los cinco fallos de `team-up`, un script de un compañero que funciona en la demo y falla en cuanto el servidor no está vacío, provocando cada fallo antes de corregirlo.

## Contexto

- `starter/team-up` está **roto a propósito**. Sus comentarios dicen lo que el autor quería; el código hace otra cosa.
- Un fallo de un script de tmux casi nunca da error: sale con 0 y actúa sobre otra sesión, otra ventana u otro servidor. Se depura mirando el estado con `list-*` antes y después.
- Uno de los fallos cierra un servidor que no es el del lab. Para que no sea el tuyo de verdad, este lab mueve todos los sockets a un directorio temporal con `TMUX_TMPDIR`.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio.
   Esta vez, **antes** de arrancar el servidor del lab, `TMUX_TMPDIR`:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-06-script-roto
   export TMUX_TMPDIR=/tmp/lab09/tmp; mkdir -p "$TMUX_TMPDIR" /tmp/lab09/api
   tmux -L lab -f /dev/null start-server \; set -s exit-empty off
   export TMUX_SOCKET=lab
   ```
   ```
   (sin salida)
   ```
   Mientras exista `TMUX_TMPDIR` en esta terminal, `tmux` sin `-L` usa el
   servidor `default` de `/tmp/lab09/tmp`, no el tuyo. Necesitas
   `shellcheck` (`sudo apt install shellcheck` o `brew install shellcheck`;
   en el laboratorio Docker ya está).

1. **Un servidor "personal".** Hace de tu tmux de siempre:
   ```bash
   tmux -f /dev/null new-session -d -s personal; tmux list-sessions -F '#{socket_path} #{session_name}'
   tmux -L lab display -p '#{socket_path}'
   ```
   ```
   /tmp/lab09/tmp/tmux-1000/default personal
   /tmp/lab09/tmp/tmux-1000/lab
   ```
   (`1000` es tu uid.) Dos servidores, los dos dentro de `/tmp/lab09`.

2. **Lee el script y pásale `shellcheck`:**
   ```bash
   shellcheck starter/team-up; echo $?
   ```
   ```

   In starter/team-up line 35:
     tmx send-keys -t "$pane" ${TEST_CMD:-echo sin pruebas} Enter
                              ^---------------------------^ SC2086 (info): Double quote to prevent globbing and word splitting.

   Did you mean: 
     tmx send-keys -t "$pane" "${TEST_CMD:-echo sin pruebas}" Enter

   For more information:
     https://www.shellcheck.net/wiki/SC2086 -- Double quote to prevent globbing ...
   1
   ```
   Uno de cinco. Los otros cuatro no son errores de bash sino de tmux:
   `shellcheck` no los ve.

3. **Fallo 1: el prefijo.** Con `api-2` en marcha, `up api`:
   ```bash
   tmux -L lab new-session -d -s api-2 -c /tmp/lab09
   ./starter/team-up up api /tmp/lab09/api; echo $?
   tmux -L lab list-windows -a -F '#{session_name}:#{window_name}'
   ```
   ```
   team-up: la sesión 'api' ya existe
   0
   api-2:bash
   api-2:test
   ```
   No hay `api`, y la ventana `test` acabó en `api-2`. **Arreglo:**
   `-t "=$name"` en `has-session` y en `kill-session` (en `down`: sin `=`,
   `down api` cerraría `api-2`). Quita la ventana que sobra y prueba:
   ```bash
   tmux -L lab kill-window -t =api-2:test
   ./starter/team-up up api /tmp/lab09/api; echo $?
   ./starter/team-up up api /tmp/lab09/api; echo $?
   tmux -L lab list-windows -a -F '#{session_name}:#{window_name}'
   ```
   ```
   team-up: sesión 'api' creada
   0
   team-up: la sesión 'api' ya existe
   0
   api:code
   api:test
   api:test
   api-2:bash
   ```

4. **Fallo 2: ventanas duplicadas.** Cada `up` añade otra `test` (lo
   acabas de ver). **Arreglo:** crea `test` solo si no está, y con la
   sesión exacta:
   ```bash
   if ! tmx list-windows -t "=$name" -F '#{window_name}' | grep -qxF test; then
     tmx new-window -d -t "=$name:" -n test -c "$dir"
   fi
   ```
   ```bash
   tmux -L lab kill-session -t =api
   ./starter/team-up up api /tmp/lab09/api; ./starter/team-up up api /tmp/lab09/api
   tmux -L lab list-windows -t =api -F '#{window_name}'
   ```
   ```
   team-up: sesión 'api' creada
   team-up: la sesión 'api' ya existe
   code
   test
   ```

5. **Fallo 3: `$TEST_CMD` sin comillas** (el de `shellcheck`):
   ```bash
   TEST_CMD='echo todo verde' ./starter/team-up test api; echo $?
   sleep 0.5; tmux -L lab capture-pane -p -t api:test | grep -v '^$' | tail -n 2
   ```
   Algo como (tu prompt será otro):
   ```
   0
   -bash: echotodoverde: command not found
   alumno@bc-tmux-lab:/tmp/lab09/api$
   ```
   **Arreglo:** texto literal y entero, `Enter` aparte:
   `tmx send-keys -t "$pane" -l -- "${TEST_CMD:-echo sin pruebas}"` y
   `tmx send-keys -t "$pane" Enter`. Repite los dos comandos de arriba:
   ```
   0
   todo verde
   alumno@bc-tmux-lab:/tmp/lab09/api$
   ```

6. **Fallo 4: validar con `display -p`.** Cierra `test` y lanza las
   pruebas; mira dónde acaban:
   ```bash
   tmux -L lab kill-window -t =api:test
   TEST_CMD='echo todo verde' ./starter/team-up test api; echo $?
   sleep 0.5; tmux -L lab capture-pane -p -t api:code | grep -v '^$' | tail -n 2
   ```
   ```
   0
   todo verde
   alumno@bc-tmux-lab:/tmp/lab09/api$
   ```
   Sin ventana `test`, `display -p` devolvió el panel de `code` con 0 y las
   pruebas se escribieron allí. **Arreglo:** valida con `list-panes`, que sí
   falla:
   `tmx list-panes -t "=$name:test" -F '#{pane_id}' >/dev/null 2>&1 || { echo "team-up: no existe la ventana test en '$name'" >&2; exit 1; }`,
   y manda las teclas a `"=$name:test"` (borra la variable `pane`).
   ```bash
   TEST_CMD='echo todo verde' ./starter/team-up test api; echo $?
   ```
   ```
   team-up: no existe la ventana test en 'api'
   1
   ```

7. **Fallo 5: `kill-server` sin `-L`.** Con `api-2` viva no pasa nada;
   cuando `api` es la última sesión del lab, `down` cierra también el
   servidor "personal":
   ```bash
   ./starter/team-up down api; echo $?; tmux list-sessions -F '#{session_name}'
   tmux -L lab kill-session -t =api-2; tmux -L lab new-session -d -s api -c /tmp/lab09/api
   ./starter/team-up down api; echo $?
   tmux list-sessions; echo $?
   ```
   ```
   0
   personal
   0
   no server running on /tmp/lab09/tmp/tmux-1000/default
   1
   ```
   `tmux kill-server` no pasa por `tmx`: ignora `TMUX_SOCKET` y va al
   servidor por defecto. Sin `TMUX_TMPDIR`, habría sido el tuyo, con todo
   lo que tuvieras abierto. **Arreglo:** borra el `if` entero. Además de
   apuntar mal, sobraba: un servidor sin sesiones ya sale solo
   (`exit-empty`), salvo que alguien lo quiera vivo, como este del lab.

8. **Comprueba el script entero** (terminal A):
   ```bash
   tmux -f /dev/null new-session -d -s personal
   tmux -L lab new-session -d -s api-2 -c /tmp/lab09; ./starter/team-up up api /tmp/lab09/api; ./starter/team-up up api /tmp/lab09/api
   tmux -L lab list-windows -a -F '#{session_name}:#{window_name}'
   TEST_CMD='echo todo verde' ./starter/team-up test api; echo $?
   tmux -L lab kill-session -t =api-2; ./starter/team-up down api; echo $?
   tmux list-sessions -F '#{session_name}'
   shellcheck starter/team-up; echo $?
   ```
   ```
   team-up: sesión 'api' creada
   team-up: la sesión 'api' ya existe
   api:code
   api:test
   api-2:bash
   0
   0
   personal
   0
   ```
   Corrige también los comentarios: que cada uno diga qué se rompe sin esa
   línea.

9. **Limpia** (terminal A):
   ```bash
   tmux kill-server; tmux -L lab kill-server
   rm -rf /tmp/lab09; unset TMUX_TMPDIR TMUX_SOCKET
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Provocas cada fallo antes de arreglarlo y nombras el comando que lo demuestra (pasos 3 a 7)
- [ ] Explicas por qué `shellcheck` solo encuentra uno de los cinco (paso 2)
- [ ] Explicas por qué `display -p` sale con 0 sin ventana `test` (paso 6)
- [ ] Explicas qué servidor cerró `tmux kill-server` y por qué `TMUX_TMPDIR` evitó que fuera el tuyo (paso 7)
- [ ] Con tu `team-up` arreglado, el paso 8 da esa salida y `shellcheck` sale con 0

## Reto extra

`team-up up` con un nombre como `a:b` o `a.b` se comporta raro (tmux lo
guarda como `a_b`). Y si `$TMUX_SOCKET` apunta a un servidor que no existe,
`up` lo arranca leyendo tu config. Añade dos validaciones: nombre sin `.` ni
`:` (salida 2) y, para `test` y `down`, un mensaje claro si no hay servidor
(`tmx list-sessions >/dev/null 2>&1`).
