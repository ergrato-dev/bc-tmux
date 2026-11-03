# Lab 01 — Tu primera sesión

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar que tienes tmux ≥ 3.4, abrir y cerrar sesiones a mano y crear una sesión en segundo plano desde un script.

## Contexto

- Una **sesión** es lo que tmux mantiene vivo por ti: un conjunto de ventanas con sus programas corriendo.
- `tmux new` crea una sesión **y te conecta** a ella. `tmux new -d` la crea **sin conectarte**: el servidor la guarda y tú sigues en tu shell.
- En este lab todo va con `-L lab`: un servidor aparte, para no tocar tus sesiones de verdad. Arranca con `-f /dev/null` (sin configuración), así que el prefix es el de fábrica: `C-b`.

## Instrucciones

0. **Prepara la terminal.** Abre una terminal **fuera de tmux** y, desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-01-primera-sesion
   echo "$TMUX"
   ```
   `echo` imprime una línea vacía: no estás dentro de tmux. Si imprime algo
   como `/tmp/tmux-1000/default,1234,0`, abre otra terminal.

1. Comprueba la versión y de dónde sale el binario:
   ```bash
   tmux -V
   command -v tmux
   ```
   ```
   tmux 3.4
   /usr/bin/tmux
   ```
   Vale `3.4` o superior (con Homebrew la ruta es `/opt/homebrew/bin/tmux`).
   Si ves `3.2a`, sigue [docs/setup-entorno.md](../../../../docs/setup-entorno.md)
   y vuelve.

2. Abre tu primera sesión con nombre:
   ```bash
   tmux -L lab -f /dev/null new -s primera
   ```
   La terminal se limpia y abajo aparece la **status line** en verde, algo
   como (cambian el nombre del equipo, la hora y la fecha):
   ```
   [primera] 0:bash*                                  "bc-tmux-lab" 23:43 02-Nov-26
   ```
   Entre corchetes va la sesión; después, la ventana `0` con su programa
   (`bash` o `zsh`, según tu shell) y el `*` marca la ventana activa. A la
   derecha, el nombre de tu equipo y la hora.

3. Dentro de la sesión:
   ```bash
   echo "$TMUX"
   ```
   ```
   /tmp/tmux-1000/lab,16,0
   ```
   Tres valores separados por comas: la ruta del socket, el pid del servidor
   (el tuyo será otro) y el número de sesión. `1000` es tu UID (`id -u`). Así
   sabe un programa que corre dentro de tmux.

4. Cierra la shell de la sesión:
   ```bash
   exit
   ```
   ```
   [exited]
   ```
   (Con bash verás antes `logout`.) Era el único programa de la única ventana
   de la única sesión: al cerrarse, la sesión desaparece y, sin sesiones, el
   servidor también termina. Vuelves a tu shell de antes. Compruébalo:
   ```bash
   tmux -L lab ls; echo $?
   ```
   ```
   no server running on /tmp/tmux-1000/lab
   1
   ```

5. **TODO 1 de `starter/first.sh`: crear la sesión sin conectarte.** Abre
   el archivo con tu editor. Debajo del comentario `TODO 1` escribe:
   ```bash
   tmx new-session -d -s primera -n inicio
   ```
   `-d` no te conecta, `-s` da nombre a la sesión y `-n` a su primera
   ventana. `tmx` es la función del starter que añade `-L lab` por ti.
   Pruébalo:
   ```bash
   ./starter/first.sh
   tmux -L lab list-windows -t primera -F '#{window_name}'
   ```
   ```
   inicio
   ```
   El script no imprime nada (todavía no lista) y no te conectó: la sesión
   existe pero nadie la mira. Borra el servidor antes del siguiente TODO,
   porque el script volverá a crear `primera`:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida)

6. **TODO 2: listar las sesiones.** Debajo de `TODO 2` escribe `tmx ls`.
   Pruébalo con el servidor vacío:
   ```bash
   ./starter/first.sh
   ```
   Algo como (cambian la fecha y la hora):
   ```
   primera: 1 windows (created Mon Nov  2 23:43:50 2026)
   ```
   Sin `(attached)` al final: ningún cliente la mira.

7. Conéctate a ella en esta misma terminal:
   ```bash
   tmux -L lab attach -t primera
   ```
   La status line dice `[primera] 0:inicio*`. Sal **sin cerrarla**: pulsa
   **Ctrl+b**, suelta, y pulsa **d** (`C-b` `d`). Vuelves a tu shell con:
   ```
   [detached (from session primera)]
   ```

8. Ejecuta el script otra vez, con `primera` todavía viva:
   ```bash
   ./starter/first.sh; echo $?
   ```
   ```
   duplicate session: primera
   1
   ```
   Los nombres de sesión son únicos por servidor y `set -e` corta el script en
   el primer error. Hacer el script **idempotente** es tema de la semana 09;
   por ahora basta con saber por qué falla.

9. Limpia:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida)

## Criterios de éxito

- [ ] `tmux -V` imprime 3.4 o superior (paso 1)
- [ ] `exit` en la última sesión deja `no server running` (paso 4)
- [ ] Tras el TODO 1, `tmux -L lab list-windows -t primera -F '#{window_name}'` imprime `inicio` (paso 5)
- [ ] `./starter/first.sh` en un servidor vacío imprime una línea `primera: 1 windows` (paso 6)
- [ ] La segunda ejecución sale con `duplicate session: primera` y código 1, y puedes explicar por qué (paso 8)

## Reto extra

Ejecuta `tmux -L lab -f /dev/null new -d -s primera -n inicio top` para que la
ventana ejecute `top` en vez de una shell, conéctate con
`tmux -L lab attach -t primera` y sal de `top` con `q`. ¿Qué le pasa a la
ventana, a la sesión y al servidor? Compruébalo con `tmux -L lab ls`.
