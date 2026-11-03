# Lab 01 — Hooks

⏱ Duración estimada: ~60 min

## Objetivo

Definir hooks que reaccionan a ventanas, sesiones, paneles y clientes nuevos, y que siguen siendo uno solo después de recargar la config.

## Contexto

- Un hook es una opción de tipo lista: `set-hook -g after-new-window 'cmd'` pone la entrada `[0]`; `-a` añade otra al final; `-u` borra una entrada o la lista entera.
- Recargar un archivo con `set-hook -ga` añade la misma entrada otra vez: el hook se ejecuta dos, tres veces. Un índice fijo (`after-new-window[10]`) sustituye siempre la misma.
- Dentro del hook hay formats propios (`#{hook_session_name}`), pero en 3.4 `#{hook_pane}` sale vacío en los `after-*`: el panel recién creado es `#{pane_id}`.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-01-hooks
   ```
   Arranca el servidor `-L lab` con el starter como dice
   [Antes de cada lab](../README.md#antes-de-cada-lab) (paso 3):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   La terminal B solo hace falta en el paso 8.

1. **Qué hooks hay.** `show-hooks -g` lista todos los eventos, tengan o no
   comando; los que tienen comando llevan su índice entre corchetes:
   ```bash
   tmux -L lab show-hooks -g | wc -l
   tmux -L lab show-hooks -g | grep '\['
   ```
   ```
   54
   after-new-window[0] set-option -Fg @lab-windows "#{e|+:#{@lab-windows},1}"
   ```
   Es el hook del starter: suma 1 a `@lab-windows` (`#{e|+:a,b}` es una
   suma) cada vez que se crea una ventana.

2. **El hook funciona:**
   ```bash
   tmux -L lab new-window -d; tmux -L lab new-window -d; tmux -L lab show -gv @lab-windows
   ```
   ```
   2
   ```

3. **Recargar lo duplica.** La recarga pone `@lab-windows` a 0 y vuelve a
   ejecutar el `set-hook -ga`:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g | grep '\['
   tmux -L lab new-window -d; tmux -L lab show -gv @lab-windows
   ```
   ```
   after-new-window[0] set-option -Fg @lab-windows "#{e|+:#{@lab-windows},1}"
   after-new-window[1] set-option -Fg @lab-windows "#{e|+:#{@lab-windows},1}"
   2
   ```
   Una ventana, dos sumas. Con `prefix` `r` (recarga) en tu kit pasaría lo
   mismo con cada hook: mensajes repetidos, logs abiertos dos veces.

4. **TODO 1 — índice fijo.** En `starter/tmux.conf` cambia
   `set-hook -ga after-new-window` por `set-hook -g after-new-window[10]`.
   Las entradas `[0]` y `[1]` siguen en el servidor: bórralas con `-u` (sin
   índice, borra la lista entera) y recarga **dos** veces:
   ```bash
   tmux -L lab set-hook -gu after-new-window; tmux -L lab show-hooks -g | grep after-new-window
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g | grep '\['
   tmux -L lab new-window -d; tmux -L lab show -gv @lab-windows
   ```
   ```
   after-new-window
   after-new-window[10] set-option -Fg @lab-windows "#{e|+:#{@lab-windows},1}"
   1
   ```
   `after-new-window` sin corchetes es el evento vacío. Tras dos recargas
   hay una sola entrada, y una ventana suma 1.

5. **TODO 2 — `session-created`.** Quita el `#   ` de la línea
   `set-hook -g session-created[10] ...`. En este evento,
   `#{hook_session_name}` es la sesión recién creada:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab new -d -s api; tmux -L lab show -gv @lab-last-session
   tmux -L lab new-window -d -t api:; tmux -L lab show -gv @lab-windows
   ```
   ```
   api
   1
   ```
   `new-session` no dispara `after-new-window` (su primera ventana no
   cuenta): solo la ventana nueva de `api` subió el contador, que la
   recarga había puesto a 0.

6. **TODO 3 — `after-split-window` y el panel nuevo.** Quita el `#   ` de
   la línea `set-hook -g after-split-window[10] ...`. `-P -F` imprime el id
   del panel creado, para compararlo:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab split-window -d -t lab: -P -F '#{pane_id}'
   tmux -L lab show -gv @lab-last-pane
   ```
   Algo como (cambia el número del `%`):
   ```
   %7
   hook= nuevo=%7
   ```
   `#{hook_pane}` vacío, `#{pane_id}` el panel nuevo: en tus hooks
   `after-*` usa `#{pane_id}`.

7. **Borrar una sola entrada.** `-u` con índice borra solo esa:
   ```bash
   tmux -L lab set-hook -gu 'after-split-window[10]'; tmux -L lab show-hooks -g | grep after-split
   tmux -L lab split-window -d -t lab: -P -F '#{pane_id}'
   tmux -L lab show -gv @lab-last-pane
   ```
   Algo como:
   ```
   after-split-window
   %8
   hook= nuevo=%7
   ```
   El split `%8` ya no actualiza `@lab-last-pane`. La recarga del paso
   siguiente vuelve a poner el hook.

8. **TODO 4 — `client-attached`.** Quita el `#   ` de la línea
   `set-hook -g client-attached[10] ...` y recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g | grep '\['
   ```
   ```
   after-new-window[10] set-option -Fg @lab-windows "#{e|+:#{@lab-windows},1}"
   after-split-window[10] set-option -Fg @lab-last-pane "hook=#{hook_pane} nuevo=#{pane_id}"
   client-attached[10] display-message -d 3000 "lab: #{session_name} (#{session_windows} ventanas)"
   session-created[10] set-option -Fg @lab-last-session "#{hook_session_name}"
   ```
   En la **terminal B** (fuera de tmux, en la misma carpeta), conéctate:
   ```bash
   tmux -L lab attach -t lab
   ```
   Durante 3 s la barra de abajo muestra:
   ```
   lab: lab (5 ventanas)
   ```
   Sal con `C-b` `d` (el servidor arrancó con el starter, que no cambia el
   prefix). B imprime:
   ```
   [detached (from session lab)]
   ```

9. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Tras dos `source-file` seguidos, `tmux -L lab show-hooks -g | grep '\['` muestra una sola línea `after-new-window[10]` (paso 4)
- [ ] `tmux -L lab new -d -s api; tmux -L lab show -gv @lab-last-session` imprime `api` (paso 5)
- [ ] `@lab-last-pane` muestra `hook=` vacío y el mismo `%N` que imprimió `split-window -P` (paso 6)
- [ ] Explicas qué hace `set-hook -gu 'after-split-window[10]'` y en qué se diferencia de `set-hook -gu after-split-window` (pasos 4 y 7)
- [ ] Al conectarte con `attach`, la barra muestra `lab: lab (N ventanas)` (paso 8)

## Reto extra

`remain-on-exit on` deja a la vista los paneles cuyo programa terminó, y el
evento `pane-died` salta entonces. Añade un hook `pane-died[10]` que guarde
en `@lab-died` el código de salida (`#{pane_dead_status}`) y pruébalo con
`tmux -L lab new-window -d 'exit 7'`. ¿Por qué sin `remain-on-exit on` el
hook no llega a ejecutarse?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Popups](../lab-02-popups/README.md) → |

[↑ Semana 10](../../README.md)
