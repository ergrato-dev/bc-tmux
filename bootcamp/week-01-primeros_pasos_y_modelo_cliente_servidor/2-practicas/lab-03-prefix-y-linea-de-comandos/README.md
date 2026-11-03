# Lab 03 — El prefix y la línea de comandos

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar que cada atajo de tmux es un comando con nombre, y ejecutar esos mismos comandos desde el prompt de tmux y desde una shell fuera de él.

## Contexto

- El **prefix** avisa a tmux de que la siguiente tecla es para él y no para el programa del panel. El servidor del lab arranca con `-f /dev/null` (sin configuración), así que el prefix es el de fábrica: `C-b` (**Ctrl+b**, suelta, y la tecla).
- Cada combinación `C-b` + tecla está **ligada a un comando**: `d` a `detach-client`, `c` a `new-window`. Las ligaduras viven en la **tabla** `prefix`.
- Ese mismo comando lo puedes escribir en el prompt de tmux (`C-b` `:`) o como argumento de `tmux` desde cualquier shell. Las tres vías dan el mismo resultado.

Necesitas dos terminales: **A** (conectada a tmux) y **B** (fuera de tmux).

## Instrucciones

0. **Prepara las dos terminales.** En A y en B, fuera de tmux y desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-03-prefix-y-linea-de-comandos
   echo "$TMUX"
   ```
   `echo` imprime una línea vacía. Solo en B, borra restos de intentos
   anteriores:
   ```bash
   tmux -L lab kill-server
   ```
   Si no había servidor imprime `no server running on ...` o
   `error connecting to ...`: es normal.

1. **Terminal A.** Abre la sesión de trabajo:
   ```bash
   tmux -L lab -f /dev/null new -s atajos
   ```

2. **Terminal A, la lista de atajos.** Primero mira qué teclas usa tmux en
   sus listas:
   ```bash
   tmux -L lab show -gw mode-keys
   ```
   ```
   mode-keys emacs
   ```
   tmux elige `vi` en vez de `emacs` si al arrancar el servidor la variable
   `VISUAL` o `EDITOR` contenía `vi`. Ahora pulsa `C-b` `?`. Aparece la
   lista de atajos, una línea por tecla:
   ```
   C-b C-b     Send the prefix key
   C-b C-o     Rotate through the panes
   ...
   ```
   - Muévete con `↑`/`↓` o `PgUp`/`PgDn`.
   - Busca: con `emacs` pulsa `C-s`; con `vi`, `/`. Abajo aparece
     `(search down)`. Escribe `detach` y Enter: el cursor salta a
     `C-b D  Choose and detach a client from a list`. `n` va a la siguiente
     coincidencia, `C-b d  Detach the current client`.
   - Busca igual `new window` y `split`: `C-b c` crea ventana, `C-b %` y
     `C-b "` dividen el panel.
   - Sal con `q`.

3. **Terminal A, el prompt de comandos.** Pulsa `C-b` `:`. La status line se
   vuelve amarilla con un `:` al principio. Escribe y pulsa Enter:
   ```
   new-window -n desde-prompt
   ```
   La status line muestra `0:bash- 1:desde-prompt*`: una ventana nueva y
   activa. Repite con `C-b` `:` y:
   ```
   display-message "hola desde el prompt"
   ```
   El texto sustituye a la status line durante 750 ms (opción
   `display-time`) y desaparece. Si lo pierdes, repítelo mirando abajo.

4. **Terminal B, los mismos comandos desde fuera:**
   ```bash
   tmux -L lab new-window -t atajos: -n desde-fuera
   tmux -L lab display-message -p -t atajos '#{session_windows} ventanas'
   ```
   ```
   3 ventanas
   ```
   El primero no imprime nada, pero en la terminal A aparece y se activa
   `2:desde-fuera*`. Es el **mismo comando** que pulsar `C-b` `c`: los
   scripts del proyecto usan exactamente esta vía. `-p` hace que
   `display-message` imprima en tu terminal en vez de en la status line.

5. **Terminal B.** Pregunta qué comando hay detrás de una tecla:
   ```bash
   tmux -L lab list-keys -T prefix d
   tmux -L lab list-keys -T prefix %
   ```
   ```
   bind-key -T prefix d detach-client
   bind-key -T prefix \% split-window -h
   ```
   Para `%` y `"` tmux escapa la tecla con `\`. Los cuatro primeros campos
   (separados por un espacio) son siempre `bind-key -T prefix <tecla>`; el
   comando empieza en el quinto.

6. **TODO de `starter/atajos.sh`: tecla -> comando.** Ejecútalo antes de
   tocarlo, desde B:
   ```bash
   ./starter/atajos.sh
   ```
   ```
   d -> TODO
   c -> TODO
   ...
   ```
   Abre el archivo. Dentro del `for`, **borra** la línea
   `echo "$tecla -> TODO"` y escribe en su lugar:
   ```bash
   comando=$(tmx list-keys -T prefix "$tecla" | cut -d' ' -f5-)
   echo "$tecla -> $comando"
   ```
   `cut -d' ' -f5-` corta por espacios y se queda del quinto campo al final.
   Se imprime `$tecla` y no la tecla del listado, que llega escapada (`\%`).
   Vuelve a ejecutarlo:
   ```bash
   ./starter/atajos.sh
   ```
   ```
   d -> detach-client
   c -> new-window
   n -> next-window
   p -> previous-window
   % -> split-window -h
   " -> split-window
   ? -> list-keys -N
   ```

7. **Terminal B.** Saca a la terminal A de tmux sin tocar su teclado:
   ```bash
   tmux -L lab detach-client -s atajos
   ```
   (sin salida en B). La terminal A recibe
   `[detached (from session atajos)]`, igual que con `C-b` `d`.

8. Limpia, desde B:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida)

## Criterios de éxito

- [ ] Encontraste `detach` en la lista de `C-b` `?` y saliste con `q` (paso 2)
- [ ] Creaste una ventana con `C-b` `:` (paso 3) y otra con `tmux -L lab new-window` desde fuera (paso 4)
- [ ] `./starter/atajos.sh` imprime las 7 líneas del paso 6
- [ ] Desconectaste la terminal A con `detach-client` desde la B (paso 7)
- [ ] Puedes explicar por qué no hace falta memorizar atajos para escribir scripts de tmux

## Reto extra

`tmux -L lab list-keys -T root` muestra los atajos que funcionan **sin**
prefix. ¿Cuántos hay por defecto (`| wc -l`) y qué tienen en común? (Pista:
mira el cuarto campo con `awk '{print $4}'`).
