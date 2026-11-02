# Lab 01 — Tu primera sesión

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar que tienes tmux ≥ 3.4, abrir y cerrar sesiones a mano y crear una sesión en segundo plano desde un script.

## Contexto

- Una **sesión** es lo que tmux mantiene vivo por ti: un conjunto de ventanas con sus programas corriendo.
- `tmux new` crea una sesión **y te conecta** a ella. `tmux new -d` la crea **sin conectarte**: el servidor la guarda y tú sigues en tu shell.
- En este lab todo va con `-L lab`: un servidor aparte, para no tocar tus sesiones de verdad.

## Instrucciones

1. Comprueba la versión y de dónde sale el binario:
   ```bash
   tmux -V
   command -v tmux
   ```
   Debes ver `tmux 3.4` o superior. Si ves `3.2a`, sigue
   [docs/setup-entorno.md](../../../../docs/setup-entorno.md) y vuelve.

2. Abre tu primera sesión con nombre:
   ```bash
   tmux -L lab new -s primera
   ```
   Abajo aparece la **status line** en verde: `[primera] 0:bash*` (o `zsh`). Entre
   corchetes va la sesión; después, la ventana `0` con su programa, y el `*`
   marca la ventana activa.

3. Dentro de la sesión, ejecuta `echo "$TMUX"`. Verás tres valores separados
   por comas: la ruta del socket, el pid del servidor y el número de sesión.
   Es la forma en que un programa sabe que corre dentro de tmux.

4. Escribe `exit`. Al cerrarse el último programa, la sesión desaparece y
   vuelves a tu shell con `[exited]`. Compruébalo:
   ```bash
   tmux -L lab ls
   ```
   ```
   no server running on /tmp/tmux-1000/lab
   ```
   `1000` es tu UID (`id -u`). Sin sesiones, el servidor también termina.

5. Abre `starter/primera.sh` y resuelve los dos `TODO`: crea en segundo plano
   la sesión `primera` con una ventana llamada `inicio`, y lista las sesiones.

6. Ejecútalo:
   ```bash
   ./starter/primera.sh
   ```
   ```
   primera: 1 windows (created ...)
   ```
   No te conectaste: la sesión existe pero nadie la está mirando.

7. Conéctate a ella y luego vuelve a ejecutar el script:
   ```bash
   tmux -L lab attach -t primera     # mira la status line: [primera] 0:inicio*
   # sal con exit y ejecuta de nuevo, dos veces seguidas:
   ./starter/primera.sh
   ./starter/primera.sh
   ```
   La segunda vez falla con `duplicate session: primera` y el script sale con
   código 1. Los nombres de sesión son únicos por servidor. Hacer el script
   **idempotente** es tema de la semana 09; por ahora basta con saber por qué
   falla.

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] `tmux -V` imprime 3.4 o superior
- [ ] `./starter/primera.sh` en un servidor vacío imprime una línea `primera: 1 windows`
- [ ] Tras ejecutarlo, `tmux -L lab list-windows -t primera -F '#{window_name}'` imprime `inicio`
- [ ] Puedes explicar por qué la segunda ejecución falla y por qué el servidor desaparece al cerrar la última sesión

## Reto extra

Usa `tmux -L lab new -d -s primera -n inicio 'top'` para que la ventana
ejecute `top` en lugar de una shell. Sal de `top` con `q` desde dentro de la
sesión: ¿qué le pasa a la ventana y a la sesión?
