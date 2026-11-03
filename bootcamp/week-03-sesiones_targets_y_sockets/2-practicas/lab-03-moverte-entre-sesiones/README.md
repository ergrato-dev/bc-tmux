# Lab 03 — Moverte entre sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Saltar entre sesiones con teclas, con filtros y con `switch-client`, y saber qué comando usar según estés dentro o fuera de tmux.

## Contexto

- Un **cliente** está conectado a una sesión, pero no para siempre: `switch-client` lo cambia a otra sin desconectarlo. Es lo que hacen `prefix` `(`, `)`, `L` y elegir en `choose-tree`.
- `attach-session` conecta un cliente **nuevo**. Dentro de tmux eso anidaría un cliente dentro de un panel, y tmux lo rechaza.
- `detach-on-destroy` decide qué pasa con tu cliente cuando su sesión se cierra: salir (por defecto) o pasar a otra.

## Instrucciones

0. Abre dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime nada en
   ninguna). En las dos, entra en la carpeta del lab:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-03-moverte-entre-sesiones
   ```
   La **terminal A** es la que conectarás; la **terminal B** se queda fuera.
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`, sin
   configuración: el prefix es `C-b`.

1. En la terminal B, crea tres sesiones; en la terminal A, conéctate a `web`:
   ```bash
   tmux -L lab -f /dev/null new -d -s web \; new -d -s notas \; new -d -s infra   # terminal B
   tmux -L lab attach -t =web                                                      # terminal A
   ```
   La barra de estado de la terminal A empieza por `[web] 0:bash*` (o
   `0:zsh*`, según tu shell).

2. **Saltar con teclas.** En la terminal A, pulsa cada combinación y mira el
   nombre entre corchetes al principio de la barra:

   | Pulsas | La barra dice | Comando que ejecuta |
   |---|---|---|
   | `C-b` `)` | `[infra]` | `switch-client -n` (siguiente) |
   | `C-b` `)` | `[notas]` | |
   | `C-b` `)` | `[web]` | |
   | `C-b` `(` | `[notas]` | `switch-client -p` (anterior) |
   | `C-b` `L` | `[web]` | `switch-client -l` (la última en la que estuviste) |
   | `C-b` `L` | `[notas]` | |

   `(` y `)` recorren las sesiones por orden alfabético (`infra`, `notas`,
   `web`) y dan la vuelta al llegar al final. `L` alterna entre las dos
   últimas: es el que más usarás. Lo compruebas con
   `tmux -L lab list-keys -T prefix L`, que imprime
   `bind-key -T prefix L switch-client -l`.

3. **Elegir cliente.** En la terminal A, pulsa `C-b` `D`:
   ```
   (0) /dev/pts/3: 23:47: session notas
   ```
   (Algo como: cambian la terminal y la hora.) Es la lista de clientes
   conectados; `Enter` desconectaría el elegido (ahora, tú mismo). Pulsa `q`
   para salir sin hacer nada.

4. **Filtrar el árbol.** En la terminal A, pulsa `C-b` `:`. Abajo aparece un
   `:` para escribir un comando de tmux. Escribe y pulsa `Enter`:
   ```
   choose-tree -Zs -f '#{m:*n*,#{session_name}}'
   ```
   ```
   (0) + notas: 1 windows (attached)
   (1) + infra: 1 windows
   ```
   Solo aparecen las sesiones con una `n`, y el borde de la vista previa dice
   `(sort: index) (filter: active)`. Pulsa `O` tres veces y mira el borde:
   `sort: name` (pasa `infra` arriba), `sort: time` y otra vez `sort: index`.
   Pulsa `f`: aparece `(filter) #{m:*n*,#{session_name}}`, el filtro actual ya
   relleno. Bórralo con `C-u` y pulsa `Enter`: vuelven las tres sesiones.
   Sal con `q`.

5. **Cerrar la sesión en la que estás.** En la terminal A, pulsa `C-b` `s`,
   baja con `↓` hasta `infra` y pulsa `Enter` (la barra dice `[infra]`).
   Ahora `C-b` `:`, escribe `kill-session` y `Enter`. La terminal A sale de
   tmux y muestra:
   ```
   [exited]
   ```
   Quedaban otras sesiones, pero tu cliente no pasó a ninguna. En la terminal B:
   ```bash
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   notas
   web
   ```

6. **`detach-on-destroy off`.** En la terminal A, vuelve a conectarte:
   ```bash
   tmux -L lab attach -t =web
   ```
   Pulsa `C-b` `:`, escribe `set -g detach-on-destroy off` y `Enter`.
   Compruébalo en la terminal B:
   ```bash
   tmux -L lab show -gv detach-on-destroy
   ```
   ```
   off
   ```
   En la terminal A, cierra otra vez la sesión actual: `C-b` `:`,
   `kill-session`, `Enter`. Esta vez no sales: la barra pasa a `[notas]`, la
   sesión usada más recientemente de las que quedan. La opción dura hasta que
   cierres el servidor; en la semana 05 la pondrás en tu configuración.

7. **Dentro de tmux, `switch-client`.** En la terminal B, crea otra vez `web`:
   ```bash
   tmux -L lab new -d -s web
   ```
   En la terminal A (estás en `notas`), escribe en el panel:
   ```bash
   tmux -L lab attach -t =web
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   ```
   ```bash
   tmux -L lab switch-client -t =web
   ```
   El segundo no imprime nada y la barra pasa a `[web]`. `switch-client` sin
   `-c` mueve el cliente que está mirando el panel desde el que lo ejecutas.

8. **El escenario de `starter/jump.sh`.** El script recibe un nombre de
   sesión y te lleva a ella con el comando correcto según estés dentro
   (`$TMUX` no vacío) o fuera de tmux. Pruébalo en la terminal B tal como
   viene:
   ```bash
   ./starter/jump.sh notas; echo $?
   ```
   ```
   jump.sh: sin implementar (notas)
   0
   ```
   Abre `starter/jump.sh` con tu editor y borra la línea
   `echo "jump.sh: sin implementar ..."`.

9. **TODO 1: la sesión existe.** Pista:
   ```bash
   if ! tmx has-session -t "=$name" 2>/dev/null; then
     echo "no existe la sesión '$name'" >&2
     exit 1
   fi
   ```
   Prueba en la terminal B:
   ```bash
   ./starter/jump.sh nada; echo $?
   ./starter/jump.sh not; echo $?
   ```
   ```
   no existe la sesión 'nada'
   1
   no existe la sesión 'not'
   1
   ```
   Gracias al `=`, `not` no encuentra `notas` por prefijo.

10. **TODO 2: el comando según dónde estés.**
    `if [[ -n "${TMUX:-}" ]]; then` → `tmx switch-client -t "=$name"`;
    `else` → `tmx attach-session -t "=$name"`. `${TMUX:-}` evita que
    `set -u` aborte el script cuando la variable no existe. Prueba primero
    **dentro**: en la terminal A (estás en `web`), en el panel:
    ```bash
    ./starter/jump.sh notas
    ```
    No imprime nada y la barra pasa a `[notas]`. Desconéctate con `C-b` `d`:
    ```
    [detached (from session notas)]
    ```
    Ahora **fuera**, en la misma terminal A:
    ```bash
    ./starter/jump.sh web
    ```
    Te conecta a `web` (`[web]` en la barra). Sal con `C-b` `d`:
    ```
    [detached (from session web)]
    ```

11. Limpia, en la terminal B:
    ```bash
    tmux -L lab kill-server
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Reprodujiste la tabla del paso 2 y alternas entre dos sesiones con `C-b` `L`
- [ ] Filtraste el árbol con `-f` y cambiaste el orden con `O` (paso 4)
- [ ] Explicas la diferencia entre `detach-on-destroy on` y `off` con lo que pasó en los pasos 5 y 6
- [ ] Viste el error de anidado y lo evitaste con `switch-client` (paso 7)
- [ ] `jump.sh` sale con 1 si la sesión no existe (paso 9) y funciona dentro y fuera de tmux (paso 10)

## Reto extra

Con dos clientes conectados (dos terminales), usa `switch-client -c` para
mover el **otro** cliente a una sesión. Saca su nombre de
`tmux -L lab list-clients -F '#{client_name} #{session_name}'`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — Targets](../lab-02-targets/README.md) | [Lab 04 — Grupos de sesiones](../lab-04-grupos-de-sesiones/README.md) → |

[↑ Semana 03](../../README.md)
