# Lab 04 — run-shell y pipe-pane

⏱ Duración estimada: ~60 min

## Objetivo

Ejecutar comandos de shell desde tmux sin bloquear al cliente y activar o desactivar el log de un panel con `pipe-pane -o` y una ruta citada a prueba de nombres hostiles.

## Contexto

- `run-shell` expande su comando como format y lo pasa a `sh`. Su salida no vuelve a quien lo lanzó: se abre en el **modo vista** del panel (sales con `q`). Sin `-b` espera a que termine, y mientras tanto el cliente no atiende otras teclas.
- `pipe-pane -o 'cmd'` envía todo lo que sale en el panel a la entrada de `cmd`; con `-o`, si ya había un pipe abierto, lo cierra (un interruptor). `#{pane_pipe}` dice si está abierto.
- El comando de `pipe-pane` pasa por dos lectores: tmux lo expande como format (un `#` se escribe `##`) y luego `sh` (espacios, `;`, `$`). Una ruta que venga de un nombre de sesión necesita los dos escapes.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux**, las dos desde la raíz del
   repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-04-run-shell-y-pipe-pane
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

1. **Adónde va la salida** (terminal A):
   ```bash
   tmux -L lab run-shell 'echo hola; echo "sesión #{session_name}"'; echo $?
   tmux -L lab display -p '#{pane_in_mode} #{pane_mode}'
   ```
   ```
   0
   1 view-mode
   ```
   A no imprime `hola`: el panel de B pasó al modo vista y muestra
   `hola` y `sesión lab` (`#{session_name}` se expandió). Pulsa `q` en B.
   ```bash
   tmux -L lab run-shell 'exit 3'; echo $?
   ```
   ```
   3
   ```
   B muestra `'exit 3' returned 3`; `q`. Con `-b`, A vuelve en el acto y la
   salida llega a B un segundo después:
   ```bash
   tmux -L lab run-shell -b 'sleep 1; echo en segundo plano'; echo $?
   ```
   ```
   0
   ```
   B muestra `en segundo plano`; `q`. `-C` ejecuta un comando de tmux, y
   ese sí imprime en A; `-d 2` espera 2 s antes de empezar:
   ```bash
   tmux -L lab run-shell -C 'display -p "panel #{pane_id}"'; echo $?
   time tmux -L lab run-shell -d 2 'echo tarde'
   ```
   Algo como:
   ```
   panel %0
   0

   real	0m2.008s
   user	0m0.000s
   sys	0m0.003s
   ```
   B muestra `tarde`; `q`.

2. **Un binding que bloquea.** El starter trae
   `bind b run-shell 'sleep 3; echo copia hecha'`. En B pulsa `C-b` `b` y
   enseguida `C-b` `c`: la ventana nueva no aparece hasta pasados 3 s, cuando
   termina el `sleep`. Mientras, el cliente parece colgado. Comprueba en A,
   pasados los 3 s:
   ```bash
   tmux -L lab list-windows -F '#{window_index} #{window_active}'
   ```
   ```
   0 0
   1 1
   ```
   La salida `copia hecha` quedó en el modo vista del panel de la ventana 0.

3. **TODO 4 — `-b`.** En `starter/tmux.conf` borra la línea
   `bind b run-shell 'sleep 3; echo copia hecha'` y quita el `#   ` de la que
   lleva `-b`. Recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix b
   ```
   ```
   bind-key -T prefix b run-shell -b "sleep 3; echo copia hecha"
   ```
   En B, `C-b` `b` y `C-b` `c`: la ventana nueva aparece al instante y a los
   3 s el panel pasa al modo vista con `copia hecha`; `q`. Deja solo la
   ventana 0 (terminal A):
   ```bash
   tmux -L lab kill-window -a -t lab:0; tmux -L lab list-windows -F '#{window_index} #{pane_in_mode}'
   ```
   ```
   0 1
   ```
   El `1` es el modo vista que dejó el paso 2: pulsa `q` en B. Con el panel
   en modo vista, `send-keys` se queda esperando; sal siempre antes de
   seguir.

4. **Un pipe a mano** (terminal A):
   ```bash
   tmux -L lab pipe-pane -o -t lab: 'cat >> /tmp/lab10/manual.log'; tmux -L lab display -p -t lab: '#{pane_pipe}'
   tmux -L lab send-keys -t lab: 'echo linea-del-log' Enter; sleep 1; grep -a -c linea-del-log /tmp/lab10/manual.log
   tmux -L lab pipe-pane -o -t lab:; tmux -L lab display -p -t lab: '#{pane_pipe}'
   ```
   ```
   1
   2
   0
   ```
   Dos líneas: el comando que se ve escrito y su salida. El log guarda lo
   que sale en pantalla, con colores y secuencias de control incluidas
   (`grep -a` lo trata como texto). El segundo `pipe-pane -o` lo cerró.

5. **El comando es un format:**
   ```bash
   tmux -L lab pipe-pane -o -t lab: 'cat >> /tmp/lab10/#{session_name}.log'; ls /tmp/lab10
   tmux -L lab pipe-pane -t lab:; tmux -L lab display -p -t lab: '#{pane_pipe}'
   ```
   ```
   lab.log
   manual.log
   0
   ```
   `#{session_name}` se convirtió en `lab`. `pipe-pane` sin comando cierra
   siempre.

6. **TODO 1 — validar el panel.** Primero, tal cual:
   ```bash
   ./starter/pane-log.sh; echo $?
   ./starter/pane-log.sh %99; echo $?
   ```
   ```
   uso: pane-log.sh PANE
   2
   pane-log: sin implementar (/tmp/lab10/logs/--.log)
   0
   ```
   `display -p -t %99` no falló: devolvió campos vacíos (`--.log`). Quita el
   `#   ` de la línea `tmx list-panes -t "$pane" ...`:
   ```bash
   ./starter/pane-log.sh %99; echo $?
   ```
   ```
   pane-log: no existe el panel '%99'
   1
   ```

7. **TODO 2 — el pipe con la ruta citada.** Cambia la línea
   `echo "pane-log: sin implementar ($file)"` por las dos del comentario:
   `printf '%q'` cita para `sh` y `${quoted//#/##}` dobla los `#` para tmux.
   ```bash
   ./starter/pane-log.sh %0; echo $?; tmux -L lab display -p -t %0 '#{pane_pipe}'
   ```
   ```
   0
   1
   ```
   Ahora con una sesión de nombre hostil (espacio y `;`):
   ```bash
   tmux -L lab new -d -s 'a b;c'; pane=$(tmux -L lab list-panes -t '=a b;c' -F '#{pane_id}'); echo "$pane"
   ./starter/pane-log.sh "$pane"; tmux -L lab send-keys -t "$pane" "echo hola-hostil" Enter; sleep 1
   ls /tmp/lab10/logs; grep -a -c hola-hostil "/tmp/lab10/logs/a b;c-0-0.log"; ls /tmp/lab10
   ```
   Algo como (cambia el `%`):
   ```
   %3
   a b;c-0-0.log
   lab-0-0.log
   2
   lab.log
   logs
   manual.log
   ```
   Un solo archivo con el nombre entero. Sin `%q`, `sh` habría cortado en el
   `;` y habría intentado ejecutar `c-0-0.log`.

8. **TODO 3 — informar del estado.** Quita el `#   ` de las cinco líneas
   `if [[ ... ]]` … `fi`. Llama tres veces (el `%0` estaba abierto y el de
   `a b;c` también):
   ```bash
   ./starter/pane-log.sh %0; ./starter/pane-log.sh %0; ./starter/pane-log.sh "$pane"
   ```
   ```
   log off: /tmp/lab10/logs/lab-0-0.log
   log on: /tmp/lab10/logs/lab-0-0.log
   log off: /tmp/lab10/logs/a b;c-0-0.log
   ```

9. **TODO 5 — `prefix` `H`.** Quita el `#   ` de la línea
   `bind H run-shell ...` y recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix H
   ```
   ```
   bind-key -T prefix H run-shell "#{q:@lab-dir}/pane-log.sh #{pane_id}"
   ```
   En B pulsa `C-b` `H`: el modo vista muestra
   `log off: /tmp/lab10/logs/lab-0-0.log` (estaba abierto desde el paso 8);
   `q`. Escribe `echo desde-B` y `Enter`. Pulsa `C-b` `H` otra vez:
   `log on: ...`; `q`. En A:
   ```bash
   tmux -L lab display -p -t %0 '#{pane_pipe}'; grep -a -c desde-B /tmp/lab10/logs/lab-0-0.log
   ```
   ```
   1
   0
   ```
   `desde-B` no está en el log: lo escribiste con el log cerrado.

10. **Limpia** (terminal A):
    ```bash
    tmux -L lab kill-server
    rm -rf /tmp/lab10
    ```
    B imprime `[server exited]`.

## Criterios de éxito

- [ ] Explicas adónde va la salida de `run-shell` y cómo sales de ese modo (paso 1)
- [ ] Con el TODO 4, `C-b` `b` y `C-b` `c` crean la ventana al instante (paso 3)
- [ ] `./starter/pane-log.sh %99; echo $?` imprime el error y `1` (paso 6)
- [ ] Con la sesión `a b;c`, `ls /tmp/lab10/logs` muestra `a b;c-0-0.log` y nada más de esa sesión (paso 7)
- [ ] Dos llamadas seguidas con `%0` imprimen `log off` y `log on` (paso 8)
- [ ] `C-b` `H` alterna el log del panel activo (paso 9)

## Reto extra

El modo vista tras cada `C-b` `H` estorba. Haz que el script, cuando se
llama desde el binding, avise con `tmx display-message -d 2000 "..."` en la
barra en lugar de `echo`. ¿Qué pasa si metes `$file` en el mensaje y la
sesión se llama `x#{pane_id}`? Pista: el mensaje de `display-message`
también es un format.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Menús y prompts](../lab-03-menus-y-prompts/README.md) | [Lab 05 — fzf en un popup](../lab-05-fzf-en-un-popup/README.md) → |

[↑ Semana 10](../../README.md)
