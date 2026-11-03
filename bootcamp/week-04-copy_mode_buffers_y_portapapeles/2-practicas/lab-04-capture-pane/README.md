# Lab 04 — capture-pane

⏱ Duración estimada: ~60 min

## Objetivo

Volcar el historial de un panel a stdout, a un archivo o a un buffer con `capture-pane`, eligiendo el rango de líneas, sin entrar en copy mode.

## Contexto

- `capture-pane -p` imprime lo que muestra un panel. Sin más opciones, solo la parte **visible**, con las líneas vacías del final incluidas.
- `-S` y `-E` eligen el rango: `0` es la primera línea visible, los negativos van hacia el historial y `-` significa "el principio" (en `-S`) o "el final" (en `-E`).
- Sirve para lo que copy mode no hace: buscar con `grep` en la salida de otro panel, guardar un log que no escribiste en un archivo o pasarlo a otro programa.

## Instrucciones

0. Todo el lab se hace desde **una terminal fuera de tmux** (`echo "$TMUX"`
   imprime una línea vacía): la sesión del lab no tiene cliente y la manejas
   desde fuera. Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-04-capture-pane
   ```
   Servidor aparte: `-L lab`. No te conectes a la sesión: un cliente cambiaría
   el tamaño de la ventana y las salidas dejarían de coincidir.

1. Prepara una sesión con un panel de "logs":
   ```bash
   tmux -L lab -f /dev/null new -d -s logs -x 80 -y 20
   tmux -L lab split-window -d -t logs:0
   tmux -L lab send -t logs:0.1 'for i in $(seq 1 300); do echo "info: peticion $i"; done; echo "ERROR: disco lleno"' Enter
   tmux -L lab list-panes -t logs:0 -F '#{pane_index} #{pane_height}'
   ```
   ```
   0 10
   1 9
   ```
   `-x` y `-y` fijan el tamaño de una sesión sin cliente: 20 filas menos la
   barra de estado y el borde dan 10 + 9.

2. **Solo lo visible.**
   ```bash
   tmux -L lab capture-pane -p -t logs:0.1
   tmux -L lab capture-pane -p -t logs:0.1 | wc -l
   ```
   Algo como (las últimas líneas son tu prompt, que puede ocupar una o dos):
   ```
   info: peticion 295
   info: peticion 296
   info: peticion 297
   info: peticion 298
   info: peticion 299
   info: peticion 300
   ERROR: disco lleno
   alumno@bc-tmux-lab:/bc-tmux/bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-
   practicas/lab-04-capture-pane$
   9
   ```
   `9`: la altura del panel, ni una línea más.

3. **El historial.** Busca el error desde fuera del panel:
   ```bash
   tmux -L lab capture-pane -p -S - -t logs:0.1 | grep -n '^ERROR'
   tmux -L lab capture-pane -p -S -20 -E -10 -t logs:0.1
   tmux -L lab capture-pane -p -S -20 -E -10 -t logs:0.1 | wc -l
   ```
   Algo como:
   ```
   306:ERROR: disco lleno
   info: peticion 275
   ...
   info: peticion 285
   11
   ```
   El número de línea y el primer `info` dependen de cuántas líneas ocupe tu
   prompt; `11` no: de la línea -20 a la -10, las dos incluidas.

4. **A un buffer y a un archivo.** Sin `-p`, el resultado va a un buffer:
   ```bash
   tmux -L lab capture-pane -S - -b log -t logs:0.1
   tmux -L lab save-buffer -b log /tmp/log.txt
   grep -c '^info' /tmp/log.txt
   grep '^ERROR' /tmp/log.txt
   ```
   ```
   300
   ERROR: disco lleno
   ```

5. **Líneas partidas.** Imprime una línea más ancha que el panel (200 `x`
   en un panel de 80 columnas):
   ```bash
   tmux -L lab send -t logs:0.1 'clear; printf "%0.sx" {1..200}; echo' Enter
   tmux -L lab capture-pane -p -t logs:0.1 | grep -c '^xxx'
   tmux -L lab capture-pane -p -J -t logs:0.1 | grep -c '^xxx'
   ```
   ```
   3
   1
   ```
   Sin `-J`, la línea sale partida en tres (80 + 80 + 40), y un `grep` que
   busca algo cerca del corte no lo encuentra. `-J` la une. (El patrón es
   `^xxx` y no `x` porque tu prompt también puede tener una `x`, como
   `bc-tmux-lab`.) Ojo: ese `clear` también borró el historial del panel
   (lab 01), por eso el paso 4 iba antes.

6. **Colores.** Por defecto, `capture-pane` quita los colores. Con `-e` los
   guarda como secuencias de escape:
   ```bash
   tmux -L lab send -t logs:0.1 'echo ERROR | grep --color=always ERROR' Enter
   tmux -L lab capture-pane -p -e -t logs:0.1 | cat -v | grep 'mERROR'
   ```
   ```
   ^[[1m^[[31mERROR^[[0m
   ```
   (`cat -v` escribe el carácter Escape como `^[`; los códigos pueden variar
   con tu `grep`.) Útil para `less -R`, molesto para `grep`.

7. **Validar el target.** Pide un panel que no existe:
   ```bash
   tmux -L lab display -p -t logs:0.9 '#{pane_index}'; echo $?
   tmux -L lab list-panes -t logs:0.9; echo $?
   ```
   ```
   0
   0
   can't find pane: 9
   1
   ```
   `display` no encuentra el panel 9, usa el panel activo de la ventana (el
   `0`) y sale con 0. Un script que capturara con lo que devuelve `display`
   guardaría el log equivocado sin enterarse. `list-panes -t` sí falla.

8. **El script** `starter/capturar.sh`: valida el target y vuelca todo el
   historial hasta la línea del cursor, sin las líneas vacías de debajo.
   Prepara el panel con algo corto y conocido:
   ```bash
   tmux -L lab send -t logs:0.1 'clear; tmux clear-history; seq 1 50' Enter
   ```
   ```
   (sin salida)
   ```
   (Dentro del panel, `tmux` sin `-L` habla con el servidor del panel: el
   del lab.)

   1. **TODO 1**: valida con `list-panes -t` (pista en el starter).
      ```bash
      ./starter/capturar.sh logs:0.9; echo $?
      ./starter/capturar.sh logs:0.1; echo $?
      ```
      ```
      capturar.sh: no existe el panel logs:0.9
      1
      capturar.sh: sin implementar (logs:0.1 stdout)
      1
      ```
      El segundo sigue "sin implementar": lo arreglan los TODOs 2 y 3.
   2. **TODO 2**: guarda en `fin` la línea del cursor con
      `display -p '#{cursor_y}'`. Mira qué valor tendrá:
      ```bash
      tmux -L lab display -p -t logs:0.1 '#{cursor_y}'
      ```
      ```
      8
      ```
      (Algo como `8`: la última fila del panel, donde está tu prompt; con un
      prompt de dos líneas, también.)
   3. **TODO 3**: borra las dos líneas `sin implementar`, captura con
      `-J -S - -E "$fin"` y, si hay archivo, cuenta las líneas con
      `wc -l <"$archivo"`.
      ```bash
      ./starter/capturar.sh logs:0.1 /tmp/cap.txt; echo $?
      tail -3 /tmp/cap.txt
      ```
      Algo como:
      ```
      capturadas 51 líneas en /tmp/cap.txt
      0
      49
      50
      alumno@bc-tmux-lab:/bc-tmux/bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-04-capture-pane$
      ```
      `51`: las 50 líneas de `seq` y el prompt, en una sola línea gracias a
      `-J`. Ni el comando (lo borró `clear`) ni las líneas vacías de debajo.
   4. Sin avisos de `shellcheck` (`sudo apt install shellcheck` o
      `brew install shellcheck`):
      ```bash
      shellcheck starter/capturar.sh; echo $?
      ```
      ```
      0
      ```

9. Limpia:
   ```bash
   tmux -L lab kill-server; rm -f /tmp/log.txt /tmp/cap.txt
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Paso 3: encuentras `ERROR` en el historial de otro panel con `capture-pane` y `grep`, sin entrar en él
- [ ] Paso 5: `grep -c '^xxx'` da `3` sin `-J` y `1` con `-J`, y explicas por qué
- [ ] Paso 8.3: `./starter/capturar.sh logs:0.1 /tmp/cap.txt` termina en la línea del prompt, sin líneas vacías debajo
- [ ] Paso 8.1: `./starter/capturar.sh logs:0.9` sale con 1 y avisa por stderr
- [ ] Paso 7: explicas por qué el script valida con `list-panes` y no con `display-message`
- [ ] Paso 8.4: `shellcheck starter/capturar.sh` no muestra avisos

## Reto extra

Añade la opción `-e` al script: `capturar.sh -e TARGET` guarda los colores.
Abre el resultado con `less -R` (sales con `q`).
