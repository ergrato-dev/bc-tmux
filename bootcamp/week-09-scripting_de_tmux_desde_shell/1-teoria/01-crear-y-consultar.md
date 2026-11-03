# Contexto — Crear y consultar desde un script

## ¿Por qué importa esto?

Todo lo que haces con el prefix es un comando de tmux que puedes lanzar desde bash. Un script que monta tu entorno en un segundo solo ahorra tiempo si es fiable, y un script de tmux que se equivoca casi nunca da error: sale con 0 y actúa sobre otra sesión, otra ventana u otro servidor.

## Crear sin conectarse

Un script no tiene terminal: `new-session` sin `-d` falla con `open terminal failed: not a terminal`. Con `-d` la sesión nace desconectada y el script sigue.

- `-s` nombre de la sesión, `-n` nombre de la primera ventana, `-c` directorio, `-x`/`-y` tamaño (sin cliente no hay de dónde sacarlo; tras `attach` manda tu terminal).
- `-P -F '#{pane_id}'` imprime lo que acabas de crear. Guarda ese id (`%3`) y úsalo como target: no cambia aunque muevas, renombres o renumeres la ventana.
- `new-window` y `split-window` aceptan los mismos `-c`, `-P` y `-F`. Sin `-c` y sin cliente, el panel nace en el directorio del proceso que ejecuta el script, no en el de la sesión.
- Una cadena con `\;` es una sola invocación: los `new-window` sin `-t` van a la sesión recién creada.

## Consultar

- `list-sessions`, `list-windows` y `list-panes` con `-F` imprimen una línea por objeto con los campos que pidas. `-f` filtra con un format que vale 1 o 0. `-a` recorre todo el servidor; `list-panes -s`, todos los paneles de una sesión.
- Esa salida se lee con `while read -r`, nunca con `for x in $(...)`: un nombre con espacios se partiría.
- **`display -p -t X` no valida**: si `X` no existe sale con 0 e imprime campos vacíos o los de otro objeto. Para saber si un target existe, `list-panes -t X`, que sí falla con rc 1.
- Sin servidor, `list-sessions` sale con 1 y `no server running`, y no arranca uno.

## Referencia rápida

| Comando | Para qué |
|---|---|
| `new-session -d -s api -n editor -c DIR -x 120 -y 30` | Sesión desconectada, con nombre, ventana y directorio |
| `new-window -d -t "=api:" -n run -c DIR -P -F '#{pane_id}'` | Ventana nueva en `api` sin cambiar la actual; imprime su panel |
| `split-window -t %1 -P -F '#{pane_id}'` | Partir un panel concreto y quedarte con el id del nuevo |
| `list-windows -t "=api" -F '#{window_index} #{window_name}'` | Ventanas de `api`, una por línea |
| `list-windows -a -F '#{session_name}:#{window_name}' -f '#{==:#{window_name},run}'` | Todas las ventanas `run` del servidor |
| `list-panes -t X -F '#{pane_id}'` | Validar `X`: rc 1 si no existe |

## Ejemplo mínimo funcional

```bash
mkdir -p /tmp/demo09/api
tmux -L demo -f /dev/null new-session -d -s api -n editor -c /tmp/demo09/api -x 120 -y 30 \
  -P -F '#{session_id} #{window_id} #{pane_id}'
run=$(tmux -L demo new-window -d -t "=api:" -n run -c /tmp/demo09/api -P -F '#{pane_id}')
echo "panel de run: $run"
tmux -L demo new-session -d -s api-2 \; new-window -n run \; new-window -n logs
tmux -L demo list-sessions -F '#{session_name} #{session_windows}'
tmux -L demo list-windows -t "=api" -F '#{window_index} #{window_name} #{pane_current_path} #{window_width}x#{window_height}'
tmux -L demo list-windows -a -F '#{session_name}:#{window_name}' -f '#{==:#{window_name},run}'
tmux -L demo list-panes -s -t "=api" -F '#{pane_id} #{window_name}' |
  while read -r id win; do echo "$win -> $id"; done
tmux -L demo display -p -t noexiste: '[#{session_name}]'; echo "rc=$?"
tmux -L demo list-panes -t noexiste: -F x; echo "rc=$?"
tmux -L demo kill-server
```

## Qué observar

- El primer comando imprime `$0 @0 %0`: sesión, ventana y panel, los ids que usará el resto del script.
- `api` tiene 2 ventanas y `api-2` 3: la cadena con `\;` metió `run` y `logs` en la sesión que acababa de crear.
- `list-windows` enseña `/tmp/demo09/api` y `120x30` en las dos ventanas de `api`, sin haberte conectado nunca.
- El filtro `-f` devuelve `api:run` y `api-2:run`, nada más.
- `display -p` sobre una sesión que no existe imprime `[]` y `rc=0`; `list-panes` dice `can't find session: noexiste` y `rc=1`.

---
Listo. Ve al [lab-01](../2-practicas/lab-01-crear-sin-conectarse/README.md) y ponlo en práctica.
