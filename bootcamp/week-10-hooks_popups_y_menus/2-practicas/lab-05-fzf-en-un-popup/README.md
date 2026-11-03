# Lab 05 — fzf en un popup

⏱ Duración estimada: ~60 min

## Objetivo

Construir un selector de sesiones con fzf dentro de un popup que cambia el cliente a la sesión elegida, funciona sin fzf y no ejecuta nada aunque el nombre de una sesión sea hostil.

## Contexto

- fzf lee líneas por la entrada, deja elegir una tecleando parte del texto y la imprime; con `Escape` o `C-c` sale con 130 sin imprimir nada. Dentro de `display-popup -E` se ve como una ventana flotante que desaparece al elegir.
- La elección vuelve a tmux como **argumento** de `switch-client`, nunca metida en un comando ni en `send-keys`: así un `;` o un `$(...)` en el nombre no son más que caracteres.
- `-t "=nombre"` no encuentra una sesión cuyo nombre empieza por `$` (tmux lo lee como un id). Por eso el selector trabaja con el id de sesión (`$0`, `$1`…) y muestra el nombre.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux**, las dos desde la raíz del
   repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-05-fzf-en-un-popup
   ```
   Este lab necesita fzf (ya está en el laboratorio Docker; si no:
   `sudo apt install fzf` o `brew install fzf`):
   ```bash
   fzf --version
   ```
   Algo como:
   ```
   0.44.1 (debian)
   ```
   En la **terminal A**, como dice
   [Antes de cada lab](../README.md#antes-de-cada-lab) (pasos 3 y 5):
   ```bash
   mkdir -p /tmp/lab10; export TMUX_SOCKET=lab
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   En la **terminal B**: `tmux -L lab attach -t lab`. El prefix es `C-b`: el
   starter no lo cambia.

1. **Sesiones de prueba, dos de ellas hostiles** (terminal A):
   ```bash
   tmux -L lab new -d -s api; tmux -L lab new -d -s web; tmux -L lab new -d -s 'x;touch /tmp/lab10/pwned'; tmux -L lab new -d -s '$(touch /tmp/lab10/pwned2)'
   tmux -L lab has-session -t '=$(touch /tmp/lab10/pwned2)'; echo $?
   ```
   ```
   can't find session: $(touch /tmp/lab10/pwned2)
   1
   ```
   La sesión existe, pero `=` con un nombre que empieza por `$` no la
   encuentra.

2. **TODO 1 — la lista con ids.** Primero, tal cual:
   ```bash
   ./starter/pick-session.sh -x; echo $?
   ./starter/pick-session.sh -l; echo $?
   ```
   ```
   uso: pick-session.sh [-l]
   2
   sin implementar
   0
   ```
   Cambia `sessions="sin implementar"` por
   `sessions=$(tmx list-sessions -F '#{session_id} #{session_name}')`:
   ```bash
   ./starter/pick-session.sh -l; echo $?
   ```
   ```
   $4 $(touch /tmp/lab10/pwned2)
   $1 api
   $0 lab
   $2 web
   $3 x;touch /tmp/lab10/pwned
   0
   ```

3. **TODO 2 — fzf.** Cambia la línea `sel="$sessions"` (la primera, dentro
   del `if`) por la de `fzf` del comentario. Pruébalo en un popup **sin
   `-E`**, para ver lo que imprime al final (terminal A; `$PWD` lo expande
   tu shell, así que el popup recibe la ruta absoluta):
   ```bash
   tmux -L lab display-popup -w 60 -h 12 "$PWD/starter/pick-session.sh"; echo $?
   ```
   En B aparece fzf con `sesión> ` arriba y `5/5` (cinco sesiones). Escribe
   `web`: la lista se reduce a `web`. Pulsa `Enter`. El popup muestra
   ```
   pick-session: elegiste '$2 web' (sin implementar)
   ```
   y se queda abierto: pulsa `Escape`. A imprime `0`. Ahora con `-E`, y
   cancela con `Escape` dentro de fzf:
   ```bash
   tmux -L lab display-popup -E "$PWD/starter/pick-session.sh"; echo $?
   ```
   ```
   0
   ```
   fzf salió con 130 y `|| exit 0` lo convirtió en una salida normal.

4. **TODO 4 — volver a tmux.** Cambia la línea
   `echo "pick-session: elegiste ..."` por `tmx switch-client -t "${sel%% *}"`
   (`${sel%% *}` es lo que hay antes del primer espacio: el id). En A:
   ```bash
   tmux -L lab display-popup -E "$PWD/starter/pick-session.sh"; echo $?
   ```
   En B escribe `web` y `Enter`: el popup se cierra y la barra de B muestra
   `[web]`. A imprime `0`:
   ```bash
   tmux -L lab list-clients -F '#{client_session}'
   ```
   ```
   web
   ```
   Repite el `display-popup`, escribe `pwned2` y `Enter`:
   ```bash
   tmux -L lab list-clients -F '#{client_session}'; ls -A /tmp/lab10
   ```
   ```
   $(touch /tmp/lab10/pwned2)
   ```
   B está en la sesión hostil y `/tmp/lab10` sigue vacío: el nombre no se
   ejecutó.

5. **TODO 3 — sin fzf.** `FZF_BIN=no-fzf` simula que fzf no está.
   Primero, tal cual (la entrada `3` no llega a leerse):
   ```bash
   printf '3\n' | FZF_BIN=no-fzf ./starter/pick-session.sh; echo $?
   ```
   ```
   0
   ```
   Cambia la línea `sel=""` por las tres de `select` del comentario.
   `select` numera las opciones, lee un número y repite la pregunta si no
   vale (aquí, `9`):
   ```bash
   printf '9\n3\n' | FZF_BIN=no-fzf ./starter/pick-session.sh; echo $?
   tmux -L lab list-clients -F '#{client_session}'
   ```
   Algo como (las columnas dependen del ancho de tu terminal):
   ```
   1) $4 $(touch /tmp/lab10/pwned2)  4) $2 web
   2) $1 api			  5) $3 x;touch /tmp/lab10/pwned
   3) $0 lab
   número (C-d cancela): número (C-d cancela): 0
   lab
   ```
   Desde A, sin `-c`, `switch-client` movió al único cliente conectado: B.
   En un popup (`-e` pone la variable solo ahí):
   ```bash
   tmux -L lab display-popup -E -e FZF_BIN=no-fzf "$PWD/starter/pick-session.sh"; echo $?
   ```
   En B escribe `2` y `Enter`: B pasa a `api` y A imprime `0`.

6. **TODO 5 — `prefix` `O`.** En `starter/tmux.conf` quita el `#   ` de la
   línea `bind O display-popup ...` y recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix O
   ```
   ```
   bind-key -T prefix O display-popup -E -T " sesiones " -h "50%" -w "50%" "exec \"$(tmux show -gv @lab-dir)/pick-session.sh\""
   ```
   En B pulsa `C-b` `O`: el popup ` sesiones ` con fzf. Escribe `lab` y
   `Enter`: vuelves a `lab`. Pulsa `C-b` `O` y `Escape`: se cierra sin
   cambiar nada.
   ```bash
   tmux -L lab list-clients -F '#{client_session}'
   ```
   ```
   lab
   ```

7. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab10
   ```
   B imprime `[server exited]`.

## Criterios de éxito

- [ ] `./starter/pick-session.sh -l` imprime las cinco sesiones con su id delante (paso 2)
- [ ] Explicas por qué el script cambia de sesión por id y no con `-t "=nombre"` (pasos 1 y 4)
- [ ] Elegir `$(touch /tmp/lab10/pwned2)` con fzf mueve a B a esa sesión y `ls -A /tmp/lab10` no imprime nada (paso 4)
- [ ] Con `FZF_BIN=no-fzf`, `printf '9\n3\n' | ...` repite la pregunta y acaba en `lab` (paso 5)
- [ ] `C-b` `O` abre el selector; `Escape` lo cierra sin cambiar de sesión (paso 6)

## Reto extra

Marca la sesión actual en la lista: `#{?session_attached,*, }` en el `-F`
pone un `*` delante de las que tienen un cliente conectado. Ajusta
`--with-nth` y `${sel%% *}` para que la marca no rompa el id. ¿Por qué no
basta con `grep -v` sobre el nombre de la sesión actual?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — run-shell y pipe-pane](../lab-04-run-shell-y-pipe-pane/README.md) | [Lab 06 — Hooks rotos](../lab-06-hooks-rotos/README.md) → |

[↑ Semana 10](../../README.md)
