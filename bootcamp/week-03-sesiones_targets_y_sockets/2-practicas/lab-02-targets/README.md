# Lab 02 — Targets

⏱ Duración estimada: ~60 min

## Objetivo

Apuntar con `-t` a cualquier sesión, ventana o panel, validar que el target existe y evitar las coincidencias por prefijo que mandan un comando a la sesión equivocada.

## Contexto

- Un **target** tiene la forma `sesión:ventana.panel`. Cada parte puede ser un nombre, un índice o un id (`$1`, `@2`, `%3`), y las que faltan se completan con la actual.
- Si un nombre de sesión no existe tal cual, tmux prueba **por prefijo** y después como **patrón** (`api*`). `=api` desactiva las dos cosas: solo el nombre exacto.
- `display-message -p -t X` no falla si `X` no existe: usa otro objeto y sale con 0. `list-panes -t X` sí falla.

## Instrucciones

1. Prepara el escenario:
   ```bash
   tmux -L lab new -d -s api -n editor
   tmux -L lab new-window -d -t api: -n logs
   tmux -L lab split-window -d -t api:logs
   tmux -L lab new -d -s api-2
   tmux -L lab new -d -s web
   ```

2. Comprueba a dónde apunta cada target. Para no repetir el formato:
   ```bash
   r() { tmux -L lab display -p -t "$1" '#{session_name}:#{window_index}.#{pane_index} #{pane_id}'; }
   r api; r api:1; r api:logs; r api:logs.1; r web:; r '%2'
   ```

   | Target | Significa |
   |---|---|
   | `api` | La sesión `api` (su ventana y panel activos) |
   | `api:1` / `api:logs` | Ventana 1 / ventana llamada `logs` de `api` |
   | `api:logs.1` | Panel 1 de esa ventana |
   | `%2`, `@1`, `$0` | Panel, ventana y sesión por id |
   | `api:+` / `api:-` | Ventana siguiente / anterior |
   | `api:!` | Última ventana visitada (también `{last}`) |
   | `{marked}` | El panel marcado con `prefix` `m` |

3. **`display-message` no valida.** Pide algo que no existe:
   ```bash
   r api:9; echo $?          # api:0.0 ... y sale con 0
   tmux -L lab list-panes -t api:9; echo $?   # can't find window: 9, sale con 1
   ```
   Un script que lee datos con `display` debe validar antes con `list-panes`.

4. **El prefijo.** Cierra `api` y repite tres comandos que parecen inofensivos:
   ```bash
   tmux -L lab kill-session -t api
   tmux -L lab has-session -t api; echo $?     # 0: ¡encontró api-2!
   tmux -L lab has-session -t =api; echo $?    # 1: api no existe
   tmux -L lab kill-session -t api             # cierra api-2
   tmux -L lab ls
   ```
   Sin `=`, un script que cierra o abre "api" puede actuar sobre `api-2`, `api-vieja`
   o cualquier sesión que empiece igual. Con dos candidatas (`api-2` y `api-3`),
   `-t api` falla por ambigua; con una sola, la elige sin avisar.

5. Prueba el patrón: `tmux -L lab has-session -t 'w*'` encuentra `web`.

6. **Puntos y dos puntos.** El `.` y el `:` separan las partes del target, así
   que no pueden ir en un nombre de sesión:
   ```bash
   tmux -L lab new -d -s web.app
   tmux -L lab ls -F '#{session_name}'          # web_app
   tmux -L lab has-session -t =web.app          # can't find pane: app
   ```
   tmux cambió el nombre sin avisar, y el target `web.app` se lee como sesión
   `web`, panel `app`. Un script que crea sesiones con el nombre de un
   directorio debe rechazar o sustituir esos caracteres.

7. Completa `starter/resolver.sh`: recibe un target, comprueba que existe y
   dice exactamente a qué apunta.
   ```bash
   tmux -L lab kill-server
   tmux -L lab new -d -s api -n editor \; new-window -d -n logs \; split-window -d -t :logs
   ./starter/resolver.sh api:logs.1
   ./starter/resolver.sh api:9; echo $?
   ```
   ```
   api:1.1  sesión $0  ventana @1  panel %2
   resolver.sh: no existe el target 'api:9'
   1
   ```

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Explicas cada fila de la tabla del paso 2 con un ejemplo que ejecutaste
- [ ] Reprodujiste el `kill-session -t api` que cierra `api-2` y lo evitas con `=`
- [ ] Sabes por qué `web.app` no sirve como nombre de sesión
- [ ] `./starter/resolver.sh` da las tres líneas del paso 7

## Reto extra

Haz que `resolver.sh` acepte `-s` para resolver solo sesiones con
`has-session -t "=$1"` y explique, si falla, si había una sesión que empezaba
igual.
