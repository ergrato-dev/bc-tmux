# Lab 02 — Targets

⏱ Duración estimada: ~60 min

## Objetivo

Apuntar con `-t` a cualquier sesión, ventana o panel, validar que el target existe y evitar las coincidencias por prefijo que mandan un comando a la sesión equivocada.

## Contexto

- Un **target** tiene la forma `sesión:ventana.panel`. Cada parte puede ser un nombre, un índice o un id (`$1`, `@2`, `%3`), y las que faltan se completan con la actual.
- Si un nombre de sesión no existe tal cual, tmux prueba **por prefijo** y después como **patrón** (`api*`). `=api` desactiva las dos cosas: solo el nombre exacto.
- `display-message -p -t X` no falla si `X` no existe: usa otro objeto (o deja los campos vacíos) y sale con 0. `list-panes -t X` sí falla.

## Instrucciones

0. Abre una terminal **fuera de tmux** (`echo "$TMUX"` no imprime nada) y
   entra en la carpeta del lab:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-02-targets
   ```
   Todo el lab se hace desde esta terminal, sin conectarte: los comandos
   hablan con un servidor aparte (`-L lab`) que arranca sin configuración
   (`-f /dev/null`).

1. **El escenario.** Una sesión `api` con dos ventanas (la segunda partida en
   dos paneles), una `api-2` y una `web`:
   ```bash
   tmux -L lab -f /dev/null new -d -s api -n editor
   tmux -L lab new-window -d -t api: -n logs
   tmux -L lab split-window -d -t api:logs
   tmux -L lab new -d -s api-2
   tmux -L lab new -d -s web
   tmux -L lab list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{session_id} #{window_id} #{pane_id}'
   ```
   ```
   api:0.0 $0 @0 %0
   api:1.0 $0 @1 %1
   api:1.1 $0 @1 %2
   api-2:0.0 $1 @2 %3
   web:0.0 $2 @3 %4
   ```
   Con un servidor recién arrancado los ids salen así; si repites el lab sin
   `kill-server`, siguen contando desde donde iban. `-a` lista los paneles de
   todas las sesiones.

2. **A dónde apunta cada target.** Define una función que imprime la posición
   y el id del panel al que llega un target, y pruébala con varios:
   ```bash
   r() { tmux -L lab display -p -t "$1" '#{session_name}:#{window_index}.#{pane_index} #{pane_id}'; }
   for t in api api:1 api:logs api:logs.1 web: %2 @1 '$0' api:+; do printf '%-11s ' "$t"; r "$t"; done
   ```
   ```
   api         api:0.0 %0
   api:1       api:1.0 %1
   api:logs    api:1.0 %1
   api:logs.1  api:1.1 %2
   web:        web:0.0 %4
   %2          api:1.1 %2
   @1          api:1.0 %1
   $0          api:0.0 %0
   api:+       api:1.0 %1
   ```

   | Target | Significa |
   |---|---|
   | `api` | La sesión `api` (su ventana y panel activos) |
   | `api:1` / `api:logs` | Ventana 1 / ventana llamada `logs` de `api` |
   | `api:logs.1` | Panel 1 de esa ventana |
   | `%2`, `@1`, `$0` | Panel, ventana y sesión por id (`$0` va entre comillas simples para que bash no lo expanda) |
   | `api:+` | Ventana siguiente a la actual (`api:-`, la anterior) |

3. **`display-message` no valida.** Pide cosas que no existen:
   ```bash
   r api:9; echo $?
   r nada; echo $?
   ```
   ```
   api:0.0 %0
   0
   :.
   0
   ```
   Con `api:9` usa la ventana actual de `api`; con `nada`, deja los campos
   vacíos. Las dos veces sale con 0. `list-panes` sí falla:
   ```bash
   tmux -L lab list-panes -t api:9; echo $?
   ```
   ```
   can't find window: 9
   1
   ```
   Un script que lee datos con `display` debe validar antes con `list-panes`.

4. **El prefijo.** Cierra `api` y repite tres comandos que parecen inofensivos:
   ```bash
   tmux -L lab kill-session -t api; echo $?
   tmux -L lab has-session -t api; echo $?
   tmux -L lab has-session -t =api; echo $?
   tmux -L lab kill-session -t api; echo $?
   tmux -L lab ls
   ```
   ```
   0
   0
   can't find session: api
   1
   0
   web: 1 windows (created Mon Nov  2 23:44:44 2026)
   ```
   El primer `kill-session` cierra `api` (existe tal cual). El segundo
   `has-session -t api` sale con 0: ¡encontró `api-2` por prefijo! Con `=api`
   sale con 1. Y el segundo `kill-session -t api` cierra `api-2` sin avisar.
   Sin `=`, un script que cierra o abre "api" puede actuar sobre `api-2`,
   `api-vieja` o cualquier sesión que empiece igual.

5. **Ambigüedad y patrones.** Con dos candidatas, el prefijo ya no elige:
   ```bash
   tmux -L lab new -d -s api-2
   tmux -L lab new -d -s api-3
   tmux -L lab has-session -t api; echo $?
   tmux -L lab has-session -t 'w*'; echo $?
   ```
   ```
   can't find session: api
   1
   0
   ```
   Con una sola candidata la elige sin avisar; con dos falla con el mismo
   mensaje que si no existiera. `'w*'` (entre comillas, para que bash no lo
   expanda) se usa como patrón y encuentra `web`.

6. **Puntos y dos puntos.** El `.` y el `:` separan las partes del target, así
   que no pueden ir en un nombre de sesión:
   ```bash
   tmux -L lab new -d -s web.app
   tmux -L lab ls -F '#{session_name}'
   tmux -L lab has-session -t =web.app; echo $?
   ```
   ```
   api-2
   api-3
   web
   web_app
   can't find pane: app
   1
   ```
   tmux cambió el nombre a `web_app` sin avisar, y el target `web.app` se lee
   como sesión `web`, panel `app`. Un script que crea sesiones con el nombre
   de un directorio debe rechazar o sustituir esos caracteres.

7. **El escenario de `starter/resolve.sh`.** El script recibe un target,
   comprueba que existe y dice exactamente a qué apunta. Reinicia el servidor
   (los ids vuelven a empezar en 0) y pruébalo tal como viene:
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f /dev/null new -d -s api -n editor \; new-window -d -n logs \; split-window -d -t :logs
   ./starter/resolve.sh api:logs.1; echo $?
   ```
   ```
   resolve.sh: sin implementar (api:logs.1)
   0
   ```
   `\;` encadena varios comandos en una sola llamada a tmux. Abre
   `starter/resolve.sh` con tu editor y borra la línea
   `echo "resolve.sh: sin implementar ..."`.

8. **TODO 1: validar.** Si `list-panes` falla, el target no existe:
   ```bash
   if ! tmx list-panes -t "$target" >/dev/null 2>&1; then
     echo "resolve.sh: no existe el target '$target'" >&2
     exit 1
   fi
   ```
   `>/dev/null 2>&1` calla la lista y el error de tmux: el mensaje lo das tú.
   Prueba:
   ```bash
   ./starter/resolve.sh api:9; echo $?
   ./starter/resolve.sh api:logs.1; echo $?
   ```
   ```
   resolve.sh: no existe el target 'api:9'
   1
   0
   ```
   El segundo aún no imprime nada: falta el TODO 2.

9. **TODO 2: decir a qué apunta.** Después de validar, imprime con
   `tmx display-message -p -t "$target" '...'` esta cadena de formato:
   ```
   #{session_name}:#{window_index}.#{pane_index}  sesión #{session_id}  ventana #{window_id}  panel #{pane_id}
   ```
   (dos espacios entre campos; va entre comillas simples para que bash no
   toque los `#{}`). Prueba:
   ```bash
   ./starter/resolve.sh api:logs.1
   ./starter/resolve.sh api
   ./starter/resolve.sh api:9; echo $?
   ```
   ```
   api:1.1  sesión $0  ventana @1  panel %2
   api:0.0  sesión $0  ventana @0  panel %0
   resolve.sh: no existe el target 'api:9'
   1
   ```

10. Limpia:
    ```bash
    tmux -L lab kill-server
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Ejecutaste el bucle del paso 2 y explicas cada fila de su tabla
- [ ] Mostraste que `display -p` sale con 0 con un target que no existe y `list-panes` con 1 (paso 3)
- [ ] Reprodujiste el `kill-session -t api` que cierra `api-2` y lo evitas con `=` (paso 4)
- [ ] Explicas por qué `web.app` no sirve como nombre de sesión (paso 6)
- [ ] `./starter/resolve.sh` da las salidas del paso 9

## Reto extra

Haz que `resolve.sh` acepte `-s` para resolver solo sesiones con
`has-session -t "=$1"` y explique, si falla, si había una sesión que empezaba
igual (pista: `has-session -t "$1"` sin `=`).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Varias sesiones](../lab-01-varias-sesiones/README.md) | [Lab 03 — Moverte entre sesiones](../lab-03-moverte-entre-sesiones/README.md) → |

[↑ Semana 03](../../README.md)
