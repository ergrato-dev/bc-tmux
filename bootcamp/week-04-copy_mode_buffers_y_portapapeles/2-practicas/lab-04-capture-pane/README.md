# Lab 04 — capture-pane

⏱ Duración estimada: ~60 min

## Objetivo

Volcar el historial de un panel a stdout, a un archivo o a un buffer con `capture-pane`, eligiendo el rango de líneas, sin entrar en copy mode.

## Contexto

- `capture-pane -p` imprime lo que muestra un panel. Sin más opciones, solo la parte **visible**, con las líneas vacías del final incluidas.
- `-S` y `-E` eligen el rango: `0` es la primera línea visible, los negativos van hacia el historial y `-` significa "el principio" (en `-S`) o "el final" (en `-E`).
- Sirve para lo que copy mode no hace: buscar con `grep` en la salida de otro panel, guardar un log que no escribiste en un archivo o pasarlo a otro programa.

## Instrucciones

1. Prepara una sesión con un panel de "logs":
   ```bash
   tmux -L lab -f /dev/null new -d -s logs -x 80 -y 20
   tmux -L lab split-window -d -t logs:0
   tmux -L lab send -t logs:0.1 'for i in $(seq 1 300); do echo "info: peticion $i"; done; echo "ERROR: disco lleno"' Enter
   ```
   `-x` y `-y` fijan el tamaño de una sesión sin cliente; el panel 1 tiene
   9 líneas.

2. **Solo lo visible.**
   ```bash
   tmux -L lab capture-pane -p -t logs:0.1
   tmux -L lab capture-pane -p -t logs:0.1 | wc -l      # 9: la altura del panel
   ```

3. **El historial.** Busca el error desde fuera del panel:
   ```bash
   tmux -L lab capture-pane -p -S - -t logs:0.1 | grep -n '^ERROR'
   tmux -L lab capture-pane -p -S -20 -E -10 -t logs:0.1    # 11 líneas del historial
   ```
   El primer comando da algo como `302:ERROR: disco lleno`: el número
   depende de cuántas líneas tenga tu prompt.

4. **Líneas partidas.** Imprime una línea más ancha que el panel y compara:
   ```bash
   tmux -L lab send -t logs:0.1 'clear; printf "%0.sx" {1..200}; echo' Enter
   tmux -L lab capture-pane -p -t logs:0.1 | grep -c x        # 3: partida en tres
   tmux -L lab capture-pane -p -J -t logs:0.1 | grep -c x     # 1: -J la une
   ```
   Sin `-J`, un `grep` que busca algo cerca del corte no lo encuentra.

5. **Colores.** Por defecto, `capture-pane` quita los colores. Con `-e` los
   guarda como secuencias de escape:
   ```bash
   tmux -L lab send -t logs:0.1 'echo ERROR | grep --color=always ERROR' Enter
   tmux -L lab capture-pane -p -e -t logs:0.1 | cat -v | grep 'ERROR'
   ```
   Verás algo como `^[[1m^[[31mERROR^[[0m`. Útil para `less -R`, molesto para
   `grep`.

6. **A un buffer.** Sin `-p`, el resultado va a un buffer:
   ```bash
   tmux -L lab capture-pane -S - -b log -t logs:0.1
   tmux -L lab save-buffer -b log /tmp/log.txt
   ```

7. **Validar el target.** Pide un panel que no existe:
   ```bash
   tmux -L lab display -p -t logs:0.9 '#{pane_index}'; echo $?   # 0 y 0
   tmux -L lab list-panes -t logs:0.9; echo $?                   # can't find pane: 9, 1
   ```
   Un script que capturara con el panel que devuelve `display` guardaría el
   log equivocado.

8. Completa `starter/capturar.sh`: valida el target y vuelca todo el
   historial hasta la línea del cursor, sin las líneas vacías de debajo.
   ```bash
   tmux -L lab send -t logs:0.1 'clear; tmux clear-history; seq 1 50' Enter
   ./starter/capturar.sh logs:0.1 /tmp/cap.txt
   tail -3 /tmp/cap.txt
   ./starter/capturar.sh logs:0.9; echo $?
   ```
   ```
   capturadas 51 líneas en /tmp/cap.txt
   49
   50
   alumno@bc-tmux-lab:/bc-tmux$
   capturar.sh: no existe el panel logs:0.9
   1
   ```
   Las 50 líneas de `seq` y el prompt: ni el comando (lo borró `clear`) ni
   las líneas vacías de debajo.

9. Limpia: `tmux -L lab kill-server; rm -f /tmp/log.txt /tmp/cap.txt`.

## Criterios de éxito

- [ ] Encuentras `ERROR` en el historial de otro panel con `capture-pane` y `grep`, sin entrar en él
- [ ] Muestras con `grep -c` la diferencia entre capturar con y sin `-J`
- [ ] `./starter/capturar.sh logs:0.1` termina en la línea del prompt, sin líneas vacías debajo
- [ ] `./starter/capturar.sh logs:0.9` sale con 1 y avisa por stderr
- [ ] Explicas por qué el script valida con `list-panes` y no con `display-message`
- [ ] `shellcheck starter/capturar.sh` no muestra avisos

## Reto extra

Añade la opción `-e` al script: `capturar.sh -e TARGET` guarda los colores.
Abre el resultado con `less -R`.
