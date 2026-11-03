# Lab 03 — Tablas propias: un modo resize

⏱ Duración estimada: ~60 min

## Objetivo

Construir un modo resize con una tabla de teclas propia, en el que `h` `j` `k` `l` mueven el borde hasta que sales con `q`, `Escape` o `Enter`.

## Contexto

- El prefix es solo una tecla que cambia la tabla del cliente a `prefix` durante **una** pulsación. `switch-client -T NOMBRE` hace lo mismo con cualquier tabla.
- Tras cada tecla de una tabla, el cliente vuelve a `root`. Para quedarte en el modo, el binding vuelve a entrar (`\; switch-client -T resize`), o lleva `-r` y aguanta `repeat-time`.
- `#{client_key_table}` dice en qué tabla está el cliente: es lo que pondrás en la barra para saber que estás "en modo".

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-03-tablas-propias
   ```
   El servidor es `-L lab`. Ni `-f /dev/null` ni el starter cambian el
   prefix: en este lab es **`C-b`**.

1. **Lo que hay.** En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s lab
   tmux -L lab list-keys -T prefix R
   tmux -L lab list-keys -T resize
   tmux -L lab kill-server
   ```
   ```
   unknown key: R
   table resize doesn't exist
   ```
   `R` está libre (la minúscula, `r`, es `refresh-client`) y la tabla
   `resize` no existe: una tabla nace con el primer `bind -T` que la nombra.

2. **La tabla en la barra.** Arranca con el starter y parte la ventana a los
   lados (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab split-window -h
   tmux -L lab list-panes -F '#{pane_index} #{pane_width} #{pane_active}'
   ```
   Algo como (el ancho depende de tu terminal):
   ```
   0 60 0
   1 59 1
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   La barra termina en `tabla: root`. Pulsa `C-b` y mira la barra:
   `tabla: prefix`. Pulsa `Escape` (en la tabla `prefix` no hace nada y
   tarda medio segundo, por `escape-time`): vuelve a `tabla: root`. Lo
   mismo desde la terminal A, sin mirar la barra:
   ```bash
   tmux -L lab display -p '#{client_key_table}'
   ```
   ```
   root
   ```
   Con un solo cliente conectado, `display -p` usa el suyo. Deja la B
   conectada.

3. **Los TODOs del starter.** Cada uno se prueba recargando con
   `source-file` en la terminal A y pulsando en la B.

   1. **TODO 1: entrar.** Pista:
      `bind -N "lab: modo resize" R switch-client -T resize`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix R
      tmux -L lab list-keys -T resize
      ```
      ```
      0
      bind-key -T prefix R switch-client -T resize
      table resize doesn't exist
      ```
      En la B, `C-b` `R`: la barra sigue en `tabla: root` y, si pulsas `h`,
      aparece en la shell (`$ h`; bórrala con `Backspace`).
      `switch-client -T` a una tabla que no existe no hace nada y no da
      error. El TODO 2 la crea.
   2. **TODO 2: moverse y seguir en el modo.** Primero, sin volver a
      entrar, para ver la diferencia (terminal A):
      ```bash
      tmux -L lab bind -T resize h resize-pane -L 5
      ```
      ```
      (sin salida)
      ```
      En la B, `C-b` `R` (barra: `tabla: resize`) y `h`: el borde se mueve
      5 a la izquierda y la barra vuelve a `tabla: root`. Otra `h` ya va a
      la shell (`$ h`; bórrala). Ahora la versión buena: debajo del
      comentario `TODO 2`, añade:
      ```tmux
      bind -T resize h resize-pane -L 5 \; switch-client -T resize
      bind -T resize j resize-pane -D 5 \; switch-client -T resize
      bind -T resize k resize-pane -U 5 \; switch-client -T resize
      bind -T resize l resize-pane -R 5 \; switch-client -T resize
      ```
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T resize h
      ```
      ```
      0
      bind-key -T resize h resize-pane -L 5 \; switch-client -T resize
      ```
      En la B, `C-b` `R` y `h` `h` `h`: tres movimientos y la barra sigue
      en `tabla: resize`. Espera unos segundos y pulsa `l`: sigue
      funcionando, este modo no caduca. En A:
      ```bash
      tmux -L lab display -p '#{client_key_table}'
      tmux -L lab list-panes -F '#{pane_index} #{pane_width} #{pane_active}'
      ```
      Algo como:
      ```
      resize
      0 45 0
      1 74 1
      ```
      Todavía no hay forma "buena" de salir. Pulsa `x`, que no está en la
      tabla: la barra vuelve a `tabla: root` y la `x` **no** llega a la
      shell. Una tecla que no está en una tabla propia te saca y se pierde.
   3. **TODO 3: salir.** Pista: `bind -T resize q switch-client -T root`,
      y lo mismo con `Escape` y `Enter`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T resize | wc -l
      ```
      ```
      0
      7
      ```
      En la B, prueba las tres: `C-b` `R` (barra `tabla: resize`), `q`
      (barra `tabla: root`); igual con `Escape` (tarda medio segundo) y con
      `Enter` (no llega a la shell: no ejecuta nada). Dentro del modo, `C-b`
      sigue siendo el prefix: `C-b` `R` y luego `C-b` pone la barra en
      `tabla: prefix`. Pulsa `Escape` para volver a `root`.
   4. **TODO 4: la variante con `-r`.** Pista:
      `bind -r -T resize H resize-pane -L 1` (y `J -D`, `K -U`, `L -R`).
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T resize H
      tmux -L lab list-keys -T resize | wc -l
      ```
      ```
      0
      bind-key -r -T resize H resize-pane -L 1
      11
      ```
      En la B, `C-b` `R` y `H` `H` seguidos: el borde se mueve de 1 en 1.
      Deja de pulsar: medio segundo después la barra vuelve sola a
      `tabla: root`. En A:
      ```bash
      tmux -L lab display -p '#{client_key_table}'
      ```
      ```
      root
      ```
      Y una diferencia más, en la B: `C-b` `R` `L` y enseguida `a`: sales
      del modo y la `a` **sí** llega a la shell (`$ a`; bórrala). Mientras
      dura la repetición, una tecla que no está en la tabla sale y se
      entrega. Sin repetición (`C-b` `R` `a`), se pierde, como la `x` del
      TODO 2.

4. **Resumen** (lo has visto en el paso 3). Escríbelo en tus notas:

   | Tras... | La tabla queda en | Una tecla que no está en la tabla |
   |---|---|---|
   | `h` (vuelve a entrar) | `resize`, hasta `q`/`Escape`/`Enter` | Te saca y se pierde |
   | `H` (`-r`) | `resize` durante `repeat-time`, luego `root` | Te saca y llega al panel |
   | `C-b` `R` sin pulsar nada más | `resize`, sin límite | Te saca y se pierde |

   Sal de la B con `C-b` `d`:
   ```
   [detached (from session lab)]
   ```

5. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `C-b` `R` no hacía nada visible tras el TODO 1 (paso 3.1)
- [ ] `tmux -L lab list-keys -T resize h` termina en `switch-client -T resize` y `h` `h` `h` mueve el borde tres veces sin salir del modo (paso 3.2)
- [ ] `tmux -L lab list-keys -T resize | wc -l` imprime `7` tras el TODO 3, y `q`, `Escape` y `Enter` ponen la barra en `tabla: root` (paso 3.3)
- [ ] Tras `C-b` `R` `H` y medio segundo sin pulsar, `display -p '#{client_key_table}'` imprime `root` (paso 3.4)
- [ ] Explicas por qué la `x` del TODO 2 se pierde y la `a` del TODO 4 llega a la shell (pasos 3.2 y 3.4)

## Reto extra

Haz que la barra solo avise cuando estás en el modo: `status-right` con
`#{?#{==:#{client_key_table},resize},MODO RESIZE ,}` (los formatos
condicionales llegan en la semana 07). ¿Qué ves en la barra si entras en el
modo y pulsas `C-b`?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — Repetición y la tabla root](../lab-02-repeticion-y-tabla-root/README.md) | [Lab 04 — Copy mode a medida](../lab-04-copy-mode-a-medida/README.md) → |

[↑ Semana 06](../../README.md)
