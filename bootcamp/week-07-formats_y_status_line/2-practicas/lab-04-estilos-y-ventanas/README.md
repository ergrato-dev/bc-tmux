# Lab 04 — Estilos y lista de ventanas

⏱ Duración estimada: ~60 min

## Objetivo

Dar color a la barra con opciones `*-style` y estilos en línea `#[...]`, y controlar cómo se dibuja cada ventana de la lista, con una paleta que se cambia en un solo sitio.

## Contexto

- Las opciones `*-style` (`status-style`, `window-status-style`, `window-status-current-style`, `message-style`, `pane-active-border-style`) dan el estilo de una zona entera. Aceptan formats y se expanden al dibujar: un color puede salir de una opción de usuario.
- Dentro de un format, `#[fg=...,bg=...,bold]` cambia el estilo desde ese punto y `#[default]` vuelve al de la zona. `display -p` no dibuja estilos: imprime el texto `#[...]` tal cual.
- `window-status-format` y `window-status-current-format` dicen qué texto lleva cada ventana (la actual usa la segunda). `#{W:fmt}` recorre las ventanas dentro de un solo format.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-04-estilos-y-ventanas
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**. Los colores usan la paleta de 256 (`colour235`...): tu
   terminal tiene que mostrarlos (`tput colors` imprime `256`).

1. **Lo que valida tmux y lo que no** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api -n editor
   tmux -L lab show -gv status-style
   tmux -L lab show -gv window-status-current-style
   tmux -L lab set -g status-style 'bg=nocolor'; echo $?
   tmux -L lab set -g window-status-curent-format x; echo $?
   tmux -L lab set -g @lab-bg nocolor; tmux -L lab set -g status-style 'bg=#{@lab-bg}'; echo $?
   tmux -L lab kill-server
   ```
   ```
   bg=green,fg=black
   default
   invalid style: bg=nocolor
   1
   invalid option: window-status-curent-format
   1
   0
   ```
   Un estilo escrito a mano se valida al hacer `set`. Uno que sale de un
   format no: el error solo se nota al dibujar (la barra sin color). Por eso
   la paleta se prueba con `display -p '#{E:status-style}'`.

2. **Arranca con el starter** y una segunda ventana (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api -n editor
   tmux -L lab new-window -d -n logs
   ```
   ```
   (sin salida)
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   La barra por defecto: verde con texto negro, algo como
   `[api] 0:editor* 1:logs   "bc-tmux-lab" 02:00 03-Nov-26`. Deja la B
   conectada.

3. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"` (sin salida) y mira
   la B.

   1. **TODO 1: la barra entera.** Pista:
      `set -g status-style 'fg=#{@lab-fg},bg=#{@lab-bg}'`.
      ```bash
      tmux -L lab show -gv status-style
      tmux -L lab display -p '#{E:status-style}'
      ```
      ```
      fg=#{@lab-fg},bg=#{@lab-bg}
      fg=colour250,bg=colour235
      ```
      La B pasa a fondo gris oscuro y texto gris claro. Cambia un color en
      caliente, sin recargar:
      ```bash
      tmux -L lab set -g @lab-bg colour52
      ```
      ```
      (sin salida)
      ```
      La barra se vuelve granate. Devuélvela con
      `tmux -L lab set -g @lab-bg colour235`.
   2. **TODO 2: la ventana actual.** Pista:
      `set -g window-status-style 'fg=colour245'` y
      `set -g window-status-current-style 'fg=#{@lab-bg},bg=#{@lab-accent},bold'`.
      ```bash
      tmux -L lab show -gv window-status-current-style
      ```
      ```
      fg=#{@lab-bg},bg=#{@lab-accent},bold
      ```
      En la B, `0:editor*` sale en verde con letra oscura y negrita; pulsa
      `C-b` `n` y el verde salta a `1:logs`. `C-b` `p` para volver.
   3. **TODO 3: el texto de cada ventana.** Pista:
      `set -g window-status-format ' #I:#W '`, lo mismo en
      `window-status-current-format`, y `set -g window-status-separator ''`.
      ```bash
      tmux -L lab display -p '[#{E:window-status-format}]'
      ```
      ```
      [ 0:editor ]
      ```
      El `*` desaparece (era `#{window_flags}` del format por defecto): ahora
      la actual se distingue por el color. Sin separador, los bloques de
      color se tocan.
   4. **TODO 4: la sesión con estilo en línea.** Pista:
      `set -g status-left '#[fg=#{@lab-bg},bg=#{@lab-accent},bold] #S #[default] '`.
      ```bash
      tmux -L lab display -p '#{E:status-left}'
      ```
      ```
      #[fg=colour235,bg=colour71,bold] api #[default] 
      ```
      `E:` resuelve los colores pero deja los `#[...]`: los dibuja la barra.
      En la B, ` api ` en verde y un espacio con el fondo de la barra
      detrás: eso es el `#[default]`.
   5. **TODO 5: bucle sobre las ventanas.** Pista:
      `set -g status-right '#[fg=#{@lab-warn}]#{W:#{?window_zoomed_flag,Z#{window_index} ,}}#[default]%H:%M '`.
      Primero el bucle solo:
      ```bash
      tmux -L lab display -p '#{W:#{window_index}:#{window_name} }'
      tmux -L lab display -p '#{W:#{window_name} ,[#{window_name}] }'
      ```
      ```
      0:editor 1:logs 
      [editor] logs 
      ```
      El segundo argumento de `W:` es el format de la ventana actual. Ahora
      amplía un panel de la ventana 1, que no es la que ves:
      ```bash
      tmux -L lab split-window -t api:1
      tmux -L lab resize-pane -Z -t api:1
      tmux -L lab display -p '#{E:status-right}'
      ```
      Algo como (la hora es la tuya):
      ```
      #[fg=colour179]Z1 #[default]02:00 
      ```
      La B tarda hasta 15 s en mostrar `Z1` en amarillo: un cambio en otra
      ventana no redibuja la barra. Para no esperar:
      ```bash
      tmux -L lab refresh-client -S
      ```
      ```
      (sin salida)
      ```
      Quita el zoom: `tmux -L lab resize-pane -Z -t api:1`.
   6. **TODO 6: mensajes y bordes.** Pista:
      `set -g message-style 'fg=#{@lab-bg},bg=#{@lab-warn}'` y
      `set -g pane-active-border-style 'fg=#{@lab-accent}'`.
      ```bash
      tmux -L lab display 'hola'
      ```
      ```
      (sin salida)
      ```
      Sin `-p`, el mensaje sale en la barra de la B, en amarillo, unos
      segundos. En la B, `C-b` `n` para ir a `1:logs` (dos paneles): el
      borde del panel activo es verde.

4. **Centrar la lista.** En la terminal A:
   ```bash
   tmux -L lab set -g status-justify centre
   ```
   ```
   (sin salida)
   ```
   La lista de ventanas de la B se va al centro; `left` la devuelve.

5. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   Comprueba que no hay zoom (`tmux -L lab display -p '#{W:#{window_zoomed_flag}}'`
   imprime `00`) y en la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `set -g status-style 'bg=nocolor'` falla y `'bg=#{@lab-bg}'` con `@lab-bg nocolor` no (paso 1)
- [ ] `tmux -L lab display -p '#{E:status-style}'` imprime `fg=colour250,bg=colour235` (paso 3.1)
- [ ] `tmux -L lab set -g @lab-bg colour52` cambia el fondo de la B sin recargar (paso 3.1)
- [ ] `tmux -L lab display -p '[#{E:window-status-format}]'` imprime `[ 0:editor ]` y la ventana actual se distingue por el color (pasos 3.2 y 3.3)
- [ ] Con zoom en la ventana 1, `display -p '#{E:status-right}'` contiene `Z1` (paso 3.5)
- [ ] `tmux -L lab display 'hola'` sale en amarillo en la B (paso 3.6)

## Reto extra

Haz que la ventana con actividad reciente se vea distinta sin tocar los
formats: `setw -g monitor-activity on` y `set -g window-status-activity-style 'fg=#{@lab-warn},bold'`.
Escribe algo en la otra ventana con `tmux -L lab send-keys -t api:1 'echo hola' Enter`
y mira la B.
