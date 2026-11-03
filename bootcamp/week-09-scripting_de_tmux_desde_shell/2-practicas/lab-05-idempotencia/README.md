# Lab 05 — Idempotencia

⏱ Duración estimada: ~60 min

## Objetivo

Escribir un script que crea o reutiliza una sesión y sus ventanas por nombre exacto, de modo que ejecutarlo dos veces deja el servidor igual que una.

## Contexto

- Idempotente: la segunda ejecución no cambia nada y no falla. Así un script se puede relanzar sin pensar (al abrir la terminal, desde un binding, tras cerrar una ventana).
- `-t api` en un comando de sesión casa por **prefijo**: si `api` no existe, encuentra `api-2`. `-t =api` pide el nombre exacto.
- `new-session -A` ("conéctate si existe") no sirve en un script: si la sesión existe, intenta conectarse aunque lleve `-d`.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-05-idempotencia
   ```
   Arranca el servidor `-L lab` como dice [Antes de cada lab](../README.md#antes-de-cada-lab)
   (paso 3).

1. **Crear dos veces falla:**
   ```bash
   mkdir -p /tmp/lab09/api; tmux -L lab new-session -d -s api -c /tmp/lab09/api; echo $?
   tmux -L lab new-session -d -s api -c /tmp/lab09/api; echo $?
   ```
   ```
   0
   duplicate session: api
   1
   ```

2. **`-A` tampoco sirve en un script:**
   ```bash
   tmux -L lab new-session -A -d -s api; echo $?
   tmux -L lab new-session -A -d -s web; echo $?
   tmux -L lab new-session -A -d -s web; echo $?
   ```
   ```
   open terminal failed: not a terminal
   1
   0
   open terminal failed: not a terminal
   1
   ```
   Crea la primera vez y falla todas las demás.

3. **El prefijo engaña.** Solo existe `api-2`:
   ```bash
   tmux -L lab kill-session -t =api; tmux -L lab kill-session -t =web; tmux -L lab new-session -d -s api-2
   tmux -L lab has-session -t api; echo $?
   tmux -L lab has-session -t =api; echo $?
   ```
   ```
   0
   can't find session: api
   1
   ```
   Un script con `has-session -t api` creería que `api` existe y no la
   crearía nunca. `api-2` se queda durante todo el lab para probarlo.

4. **El starter, tal cual.** Crea bien la primera vez y falla la segunda:
   ```bash
   ./starter/workspace api /tmp/lab09/api; echo $?
   ./starter/workspace api /tmp/lab09/api; echo $?
   tmux -L lab list-windows -t =api -F '#{window_index} #{window_name}'
   ```
   ```
   0
   duplicate session: api
   1
   0 editor
   1 run
   2 logs
   ```

5. **Completa `starter/workspace`.** Antes de cada prueba,
   `tmux -L lab kill-session -t =api` para empezar sin la sesión.

   1. **TODO 1 — la sesión, solo si no existe.** Cambia la línea
      `tmx new-session ...` por el `if tmx has-session -t "=$name" 2>/dev/null; then ... else ... fi`
      del comentario. `2>/dev/null` calla el `can't find session` de cuando
      no existe: ahí no es un error.
      ```bash
      tmux -L lab kill-session -t =api
      ./starter/workspace api /tmp/lab09/api; echo $?
      ./starter/workspace api /tmp/lab09/api; echo $?
      tmux -L lab list-windows -t =api -F '#{window_index} #{window_name}'
      ```
      ```
      workspace: sesión 'api' creada en /tmp/lab09/api
      0
      workspace: la sesión 'api' ya existe
      0
      0 editor
      1 run
      2 logs
      3 run
      4 logs
      ```
      Ya no falla, pero duplica `run` y `logs`: la sesión es idempotente,
      las ventanas no.
   2. **TODO 2 — solo las ventanas que falten.** Antes del bucle,
      `existing=$(tmx list-windows -t "=$name" -F '#{window_name}')`;
      dentro, antes de `new-window`,
      `grep -qxF -- "$window" <<<"$existing" && continue` (`-x` línea
      entera, `-F` sin comodines); después,
      `echo "workspace: ventana '$window' creada"`. Y recorre
      `"${WINDOWS[@]}"` en vez de `"${WINDOWS[@]:1}"`.
      ```bash
      tmux -L lab kill-session -t =api
      ./starter/workspace api /tmp/lab09/api; echo $?
      ```
      Algo como (cambian los `@`):
      ```
      workspace: sesión 'api' creada en /tmp/lab09/api
      workspace: ventana 'run' creada
      workspace: ventana 'logs' creada
      0
      ```

6. **Demuestra que es idempotente.** Una foto antes y otra después; el
   `window_id` delata cualquier ventana nueva aunque se llame igual:
   ```bash
   tmux -L lab list-windows -t =api -F '#{window_index} #{window_id} #{window_name} #{pane_current_path}' > /tmp/lab09/antes; cat /tmp/lab09/antes
   ./starter/workspace api /tmp/lab09/api; echo $?
   tmux -L lab list-windows -t =api -F '#{window_index} #{window_id} #{window_name} #{pane_current_path}' > /tmp/lab09/despues; diff /tmp/lab09/antes /tmp/lab09/despues && echo 'sin cambios'
   ```
   Algo como:
   ```
   0 @6 editor /tmp/lab09/api
   1 @7 run /tmp/lab09/api
   2 @8 logs /tmp/lab09/api
   workspace: la sesión 'api' ya existe
   0
   sin cambios
   ```

7. **Repara lo que falta.** Cierra `logs` y relanza:
   ```bash
   tmux -L lab kill-window -t =api:logs; ./starter/workspace api /tmp/lab09/api; echo $?
   tmux -L lab list-windows -t =api -F '#{window_index} #{window_id} #{window_name}'
   tmux -L lab list-sessions -F '#{session_name} #{session_windows}'
   ```
   Algo como:
   ```
   workspace: la sesión 'api' ya existe
   workspace: ventana 'logs' creada
   0
   0 @6 editor
   1 @7 run
   2 @9 logs
   api 3
   api-2 1
   ```
   Solo `logs` es nueva (`@9`), y `api-2` sigue con su única ventana.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `new-session -A -d` no sirve para un script (paso 2)
- [ ] Explicas, con `api-2`, por qué los comandos de sesión llevan `-t "=$name"` (paso 3)
- [ ] Dos ejecuciones seguidas de `./starter/workspace api /tmp/lab09/api` salen con 0 y `diff` dice `sin cambios` (paso 6)
- [ ] Tras cerrar `logs`, relanzar crea solo esa ventana (paso 7)

## Reto extra

El nombre `a.b` no sirve como target (`.` separa ventana y panel) y tmux
lo guarda como `a_b`. Pruébalo: `./starter/workspace a.b /tmp/lab09/api`
dos veces. ¿Qué pasa la segunda vez, y por qué? Arréglalo validando el
nombre al principio del script (sal con 2 si tiene `.` o `:`).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — Esperar con wait-for](../lab-04-esperar-con-wait-for/README.md) | [Lab 06 — Script roto](../lab-06-script-roto/README.md) → |

[↑ Semana 09](../../README.md)
