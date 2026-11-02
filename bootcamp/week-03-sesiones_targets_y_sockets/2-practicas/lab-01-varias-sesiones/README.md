# Lab 01 — Varias sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Crear y organizar varias sesiones, moverte entre ellas con `choose-tree` y cerrar las que sobran sin tocar las demás.

## Contexto

- Lo normal es **una sesión por proyecto o tarea**: `api`, `web`, `notas`. Cada una guarda sus ventanas, su directorio y su historia.
- `choose-tree` (`prefix` `s` y `prefix` `w`) muestra el árbol sesión > ventana > panel con una vista previa, y permite saltar, cerrar o marcar elementos.
- `list-sessions` (`tmux ls`) solo pregunta: si no hay servidor falla, pero no arranca ninguno. `new-session` sí lo arranca.

## Instrucciones

1. Crea tres sesiones, solo la primera conectada:
   ```bash
   tmux -L lab new -d -s web
   tmux -L lab new -d -s notas
   tmux -L lab new -s api -n editor
   ```

2. Dentro de `api`, abre el árbol de sesiones con `prefix` `s`. Muévete con
   las flechas, despliega una sesión con `→` o `+` y elige una con `Enter`.
   Prueba también `prefix` `w`, que abre el árbol ya desplegado hasta las
   ventanas. Dentro del árbol:

   | Tecla | Qué hace |
   |---|---|
   | `Enter` | Salta al elemento |
   | `x` | Cierra el elemento (pide confirmación) |
   | `t` / `X` | Marca un elemento / cierra todos los marcados |
   | `O` | Cambia el orden: índice, nombre o actividad |
   | `v` | Muestra u oculta la vista previa |
   | `q` | Sale sin elegir |

3. Renombra la sesión actual con `prefix` `$` a `api-v2` y vuelve a llamarla
   `api`. Desde fuera: `tmux -L lab rename-session -t api api-v2`.

4. Desde otra terminal, mira las sesiones con más detalle:
   ```bash
   tmux -L lab ls -F '#{session_name}: #{session_windows} ventanas, #{session_attached} clientes, actividad #{t:session_activity}'
   ```
   `session_attached` cuenta los clientes conectados; `t:` convierte la hora
   en fecha legible.

5. Cierra `notas` desde fuera con `tmux -L lab kill-session -t notas`. Las
   demás siguen intactas. Desconéctate de `api` con `prefix` `d`.

6. **Preguntar no arranca nada.** Cierra el servidor y pregunta:
   ```bash
   tmux -L lab kill-server
   tmux -L lab ls; echo $?            # no server running, 1
   tmux -L lab has-session; echo $?   # igual: no arranca un servidor
   ls /tmp/tmux-$(id -u)/             # no aparece el socket lab
   tmux -L lab new -d -s api          # este sí lo arranca
   ```
   Un script que solo quiere listar no debe dejarte un servidor vacío.

7. Completa `starter/limpiar.sh`: cierra las sesiones cuyo nombre empieza por
   un prefijo y que **no tienen clientes conectados**, y dice qué cerró.
   ```bash
   tmux -L lab kill-server
   for s in tmp-1 tmp-2 tmpfiles api; do tmux -L lab new -d -s "$s"; done
   ./starter/limpiar.sh tmp-
   ```
   ```
   cerrada: tmp-1
   cerrada: tmp-2
   quedan: api tmpfiles
   ```
   Cierra cada sesión con `kill-session -t "=$nombre"`: el `=` pide el nombre
   exacto (lo verás a fondo en el lab 02).

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Saltas entre tres sesiones con `prefix` `s` y cierras una desde el árbol con `x`
- [ ] Muestras que `ls` y `has-session` no crean el socket y `new-session` sí
- [ ] `./starter/limpiar.sh tmp-` imprime las tres líneas del paso 7
- [ ] Una sesión `tmp-3` con un cliente conectado no se cierra

## Reto extra

Abre el árbol filtrado solo con las sesiones `tmp-*` desde el prompt
(`prefix` `:`): `choose-tree -s -f '#{m:tmp-*,#{session_name}}'`. Márcalas
todas con `Ctrl`+`t` y ciérralas con `X`.
