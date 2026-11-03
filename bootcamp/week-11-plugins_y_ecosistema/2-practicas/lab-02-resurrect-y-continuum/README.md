# Lab 02 — resurrect y continuum

⏱ Duración estimada: ~60 min

## Objetivo

Guardar una sesión de tres ventanas con tmux-resurrect, restaurarla tras matar el servidor y dejar que tmux-continuum la guarde y la restaure sola.

## Contexto

- resurrect guarda en un archivo de texto las sesiones, ventanas, paneles, directorios y layouts; con `@resurrect-capture-pane-contents on`, también lo que se veía. Programas solo restaura los de una lista (`top`, `less`, `tail`, `vim`...); el resto vuelve como shell.
- continuum no guarda nada por sí mismo: llama al `save.sh` de resurrect desde un `#(...)` que pone delante de `status-right`. Sin barra o sin ningún cliente conectado, no hay guardado.
- Este lab carga los dos plugins con `run-shell`, sin TPM: es exactamente lo que TPM hace por ti.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` vacío), las
   dos desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-02-resurrect-y-continuum
   ```
   En la **terminal A**, el HOME aislado del lab (como en el lab 01,
   `home/.config/tmux` es `starter/`) y el servidor `-L lab`:
   ```bash
   mkdir -p home/.config && ln -s ../../starter home/.config/tmux
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   La terminal B solo hace falta en el paso 7.

1. **Clona los dos plugins fijados** (terminal A):
   ```bash
   for p in tmux-resurrect:v4.0.0 tmux-continuum:v3.1.0; do
     git -c advice.detachedHead=false clone -q --depth 1 --branch "${p#*:}" "https://github.com/tmux-plugins/${p%:*}" "starter/plugins/${p%:*}"
   done; echo $?
   ls starter/plugins
   ```
   ```
   0
   tmux-continuum
   tmux-resurrect
   ```

2. **TODO 1 y TODO 2 — carga resurrect.** En `starter/tmux.conf` quita el
   `#   ` de las dos líneas `set -g @resurrect-...` (TODO 1) y de la línea
   `run-shell` de resurrect (TODO 2). Recarga:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T prefix | grep -c resurrect
   tmux -L lab show -gv @resurrect-dir
   ```
   ```
   0
   2
   ~/.local/share/tmux/resurrect
   ```
   Dos teclas (`prefix` `C-s` guarda, `prefix` `C-r` restaura). La `~`
   sigue sin expandir: entre comillas simples tmux la deja tal cual y la
   cambia resurrect, con el HOME del servidor (`home/` del lab).

3. **Una sesión que merezca guardarse.** Tres ventanas en directorios
   distintos; en dos de ellas arrancas un programa desde la shell:
   ```bash
   tmux -L lab new -d -s trabajo -n editor -c /tmp
   tmux -L lab new-window -d -t trabajo: -n logs -c /var/log
   tmux -L lab new-window -d -t trabajo: -n run -c /etc
   tmux -L lab send-keys -t trabajo:editor 'echo hola desde editor' Enter
   tmux -L lab send-keys -t trabajo:logs top Enter
   tmux -L lab send-keys -t trabajo:run 'sleep 600' Enter
   sleep 1; tmux -L lab list-windows -t trabajo -F '#{window_index}:#{window_name} #{pane_current_command} #{pane_current_path}'
   ```
   ```
   1:editor bash /tmp
   2:logs top /var/log
   3:run sleep /etc
   ```
   `send-keys` y no `new-window ... top`: resurrect busca el programa como
   hijo de la shell del panel. Un programa lanzado como comando de la
   ventana no tiene shell debajo y no se restaura.

4. **Guarda sin teclado.** `prefix` `C-s` ejecuta este script; desde
   terminal A lo lanzas con `run-shell`:
   ```bash
   tmux -L lab run-shell "$PWD/starter/plugins/tmux-resurrect/scripts/save.sh"; echo $?
   ls home/.local/share/tmux/resurrect
   grep '^pane' home/.local/share/tmux/resurrect/last | cut -f2,3,6,8,10,11
   ```
   Algo como (cambian la fecha del archivo y la ruta del lab):
   ```
   0
   last  pane_contents.tar.gz  save  tmux_resurrect_20261103T200426.txt
   lab	1	0	:/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-02-resurrect-y-continuum	bash	:
   trabajo	1	0	:/tmp	bash	:
   trabajo	2	0	:/var/log	top	:top
   trabajo	3	0	:/etc	sleep	:sleep 600
   ```
   `last` es un enlace al guardado más reciente; cada línea `pane` es
   sesión, ventana, panel, directorio, programa y línea de comandos.

5. **Mata el servidor y restaura:**
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab ls -F '#{session_name}'
   tmux -L lab run-shell "$PWD/starter/plugins/tmux-resurrect/scripts/restore.sh"; echo $?
   sleep 2; tmux -L lab list-windows -t trabajo -F '#{window_index}:#{window_name} #{pane_current_command} #{pane_current_path}'
   tmux -L lab capture-pane -p -t trabajo:editor | grep -v '^$' | head -2
   ```
   Algo como (el prompt depende de tu usuario y máquina):
   ```
   lab
   0
   1:editor bash /tmp
   2:logs top /var/log
   3:run bash /etc
   alumno@bc-tmux-lab:/tmp$ echo hola desde editor
   hola desde editor
   ```
   Vuelven nombres, directorios, `top` (está en la lista) y el texto del
   panel. `sleep 600` no: en su lugar hay una shell en `/etc`. Si un
   programa tuyo no vuelve, mira `@resurrect-processes` en el README del
   plugin.

6. **TODO 3 — continuum.** Quita el `#   ` de las tres líneas del TODO 3.
   continuum restaura al arrancar el servidor, así que reinicia:
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   sleep 2; tmux -L lab ls -F '#{session_name} #{session_windows}'
   tmux -L lab show -gv status-right
   ```
   Algo como:
   ```
   duplicate session: lab
   1
   lab 1
   trabajo 3
   #(/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-02-resurrect-y-continuum/home/.config/tmux/plugins/tmux-continuum/scripts/continuum_save.sh)#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}"#{=21:pane_title}" %H:%M %d-%b-%y
   ```
   `duplicate session: lab` es la prueba de que restauró: al leer la config
   no había sesiones, continuum restauró `lab` y `trabajo`, y luego
   `new -s lab` encontró la suya ocupada. `status-right` empieza por el
   `#(...)` que guarda.

   Si `status-right` **no** empieza por `#(`, hay otro servidor de tmux en
   marcha (tu tmux de siempre, otro `-L`): continuum solo activa el
   autoguardado si es el único. En el laboratorio Docker no pasa.

7. **El autoguardado necesita un cliente.** Mira qué guardado es el último
   (terminal A):
   ```bash
   readlink home/.local/share/tmux/resurrect/last
   ```
   ```
   tmux_resurrect_20261103T200426.txt
   ```
   En la **terminal B**, desde la carpeta del lab, conéctate:
   ```bash
   tmux -L lab attach -t lab
   ```
   Espera un poco más de un minuto (`@continuum-save-interval 1`) y repite
   el `readlink` en A:
   ```
   tmux_resurrect_20261103T200541.txt
   ```
   Cambió sin que pulsaras nada: la barra de B ejecutó `continuum_save.sh`.
   Sal de B con `C-b` `d` (el starter no cambia el prefix); B imprime
   `[detached (from session lab)]`.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf home starter/plugins
   ```
   ```
   (sin salida)
   ```
   `rm -rf home` borra también los guardados del lab.

## Criterios de éxito

- [ ] `grep '^pane' home/.local/share/tmux/resurrect/last` muestra las tres ventanas de `trabajo` con sus directorios (paso 4)
- [ ] Tras `kill-server` y `restore.sh`, `list-windows -t trabajo` muestra `editor`, `logs` con `top` y `run` (paso 5)
- [ ] Explicas por qué `sleep 600` no vuelve y `top` sí (pasos 3 y 5)
- [ ] Con continuum, un servidor nuevo arranca con `trabajo` sin ejecutar `restore.sh` (paso 6)
- [ ] `readlink .../last` cambia solo con un cliente conectado durante más de un minuto (paso 7)

## Reto extra

Añade `set -g @resurrect-processes 'sleep'` encima del `run-shell` de
resurrect, recarga, guarda y restaura otra vez. ¿Vuelve `sleep 600`? Lee en
el README de tmux-resurrect qué hace una `~` delante del nombre y por
qué restaurar cualquier programa (`:all:`) puede ser peligroso.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — TPM desde cero](../lab-01-tpm-desde-cero/README.md) | [Lab 03 — Anatomía de un plugin](../lab-03-anatomia-de-un-plugin/README.md) → |

[↑ Semana 11](../../README.md)
