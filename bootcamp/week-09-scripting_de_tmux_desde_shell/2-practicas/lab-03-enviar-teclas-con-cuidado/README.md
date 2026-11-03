# Lab 03 — Enviar teclas con cuidado

⏱ Duración estimada: ~60 min

## Objetivo

Escribir en la shell de un panel desde un script sin que un dato externo se ejecute como código, sin que un texto se lea como teclas y sin escribir en un programa que no es la shell.

## Contexto

- `send-keys` **teclea**: lo que mandas lo interpreta la shell del panel como si lo escribieras tú. Un nombre de archivo con `;` o `$(...)` se ejecuta.
- Sin `-l`, un argumento que es exactamente un nombre de tecla (`Enter`, `C-c`) es esa tecla, y los argumentos se pegan sin espacio entre ellos. Con `-l`, todo es texto.
- Si el panel ejecuta otro programa, las teclas le llegan a él. Un comando inicial (`new-window 'cmd'`) no deja shell: al terminar, el panel se cierra.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-03-enviar-teclas-con-cuidado
   ```
   Arranca el servidor `-L lab` como dice [Antes de cada lab](../README.md#antes-de-cada-lab)
   (paso 3).

1. **Un log y un nombre hostil.** Un archivo que se llama
   `viejo;touch PWNED` es un nombre válido:
   ```bash
   mkdir -p /tmp/lab09/logs; printf 'linea %s\n' 1 2 3 4 > /tmp/lab09/logs/app.log; touch '/tmp/lab09/logs/viejo;touch PWNED'; ls /tmp/lab09/logs
   tmux -L lab new-session -d -s api -c /tmp/lab09 -x 80 -y 20 -P -F '#{pane_id}'
   ```
   ```
   app.log
   viejo;touch PWNED
   %0
   ```
   Para ver el panel sin conectarte, `capture-pane -p` imprime su pantalla.
   El prompt de tus salidas será otro.

2. **Varias teclas en un comando:**
   ```bash
   tmux -L lab send-keys -t api 'clear' Enter 'echo uno' Enter 'echo dos' Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 4
   ```
   Algo como:
   ```
   uno
   alumno@bc-tmux-lab:/tmp/lab09$ echo dos
   dos
   alumno@bc-tmux-lab:/tmp/lab09$
   ```

3. **Sin comillas, las palabras se pegan:**
   ```bash
   cmd='echo todo verde'; tmux -L lab send-keys -t api $cmd Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 2
   ```
   ```
   -bash: echotodoverde: command not found
   alumno@bc-tmux-lab:/tmp/lab09$
   ```
   Tres argumentos (`echo`, `todo`, `verde`) tecleados uno tras otro.

4. **`-l`: todo es texto.** `C-c` y `Enter` dentro del texto llegan como
   letras; el `Enter` que ejecuta va aparte, sin `-l`:
   ```bash
   tmux -L lab send-keys -t api -l 'echo "hola; $HOME" C-c Enter'; tmux -L lab send-keys -t api Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 2
   ```
   Algo como (cambia tu `$HOME`):
   ```
   hola; /home/alumno C-c Enter
   alumno@bc-tmux-lab:/tmp/lab09$
   ```
   `$HOME` lo expandió la shell del panel: `-l` evita que tmux lea teclas,
   no que la shell interprete lo que recibe.

5. **La inyección.** El nombre hostil, tecleado tal cual:
   ```bash
   f='/tmp/lab09/logs/viejo;touch PWNED'; tmux -L lab send-keys -t api "tail -n 3 $f" Enter
   sleep 0.5; ls /tmp/lab09
   ```
   ```
   PWNED
   logs
   ```
   La shell del panel ejecutó `tail -n 3 /tmp/lab09/logs/viejo` y luego
   `touch PWNED`. Con `printf %q` el nombre va escapado y la shell lo ve
   como un solo argumento:
   ```bash
   rm /tmp/lab09/PWNED; printf 'tail -n 3 -- %q\n' "$f"
   ```
   ```
   tail -n 3 -- /tmp/lab09/logs/viejo\;touch\ PWNED
   ```

6. **Un panel ocupado.** Con `sleep` en marcha, lo que mandes lo recibe
   `sleep` (y la shell lo ejecuta cuando `sleep` termine):
   ```bash
   tmux -L lab send-keys -t api 'sleep 300' Enter; sleep 0.5; tmux -L lab display -p -t api '#{pane_current_command}'
   tmux -L lab send-keys -t api C-c; sleep 0.5; tmux -L lab display -p -t api '#{pane_current_command}'
   ```
   ```
   sleep
   bash
   ```
   Si el programa no atiende a `C-c`, `respawn-pane -k` mata lo que haya y
   arranca una shell nueva en el mismo panel (mismo id):
   ```bash
   tmux -L lab send-keys -t api 'sleep 300' Enter; sleep 0.5; tmux -L lab respawn-pane -k -t api; sleep 0.5; tmux -L lab display -p -t api '#{pane_id} #{pane_current_command}'
   ```
   ```
   %0 bash
   ```

7. **Comando inicial y `remain-on-exit`.** Una ventana con comando propio
   desaparece al terminar, salida incluida:
   ```bash
   tmux -L lab new-window -d -t api: -n once 'tail -n 2 /tmp/lab09/logs/app.log; exit 3'; sleep 0.5; tmux -L lab list-windows -t =api -F '#{window_name}'
   ```
   ```
   bash
   ```
   Con `remain-on-exit on` el panel queda muerto, con su salida y su código:
   ```bash
   tmux -L lab set -g remain-on-exit on; tmux -L lab new-window -d -t api: -n once 'tail -n 2 /tmp/lab09/logs/app.log; exit 3'
   sleep 0.5; tmux -L lab display -p -t api:once '#{pane_dead} #{pane_dead_status}'
   tmux -L lab capture-pane -p -S - -t api:once | grep -v '^$'
   ```
   Algo como (cambia la fecha):
   ```
   1 3
   linea 3
   linea 4
   Pane is dead (status 3, Tue Nov  3 03:24:29 2026)
   ```
   `-S -` incluye el historial: la primera línea de un panel recién creado
   puede haber subido ya a él (`#{history_size}` vale 1) y sin `-S -` no
   saldría. `respawn-pane -t api:once` (sin `-k`: el panel ya está muerto) vuelve a
   ejecutar el mismo comando. Recoge:
   ```bash
   tmux -L lab kill-window -t api:once; tmux -L lab set -g remain-on-exit off; tmux -L lab send-keys -t api clear Enter
   ```
   ```
   (sin salida)
   ```

8. **Completa `starter/show-log`.** Tal como viene, funciona con un nombre
   normal y ejecuta el hostil:
   ```bash
   ./starter/show-log api /tmp/lab09/logs/app.log; echo $?
   ./starter/show-log api '/tmp/lab09/logs/viejo;touch PWNED'; sleep 0.5; ls /tmp/lab09; rm -f /tmp/lab09/PWNED
   ```
   ```
   0
   PWNED
   logs
   ```

   1. **TODO 1 — validar el target.** Descomenta
      `tmx list-panes -t "$target" -F '#{pane_id}' >/dev/null 2>&1 || die "no existe el target '$target'"`.
      ```bash
      ./starter/show-log nada /tmp/lab09/logs/app.log; echo $?
      ```
      ```
      show-log: no existe el target 'nada'
      1
      ```
      Antes salía `can't find pane: nada`: falla igual, pero el mensaje
      ahora es tuyo y se comprueba antes de teclear nada.
   2. **TODO 2 — panel ocupado.** Lee
      `command=$(tmx display -p -t "$target" '#{pane_current_command}')` y
      con un `case "$command" in bash | zsh | sh | dash | fish) ;; *) die "..." ;; esac`
      sal con el mensaje del TODO.
      ```bash
      tmux -L lab send-keys -t api 'sleep 300' Enter; sleep 0.5; ./starter/show-log api /tmp/lab09/logs/app.log; echo $?
      tmux -L lab send-keys -t api C-c clear Enter
      ```
      ```
      show-log: el panel 'api' está ocupado con 'sleep' (prueba: respawn-pane -k -t 'api')
      1
      ```
   3. **TODO 3 — escapar.** Cambia `line="tail -n 3 $file"` por
      `printf -v line 'tail -n 3 -- %q' "$file"`. `--` impide que un nombre
      que empiece por `-` se lea como opción de `tail`.
   4. **TODO 4 — literal y Enter aparte.** Cambia la última línea por
      `tmx send-keys -t "$target" -l -- "$line"` y
      `tmx send-keys -t "$target" Enter`. Prueba los TODOs 3 y 4 juntos:
      ```bash
      ./starter/show-log api '/tmp/lab09/logs/viejo;touch PWNED'; echo $?; sleep 0.5; ls /tmp/lab09
      tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 2
      ```
      Algo como:
      ```
      0
      logs
      alumno@bc-tmux-lab:/tmp/lab09$ tail -n 3 -- /tmp/lab09/logs/viejo\;touch\ PWNED
      alumno@bc-tmux-lab:/tmp/lab09$
      ```
      Sin `PWNED`, y `tail` no imprime nada porque el archivo está vacío.
      Una ruta relativa también vale: el script la hace absoluta, porque
      la shell del panel está en `/tmp/lab09`:
      ```bash
      (cd /tmp/lab09/logs && "$OLDPWD/starter/show-log" api app.log); echo $?
      sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 4
      ```
      Algo como:
      ```
      0
      linea 2
      linea 3
      linea 4
      alumno@bc-tmux-lab:/tmp/lab09$
      ```

9. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `send-keys -t api $cmd Enter` teclea `echotodoverde` (paso 3)
- [ ] Explicas qué evita `-l` y qué no evita (paso 4)
- [ ] Con tu `show-log`, el archivo `viejo;touch PWNED` no crea `/tmp/lab09/PWNED` (paso 8.4)
- [ ] `show-log nada ...` sale con 1 y `show-log` sobre un panel con `sleep` dice que está ocupado (pasos 8.1 y 8.2)
- [ ] Explicas la diferencia entre `send-keys` a una shell y un comando inicial, y para qué sirve `remain-on-exit` (paso 7)

## Reto extra

`printf %q` escapa para bash. Crea un archivo con un salto de línea en el
nombre (`touch $'/tmp/lab09/logs/dos\nlineas'`), mira qué produce `%q` y
comprueba si tu `show-log` funciona también con un panel cuya shell sea
`sh` (`tmux -L lab new-window -d -t api: -n sh sh`). ¿Por qué falla, y qué
cambiarías?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — Consultar con formatos](../lab-02-consultar-con-formatos/README.md) | [Lab 04 — Esperar con wait-for](../lab-04-esperar-con-wait-for/README.md) → |

[↑ Semana 09](../../README.md)
