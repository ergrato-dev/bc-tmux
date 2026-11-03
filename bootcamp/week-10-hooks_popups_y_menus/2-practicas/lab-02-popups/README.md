# Lab 02 — Popups

⏱ Duración estimada: ~60 min

## Objetivo

Lanzar comandos y scripts en popups que se cierran solos al terminar, con tamaño, título, directorio y entorno propios.

## Contexto

- `display-popup` abre una ventana flotante sobre el cliente conectado y ejecuta un comando dentro. Sin cliente conectado no aparece nada: este lab necesita la terminal B.
- Sin `-E` el popup sigue abierto cuando el comando termina y solo se cierra con `Escape` (`q` no sirve). `-E` lo cierra al terminar; `-EE`, solo si el comando sale con 0.
- En 3.4 el comando del popup **no** se expande como format (`#{session_name}` llega literal a la shell). Dentro del popup `$TMUX` apunta al servidor, así que `tmux display -p` pregunta lo que necesites.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux**, las dos desde la raíz del
   repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-02-popups
   ```
   En la **terminal A**, prepara el lab como dice
   [Antes de cada lab](../README.md#antes-de-cada-lab) (pasos 3 y 5):
   ```bash
   mkdir -p /tmp/lab10; export TMUX_SOCKET=lab
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   En la **terminal B**, conéctate y déjala a la vista:
   ```bash
   tmux -L lab attach -t lab
   ```
   El prefix es `C-b`: el starter no lo cambia. Los popups de los pasos 1
   a 4 los lanzas desde A y aparecen en B; A no vuelve al prompt hasta que
   el popup se cierra.

1. **Un popup sin `-E`** (terminal A):
   ```bash
   tmux -L lab display-popup -w 60 -h 10 'echo hola desde un popup'; echo $?
   ```
   En B aparece un recuadro de 60 × 10 con `hola desde un popup`. Pulsa
   `q` en B: no pasa nada, el popup sigue ahí. Pulsa `Escape`: se cierra, y
   A imprime:
   ```
   0
   ```

2. **`-E` y `-EE`.** El primero se cierra solo a los 3 s; el segundo
   parpadea y se cierra (el código de salida del comando llega a A):
   ```bash
   tmux -L lab display-popup -E 'echo se cierra solo; sleep 3'; echo $?
   tmux -L lab display-popup -E 'exit 4'; echo $?
   ```
   ```
   0
   4
   ```
   Con `-EE` un fallo deja el popup abierto para que leas el error:
   ```bash
   tmux -L lab display-popup -EE 'echo algo falló; exit 4'; echo $?
   ```
   B muestra `algo falló` y espera. Pulsa `Escape` en B; A imprime:
   ```
   4
   ```

3. **El comando no es un format** (terminal A):
   ```bash
   tmux -L lab display-popup 'echo "sesión: #{session_name}"; echo "con tmux: $(tmux display -p "#{session_name}")"'
   ```
   B muestra:
   ```
   sesión: #{session_name}
   con tmux: lab
   ```
   La primera línea es literal; la segunda la calcula `tmux` desde dentro
   del popup, sin `-L`, porque `$TMUX` ya apunta al servidor del lab.
   Cierra con `Escape`.

4. **Directorio y entorno.** `-d` fija el directorio; `-e` añade una
   variable solo para ese popup:
   ```bash
   tmux -L lab display-popup -d /tmp/lab10 -e LAB_MODE=popup 'pwd; echo "LAB_MODE=$LAB_MODE"'
   ```
   B muestra:
   ```
   /tmp/lab10
   LAB_MODE=popup
   ```
   Cierra con `Escape`. Sin `-d`, el popup arranca en el directorio del
   panel.

5. **TODO 3 — `starter/popup-info.sh`.** Primero, tal cual (terminal A).
   `echo |` le da la tecla que espera `read`; `TMUX_SOCKET=lab` lleva `tmx`
   al servidor del lab, porque A no está dentro de tmux:
   ```bash
   echo | TMUX_SOCKET=lab ./starter/popup-info.sh; echo $?
   ```
   Algo como (cambia la ruta):
   ```
   sin implementar
   directorio: /bc-tmux/bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-02-popups
   0
   ```
   Borra `echo "sin implementar"` y pon en su lugar
   `tmx display -p 'sesión #{session_name}, ventana #{window_index}, panel #{pane_id}'`:
   ```bash
   echo | TMUX_SOCKET=lab ./starter/popup-info.sh; echo $?
   ```
   Algo como:
   ```
   sesión lab, ventana 0, panel %0
   directorio: /bc-tmux/bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-02-popups
   0
   ```

6. **TODO 1 — `prefix` `y`.** En `starter/tmux.conf` quita el `#   ` de la
   línea `bind y display-popup ...`. La ruta sale de `@lab-dir`, que la
   config calcula con `#{d:current_file}`. Recarga y comprueba (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix y
   ```
   ```
   bind-key -T prefix y display-popup -E -T " info " -h "40%" -w "60%" "exec \"$(tmux show -gv @lab-dir)/popup-info.sh\""
   ```
   En B pulsa `C-b` `y`: un popup con ` info ` en el borde de arriba
   muestra
   ```
   sesión lab, ventana 0, panel %0
   directorio: /bc-tmux/bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-02-popups
   pulsa una tecla para cerrar
   ```
   Pulsa cualquier tecla: el script termina y `-E` cierra el popup.

7. **TODO 2 — `prefix` `u`.** Quita el `#   ` de la línea
   `bind u display-popup -E -w 90% -h 90% top` y recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix u
   ```
   ```
   bind-key -T prefix u display-popup -E -h "90%" -w "90%" top
   ```
   En B pulsa `C-b` `u`: `top` ocupa casi toda la pantalla, encima de tu
   panel. Sal de `top` con `q`: el popup se cierra con él.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab10
   ```
   B imprime `[server exited]`.

## Criterios de éxito

- [ ] Explicas por qué `q` no cerró el popup del paso 1 y `Escape` sí
- [ ] `tmux -L lab display-popup -E 'exit 4'; echo $?` imprime `4` (paso 2)
- [ ] Explicas por qué el paso 3 imprime `#{session_name}` literal y cómo obtener el nombre desde dentro del popup
- [ ] `echo | TMUX_SOCKET=lab ./starter/popup-info.sh` imprime `sesión lab, ventana 0, panel %0` (paso 5)
- [ ] `C-b` `y` abre el popup ` info ` y una tecla lo cierra (paso 6)
- [ ] `C-b` `u` abre `top` y `q` cierra a la vez `top` y el popup (paso 7)

## Reto extra

Con un popup abierto, lanzar otro no hace nada. Abre uno sin `-E` desde A
con `&` al final (`tmux -L lab display-popup 'echo abierto' &`) y ciérralo
desde A con `tmux -L lab display-popup -C`. ¿Para qué te serviría en un
script que abre un popup de espera?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Hooks](../lab-01-hooks/README.md) | [Lab 03 — Menús y prompts](../lab-03-menus-y-prompts/README.md) → |

[↑ Semana 10](../../README.md)
