# Lab 03 — Alcances y herencia

⏱ Duración estimada: ~60 min

## Objetivo

Fijar opciones en el servidor, en una sesión, en una ventana y en un panel, ver cómo se heredan y escribir un script que dice de qué nivel sale el valor que ves.

## Contexto

- Servidor (`-s`), sesión (`-t sesión`, global `-g`), ventana (`-w -t ventana`, global `-gw`) y panel (`-p -t panel`). Un valor fijado abajo gana al heredado.
- `show -A` lista también lo heredado y lo marca con `*`.
- Con el **nombre** de una opción, `show` deduce su tipo (servidor, sesión o ventana) y puede ignorar `-s` o `-w`. **Sin nombre**, lista solo lo fijado en el nivel que pides.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para ver los cambios. En las
   dos, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-03-alcances-y-herencia
   ```
   El servidor `-L lab` arranca con `-f /dev/null`: sin config, así que su
   prefix es **`C-b`**.

1. **Prepara** dos sesiones, `api` con dos ventanas (`editor` partida en dos
   paneles y `logs`) y `web`. En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s api -n editor
   tmux -L lab new-window -d -t api: -n logs
   tmux -L lab split-window -h -d -t api:editor
   tmux -L lab new -d -s web
   tmux -L lab ls
   ```
   Algo como (cambian las fechas):
   ```
   api: 2 windows (created Mon Nov  2 23:45:05 2026)
   web: 1 windows (created Mon Nov  2 23:45:05 2026)
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   Ves la ventana `editor` con dos paneles, el izquierdo activo. Déjala
   conectada; sales al final con `C-b` `d`.

2. **Sesión.** Pinta la barra de estado (terminal A):
   ```bash
   tmux -L lab set -g status-style bg=blue
   tmux -L lab set -t api status-style bg=red
   tmux -L lab show -t api; echo ---; tmux -L lab show -t web
   tmux -L lab show -A -t web status-style
   ```
   ```
   status-style bg=red
   ---
   status-style* bg=blue
   ```
   `api` tiene valor propio (en B la barra es roja); `web` no tiene ninguno
   (`show -t web` sin nombre no imprime nada) y hereda el global (`*`). En la
   terminal B pulsa `C-b` `)` (siguiente sesión): estás en `web` y la barra es
   azul. `C-b` `(` vuelve a `api`, roja.

3. **Ventana y panel.** Colorea el fondo de un solo panel (terminal A):
   ```bash
   tmux -L lab set -gw window-style bg=default
   tmux -L lab set -w -t api:logs window-style bg=colour17
   tmux -L lab set -p -t api:editor.1 window-style bg=colour52
   ```
   ```
   (sin salida)
   ```
   En la terminal B, el panel derecho de `editor` (`editor.1`) es rojo
   oscuro y el izquierdo sigue igual. `C-b` `n` pasa a la ventana `logs`:
   azul oscuro. `C-b` `p` vuelve a `editor`. Compruébalo también desde A:
   ```bash
   tmux -L lab show -A -p -t api:editor.1 window-style
   tmux -L lab show -A -p -t api:editor.0 window-style
   tmux -L lab show -A -p -t api:logs.0 window-style
   ```
   ```
   window-style bg=colour52
   window-style* bg=default
   window-style* bg=colour17
   ```
   Cada nivel pisa al de arriba solo donde lo fijas: `editor.1` tiene valor
   propio; `editor.0` hereda el global; `logs.0` hereda el de su ventana.

4. **Volver a heredar.** `-u` borra el valor de ese nivel (terminal A):
   ```bash
   tmux -L lab set -u -t api status-style
   tmux -L lab set -p -u -t api:editor.1 window-style
   tmux -L lab show -A -t api status-style
   ```
   ```
   status-style* bg=blue
   ```
   En B, la barra de `api` es azul y el panel derecho vuelve al fondo
   normal. `set -gu status-style` devolvería el global a su valor por
   defecto.

5. **Servidor.** Hay un valor para todo el servidor, sin herencia
   (terminal A):
   ```bash
   tmux -L lab show -sv escape-time
   tmux -L lab set -s escape-time 10
   tmux -L lab show -sv escape-time
   ```
   ```
   500
   10
   ```
   `escape-time` es cuánto espera tmux tras un `Esc` por si es el inicio de
   una secuencia (una flecha, `Alt+tecla`). Con 500 ms, cualquier programa
   del panel que use `Esc` (cerrar un menú, la shell con `set -o vi`, un
   editor de terminal) lo recibe medio segundo tarde. 10 ms bastan en local;
   por SSH con mucha latencia, si alguna flecha llega como `Esc` más una
   letra, súbelo (por ejemplo a 50). Tu kit lo fijará en
   `conf.d/10-opciones.conf`.

6. **¿De dónde sale este valor?** Prepara tres casos (terminal A):
   ```bash
   tmux -L lab set -gw remain-on-exit off
   tmux -L lab set -w -t api:logs remain-on-exit on
   tmux -L lab set -p -t api:editor.1 remain-on-exit on
   tmux -L lab show -p -t api:editor.0 remain-on-exit; echo "[$?]"
   tmux -L lab show -p -t api:editor.1; echo "[lista]"
   tmux -L lab show -w -t api:logs escape-time
   ```
   ```
   [0]
   remain-on-exit on
   [lista]
   escape-time 10
   ```
   Con nombre, para `editor.0` no imprime nada (no tiene valor propio) pero
   tampoco dice de dónde hereda. Y con el nombre de una opción de servidor,
   `show -w` contesta igual: tmux deduce el alcance por la opción e ignora
   `-w`. La lista sin nombre es la única que dice, sin trampas, qué hay en
   cada nivel. Con esa idea escribe `starter/nivel.sh OPCION PANEL`. Al
   final del archivo hay un `echo "sin implementar"` y un `exit 1`: déjalos
   hasta el TODO 3 y entonces bórralos. Si no lo tienes:
   `sudo apt install shellcheck` (macOS: `brew install shellcheck`).

   1. **TODO 1: valida el panel.** `display-message` no falla con un panel
      que no existe; `list-panes -t` sí. Pista:
      `if ! tmx list-panes -t "$panel" >/dev/null 2>&1; then` + mensaje por
      stderr `nivel.sh: no existe el panel PANEL` + `exit 1`.
      ```bash
      ./starter/nivel.sh remain-on-exit api:nada; echo $?
      ./starter/nivel.sh remain-on-exit api:editor.0; echo $?
      ```
      ```
      nivel.sh: no existe el panel api:nada
      1
      nivel.sh: sin implementar (remain-on-exit en api:editor.0)
      1
      ```
   2. **TODO 2: la función `valor`.** `valor FLAGS...` ejecuta
      `tmx show "$@"` (sin nombre de opción) y se queda con la línea cuyo
      primer campo es la opción. Pista de `awk`:
      `awk -v o="$opcion" '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'`:
      `sub` quita el nombre y el espacio, y `exit !f` hace que falle si no
      la encontró. Prueba la tubería suelta en la terminal:
      ```bash
      tmux -L lab show -p -t api:editor.1 | awk -v o=remain-on-exit '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'; echo $?
      tmux -L lab show -p -t api:editor.0 | awk -v o=remain-on-exit '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'; echo $?
      ```
      ```
      on
      0
      1
      ```
   3. **TODO 3: del más concreto al más general.** Pista:
      `if v=$(valor -p -t "$panel"); then echo "$v (panel)"`, después
      `elif` con `-w -t "$panel"` (ventana) y con `-gw` (global); en el
      `else`, `nivel.sh: OPCION no es una opción de ventana` por stderr y
      `exit 1`. Borra el `echo "sin implementar"` y el `exit 1`.
      ```bash
      for p in api:editor.0 api:editor.1 api:logs.0; do printf '%s ' "$p"; ./starter/nivel.sh remain-on-exit "$p"; done
      ./starter/nivel.sh status-style api:editor.0; echo $?
      shellcheck starter/nivel.sh; echo $?
      ```
      ```
      api:editor.0 off (global)
      api:editor.1 on (panel)
      api:logs.0 on (ventana)
      nivel.sh: status-style no es una opción de ventana
      1
      0
      ```
   El proyecto amplía esta idea a todos los niveles en `bin/kit-opcion`.
   Referencia: `solucion/nivel.sh`.

7. **El `-g` olvidado.** Una config con una línea sin `-g`. El
   `kill-server` expulsa a la terminal B, que imprime `[server exited]`.
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   echo 'set status-style bg=red' > /tmp/sin-g.conf
   tmux -L lab -f /tmp/sin-g.conf new -d -s x
   tmux -L lab show -A -t x status-style
   tmux -L lab source-file /dev/null
   ```
   ```
   status-style* bg=green,fg=black
   /tmp/sin-g.conf:1: no current session
   ```
   Al leer la config todavía no existe ninguna sesión: `set` sin `-g` no
   tiene a quién aplicarse y falla con `no current session`. Con `new -d`
   nadie ve el error: espera al primer cliente que se conecte o, como aquí,
   a la primera orden `source-file` (lab 01, paso 4). En la config, `-g`
   siempre.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server; rm -f /tmp/sin-g.conf
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Muestras con `show -A` una opción de sesión propia y otra heredada (paso 2)
- [ ] Tres paneles con tres fondos distintos, cada uno desde un nivel distinto (paso 3)
- [ ] `tmux -L lab show -sv escape-time` imprime `10` y explicas qué notaría un programa que usa `Esc` (paso 5)
- [ ] `./starter/nivel.sh` da las salidas de los pasos 6.1 y 6.3 (paso 6)
- [ ] Explicas por qué `set status-style` sin `-g` no hizo nada y dónde quedó el error (paso 7)
- [ ] `shellcheck starter/nivel.sh` sale con 0 sin avisos (paso 6.3)

## Reto extra

`window-active-style` pinta solo el panel activo. Haz que el panel activo
tenga fondo normal y los inactivos uno algo más oscuro, solo en la sesión
`api`. ¿En qué nivel lo fijas, y por qué no con `-p`?
