# Lab 03 — Alcances y herencia

⏱ Duración estimada: ~60 min

## Objetivo

Fijar opciones en el servidor, en una sesión, en una ventana y en un panel, ver cómo se heredan y escribir un script que dice de qué nivel sale el valor que ves.

## Contexto

- Servidor (`-s`), sesión (`-t sesión`, global `-g`), ventana (`-w -t ventana`, global `-gw`) y panel (`-p -t panel`). Un valor fijado abajo gana al heredado.
- `show -A` lista también lo heredado y lo marca con `*`.
- Con el **nombre** de una opción, `show` y `set` deducen el alcance por su cuenta. Sin nombre, `show` lista solo lo fijado en el nivel que pidas.

## Instrucciones

1. Prepara dos sesiones, una con dos ventanas y un panel partido, y conéctate
   desde una segunda terminal para ver los cambios:
   ```bash
   tmux -L lab -f /dev/null new -d -s api -n editor
   tmux -L lab new-window -d -t api: -n logs
   tmux -L lab split-window -h -d -t api:editor
   tmux -L lab new -d -s web
   tmux -L lab attach -t api          # en la segunda terminal
   ```

2. **Sesión.** Pinta la barra de estado:
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
   `api` tiene valor propio; `web` no tiene ninguno y hereda el global (`*`).
   Cambia a `web` en el cliente (`prefix` `)`) y verás la barra azul.

3. **Ventana y panel.** Colorea el fondo de un solo panel:
   ```bash
   tmux -L lab set -gw window-style bg=default
   tmux -L lab set -w -t api:logs window-style bg=colour17
   tmux -L lab set -p -t api:editor.1 window-style bg=colour52
   ```
   En el cliente, el panel derecho de `editor` es rojo oscuro, el izquierdo
   sigue igual y la ventana `logs` es azul oscuro. Cada nivel pisa al de
   arriba solo donde lo fijas.

4. **Volver a heredar.** `-u` borra el valor de ese nivel:
   ```bash
   tmux -L lab set -u -t api status-style
   tmux -L lab set -p -u -t api:editor.1 window-style
   tmux -L lab show -A -t api status-style       # status-style* bg=blue
   ```
   `set -gu status-style` devolvería el global a su valor por defecto.

5. **Servidor.** Hay un valor para todo el servidor, sin herencia:
   ```bash
   tmux -L lab show -sv escape-time        # 500
   tmux -L lab set -s escape-time 10
   ```
   `escape-time` es cuánto espera tmux tras un `Esc` por si es el inicio de
   una secuencia (una flecha, `Alt+tecla`). Con 500 ms, en vim cada `Esc`
   tarda medio segundo en salir del modo insertar. 10 ms bastan en local y por
   SSH. Tu kit lo fijará en `conf.d/10-opciones.conf`.

6. **¿De dónde sale este valor?** Prepara tres casos y pregunta con el nombre:
   ```bash
   tmux -L lab set -gw remain-on-exit off
   tmux -L lab set -w -t api:logs remain-on-exit on
   tmux -L lab set -p -t api:editor.1 remain-on-exit on
   tmux -L lab show -p -t api:editor.0 remain-on-exit; echo "[$?]"
   tmux -L lab show -p -t api:editor.0; echo "[lista]"
   ```
   Con nombre, para `editor.0` no imprime nada (no tiene valor propio) pero
   tampoco dice de dónde hereda. La lista, sin nombre, es la que dice qué hay
   en cada nivel. Completa `starter/nivel.sh` con esa idea:
   ```bash
   for p in api:editor.0 api:editor.1 api:logs.0; do printf '%s ' "$p"; ./starter/nivel.sh remain-on-exit "$p"; done
   ./starter/nivel.sh remain-on-exit api:nada; echo $?
   ```
   ```
   api:editor.0 off (global)
   api:editor.1 on (panel)
   api:logs.0 on (ventana)
   nivel.sh: no existe el panel api:nada
   1
   ```
   El proyecto amplía esta idea a todos los niveles en `bin/kit-opcion`.

7. **El `-g` olvidado.** Una config con una línea sin `-g`:
   ```bash
   tmux -L lab kill-server
   echo 'set status-style bg=red' > /tmp/sin-g.conf
   tmux -L lab -f /tmp/sin-g.conf new -d -s x
   tmux -L lab show -A -t x status-style
   ```
   ```
   status-style* bg=green,fg=black
   ```
   Al leer la config todavía no existe ninguna sesión: `set` sin `-g` no tiene
   a quién aplicarse, falla y no avisa. En la config, `-g` siempre.

8. Limpia: `tmux -L lab kill-server; rm -f /tmp/sin-g.conf`.

## Criterios de éxito

- [ ] Muestras con `show -A` una opción de sesión propia y otra heredada
- [ ] Tres paneles con tres fondos distintos, cada uno desde un nivel distinto
- [ ] `tmux -L lab show -sv escape-time` imprime `10` y explicas qué cambia en vim
- [ ] `./starter/nivel.sh` da las cinco líneas del paso 6
- [ ] Explicas por qué `set status-style` sin `-g` no hizo nada en el paso 7
- [ ] `shellcheck starter/nivel.sh` no muestra avisos

## Reto extra

`window-active-style` pinta solo el panel activo. Haz que el panel activo
tenga fondo normal y los inactivos uno algo más oscuro, solo en la sesión
`api`. ¿En qué nivel lo fijas, y por qué no con `-p`?
