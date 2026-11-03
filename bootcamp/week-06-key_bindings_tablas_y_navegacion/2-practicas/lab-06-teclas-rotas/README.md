# Lab 06 — Teclas rotas

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cinco errores de bindings de la config de un compañero usando `source-file`, `list-keys` y `show-messages` en lugar de adivinar.

## Contexto

Un compañero te pasa `starter/tmux.conf`. Dice que tiene un modo resize en
`prefix` `R`, ventanas nuevas en el directorio actual, copy mode con
`prefix` `Enter`, sincronizar paneles con `prefix` `S` y que `prefix`
`Space` ya no cambia el layout. Al usarla, la shell no ejecuta nada y casi
ninguna de esas teclas hace lo que dice. Hay **cinco errores reales**, todos
de esta semana:

- Un binding pisado por otro posterior.
- Comillas mal anidadas dentro de un `if -F`.
- Una tecla en `root` que roba algo esencial a la shell.
- Un `-r` en una tecla que no se debe repetir.
- Un `unbind` en la tabla equivocada.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-06-teclas-rotas
   ```
   El servidor es `-L lab`. La config del compañero fija el prefix:
   **`C-a`**.

1. **Errores al cargar.** En la terminal A:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab show -gv prefix
   tmux -L lab source-file /dev/null; echo $?
   ```
   Algo como (la ruta es la de tu repositorio):
   ```
   C-a
   /bc-tmux/bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-06-teclas-rotas/starter/tmux.conf:36: command if-shell: too many arguments (need at most 3)
   0
   ```
   Con `new -d` el error queda guardado hasta el primer cliente o el primer
   `source-file` (semana 05, lab 01). La config cargó **casi** entera: el
   prefix es `C-a`. Solo falló la línea 36:
   ```bash
   tmux -L lab list-keys -T prefix S
   ```
   ```
   unknown key: S
   ```
   Ojo: `source-file -n`, que solo parsea, **no** lo detecta. El error
   aparece al construir el comando:
   ```bash
   tmux -L lab source-file -n "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   ```
   ```
   0
   command if-shell: too many arguments (need at most 3)
   1
   ```
   **Error 2.** Lee la línea 36. `'setw synchronize-panes on ; display
   'cuidado: sync on''`: la segunda `'` cierra la primera, así que `if`
   recibe cuatro argumentos en vez de tres. Arréglalo con bloques, que no
   necesitan comillas dentro de comillas:
   ```tmux
   bind S if -F '#{synchronize-panes}' {
     setw synchronize-panes off
   } {
     setw synchronize-panes on
     display 'cuidado: sync on'
   }
   ```
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T prefix S
   ```
   ```
   0
   bind-key -T prefix S if-shell -F "#{synchronize-panes}" { set-window-option synchronize-panes off } { set-window-option synchronize-panes on ;; display-message "cuidado: sync on" }
   ```

2. **La shell no ejecuta nada.** En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   Escribe `echo hola` y pulsa `Enter`. No se ejecuta: arriba a la derecha
   aparece `[0/0]`, estás en copy mode. Sal con `q`; `echo hola` sigue en
   la línea sin ejecutar. ¿Qué hizo `Enter`? En la terminal A:
   ```bash
   tmux -L lab show-messages | grep key | head -3
   ```
   Algo como (la hora y el terminal varían; lo más reciente, arriba):
   ```
   01:01: /dev/pts/1 key q: send-keys -X cancel
   01:01: /dev/pts/1 key Enter: copy-mode
   01:01: client-26 command: bind-key R source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```
   `show-messages` registra cada tecla que tmux se queda y el comando que
   ejecutó (necesita un cliente conectado: sin ninguno, `no current
   client`). Confírmalo:
   ```bash
   tmux -L lab list-keys -T root Enter
   tmux -L lab list-keys -T prefix Enter
   ```
   ```
   bind-key -T root Enter copy-mode
   unknown key: Enter
   ```
   **Error 3.** El compañero quería `prefix` `Enter` y escribió `-n`. En el
   archivo, quita el `-n` (`bind Enter copy-mode`). Recargar **no** borra la
   tecla de `root`: quítala a mano para seguir trabajando (terminal A):
   ```bash
   tmux -L lab unbind -n Enter
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T prefix Enter
   ```
   ```
   0
   bind-key -T prefix Enter copy-mode
   ```
   En la B, `Enter` ejecuta el `echo hola`.

3. **El modo resize no existe.** En la B, `C-a` `R`. La barra muestra
   `config recargada` y sigue en `tabla: root`. En la terminal A:
   ```bash
   tmux -L lab list-keys -T prefix R
   tmux -L lab list-keys -N -T prefix R
   grep -n 'bind.* R ' starter/tmux.conf
   ```
   ```
   bind-key -T prefix R source-file -F "#{@lab-dir}/tmux.conf" \; display-message "config recargada"
   unknown key: R
   18:bind -N "modo resize" R switch-client -T resize
   39:bind R source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```
   La nota se perdió con el segundo `bind` (lab 01). **Error 1.** La línea
   39 pisa la 18. Pasa la recarga a `r`:
   ```tmux
   bind r source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```
   Recargar pondría `R` como en la línea 18 (la 39 ya no la toca), pero
   compruébalo al final con un servidor limpio (paso 6).

4. **Ventanas de más.** En la B, `C-a` `c` y escribe enseguida `cd /tmp`.
   Aparecen **dos** ventanas nuevas y la shell muestra `d /tmp`. Vacía la
   línea con `C-u`. En la terminal A:
   ```bash
   tmux -L lab list-windows -F '#{window_index} #{window_active}'
   tmux -L lab list-keys -T prefix c
   ```
   ```
   0 0
   1 0
   2 1
   bind-key -r -T prefix c new-window -c "#{pane_current_path}"
   ```
   **Error 4.** Con `-r`, la `c` de `cd` dentro de `repeat-time` fue otro
   `prefix` `c`. `-r` es para teclas que se pulsan en ráfaga (redimensionar,
   moverse), nunca para crear o cerrar cosas. Quita el `-r`. Cierra las
   ventanas de más: en la B, `exit` en las dos nuevas.

5. **`C-a` `Space` sigue cambiando el layout.** En la terminal A, parte la
   ventana y mira el layout antes y después de pulsar `C-a` `Space` en la B:
   ```bash
   tmux -L lab split-window -h
   tmux -L lab display -p '#{window_layout}'
   ```
   Algo como (cambia con tu terminal):
   ```
   f0a4,120x30,0,0{60x30,0,0,2,59x30,61,0,3}
   ```
   Tras `C-a` `Space` en la B:
   ```
   f894,120x30,0,0{59x30,0,0,2,60x30,60,0,3}
   ```
   ```bash
   tmux -L lab list-keys -T prefix Space
   tmux -L lab list-keys -T root Space
   ```
   ```
   bind-key -T prefix Space next-layout
   unknown key: Space
   ```
   **Error 5.** `unbind -n Space` quitó `Space` de `root`, donde no
   existía, y `unbind` no avisa de que no había nada. La tecla está en
   `prefix`: `unbind Space`. Sal de la B con `C-a` `d`:
   ```
   [detached (from session lab)]
   ```

6. **Comprueba todo con un servidor limpio.** Recargar no deshace lo que la
   versión rota dejó puesto: reinicia (terminal A).
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab source-file /dev/null; echo $?
   for k in R r c Enter Space; do tmux -L lab list-keys -T prefix "$k"; done
   tmux -L lab list-keys -T root Enter
   ```
   ```
   0
   bind-key -T prefix R switch-client -T resize
   bind-key -T prefix r source-file -F "#{@lab-dir}/tmux.conf" \; display-message "config recargada"
   bind-key -T prefix c new-window -c "#{pane_current_path}"
   bind-key -T prefix Enter copy-mode
   unknown key: Space
   unknown key: Enter
   ```
   Sin errores al cargar, y cada tecla donde debe. En la B,
   `tmux -L lab attach -t lab` y prueba:
   - `C-a` `S`: la barra muestra `cuidado: sync on`. Otra vez `C-a` `S`
     lo apaga. En A, `tmux -L lab show -wv synchronize-panes` imprime `on`
     y luego `off`.
   - `C-a` `R`: la barra pasa a `tabla: resize`; sal con `q`.
   - `C-a` `r`: `config recargada`.
   - `C-a` `c` y enseguida `cd /tmp`: una sola ventana nueva y `cd /tmp`
     completo en la línea.
   - `C-a` `Enter`: copy mode (`[0/0]`); sal con `q`.

   Sal con `C-a` `d`: `[detached (from session lab)]`.

7. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Los cinco errores identificados, con una línea por cada uno: síntoma, cómo lo viste (`source-file`, `list-keys`, `show-messages`) y causa (pasos 1-5)
- [ ] `tmux -L lab source-file /dev/null` no muestra errores con el servidor recién arrancado (paso 6)
- [ ] `tmux -L lab list-keys -T prefix R` muestra `switch-client -T resize` y `r` recarga (paso 6)
- [ ] `tmux -L lab list-keys -T prefix c` no tiene `-r` (paso 6)
- [ ] `tmux -L lab list-keys -T root Enter` imprime `unknown key: Enter` y `-T prefix Space`, `unknown key: Space` (paso 6)
- [ ] `C-a` `S` activa y desactiva `synchronize-panes` con aviso (paso 6)

## Reto extra

Escribe un script `check-dupes.sh CONF` que avise de teclas definidas dos
veces en la misma tabla dentro de un archivo (como el error 1). Pista: con
`awk`, quédate con la tabla (`-T X`, `-n` = `root`, por defecto `prefix`) y
la tecla de cada línea `bind`. ¿Qué casos se le escapan (bloques `{}`,
`source-file` de otros archivos)?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — Navegación consciente](../lab-05-navegacion-consciente/README.md) | [Proyecto — tmux-kit: modo resize, navegación sin prefix y teclas documentadas](../../3-proyecto/README.md) → |

[↑ Semana 06](../../README.md)
