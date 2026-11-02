# Lab 03 — El prefix y la línea de comandos

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar que cada atajo de tmux es un comando con nombre, y ejecutar esos mismos comandos desde el prompt de tmux y desde una shell fuera de él.

## Contexto

- El **prefix** (`C-b` por defecto) avisa a tmux de que la siguiente tecla es para él y no para el programa del panel.
- Cada combinación `prefix` + tecla está **ligada a un comando**: `d` a `detach-client`, `c` a `new-window`. Las ligaduras viven en la **tabla** `prefix`.
- Ese mismo comando lo puedes escribir en el prompt de tmux (`prefix` `:`) o como argumento de `tmux` desde cualquier shell. Las tres vías dan el mismo resultado.

## Instrucciones

1. Abre una sesión de trabajo: `tmux -L lab new -s atajos`.

2. Pulsa `prefix` `?`. tmux muestra la lista de atajos con una descripción.
   Muévete con las flechas, busca con `C-s` y sal con `q`. Encuentra las
   teclas de `new-window`, `split-window` y `detach-client`.

3. Abre el **prompt de comandos** con `prefix` `:`. Aparece una línea amarilla
   en la status line. Escribe:
   ```
   new-window -n desde-prompt
   ```
   y pulsa Enter. Aparece la ventana `1:desde-prompt*`. Repite con:
   ```
   display-message "hola desde el prompt"
   ```

4. Ahora **desde fuera**. En otra terminal, sin entrar a tmux:
   ```bash
   tmux -L lab new-window -t atajos: -n desde-fuera
   tmux -L lab display-message -p -t atajos '#{session_windows} ventanas'
   ```
   En la primera terminal aparece la ventana `2:desde-fuera`; la segunda línea
   imprime `3 ventanas`. Es el **mismo comando** que pulsar `prefix` `c`: los
   scripts del proyecto usan exactamente esta vía.

5. Pregunta qué comando hay detrás de una tecla:
   ```bash
   tmux -L lab list-keys -T prefix d
   ```
   ```
   bind-key -T prefix d detach-client
   ```
   Para `%` y `"` tmux escapa la tecla con `\`: `bind-key -T prefix \% split-window -h`.

6. Completa `starter/atajos.sh`: por cada tecla de la lista, imprime
   `tecla -> comando`. Ejecútalo con el servidor del paso 1 todavía vivo:
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

7. Sal de tmux **sin** pulsar ninguna tecla de tmux: desde la otra terminal,
   ```bash
   tmux -L lab detach-client -s atajos
   ```
   Tu primera terminal recibe `[detached (from session atajos)]`, igual que con
   `prefix` `d`.

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Creaste una ventana con `prefix` `:` y otra con `tmux -L lab new-window` desde fuera
- [ ] `./starter/atajos.sh` imprime las 7 líneas del paso 6
- [ ] Desconectaste un cliente con `detach-client` sin tocar el teclado de esa terminal
- [ ] Puedes explicar por qué no hace falta memorizar atajos para escribir scripts de tmux

## Reto extra

`tmux -L lab list-keys -T root` muestra los atajos que funcionan **sin**
prefix. ¿Cuántos hay por defecto y qué tienen en común? (Pista: casi todos son
del ratón).
