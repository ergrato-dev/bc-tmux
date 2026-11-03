# Lab 02 — Un prefix propio

⏱ Duración estimada: ~60 min

## Objetivo

Cambiar el prefix de tmux por uno elegido con criterio, liberar `C-b` y mantener la forma de enviar el prefix al programa del panel.

## Contexto

- `C-b` choca con atajos que usas a diario: en bash mueve el cursor un carácter atrás; en `less`, sube una página.
- `prefix` es una opción de **sesión**: se fija con `-g` para todas. La tecla que lo "reenvía" al panel es un binding aparte en la tabla `prefix`: `send-prefix`.
- Desde esta semana, el bootcamp escribe `prefix` y no `C-b` cuando el servidor carga tu config: cada uno usa el suyo. En este lab, cada paso dice qué tecla es.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-02-prefix-propio
   ```
   Todo va contra el servidor `-L lab`.

1. **Lo que hay ahora.** En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d \; show -gv prefix \; list-keys -T prefix C-b
   tmux -L lab kill-server
   ```
   ```
   C-b
   bind-key -T prefix C-b send-prefix
   ```
   El prefix es la tecla que abre la tabla `prefix`; `C-b` **dentro** de esa
   tabla es otro binding: el que envía un `C-b` real al panel.

2. **Elige.** Ninguno es perfecto. La última columna es lo que pasa en bash
   al pulsar el prefix dos veces (lo pruebas en el paso 4):

   | Prefix | A favor | En contra | `prefix` `prefix` en bash |
   |---|---|---|---|
   | `C-a` | Cómodo con Caps Lock como Ctrl; el de screen | En bash es "inicio de línea": pasa a ser `C-a` `C-a` | El cursor va al inicio de la línea |
   | `C-Space` | Casi nada lo usa | Algunas terminales y sistemas (cambio de idioma) lo capturan | Marca la posición del cursor: no se ve nada |
   | `C-s` | Cómodo | Es XOFF: `prefix` `prefix` congela el panel hasta que pulsas `C-q`, salvo que ejecutes `stty -ixon` en la shell del panel (para siempre, en tu `~/.bashrc`) | Congela el panel (`C-q` lo suelta). Con `stty -ixon`, búsqueda hacia delante en el historial, `(i-search)`; `C-g` sale |
   | `` ` `` (backtick) | Una sola tecla | Lo escribes en markdown y en shell a menudo | Escribe un `` ` `` |

   Escribe tu elección y el motivo en el comentario del `TODO 1` de
   `starter/tmux.conf`. Los ejemplos usan `C-a`: si eliges otro, cámbialo en
   cada comando (el backtick, entre comillas simples: `` '`' ``).

3. **Arranca el servidor** con el starter, que aún no cambia nada (terminal
   A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s principal
   tmux -L lab show -gv prefix
   ```
   ```
   C-b
   ```
   Cada TODO se prueba recargando el archivo con `source-file`.

   1. **TODO 1: el prefix.** Pista: `set -g prefix C-a` (con `-g`: para
      todas las sesiones).
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab show -gv prefix
      tmux -L lab list-keys -T prefix C-b
      ```
      ```
      0
      C-a
      bind-key -T prefix C-b send-prefix
      ```
      `C-a` ya abre la tabla `prefix`, pero `C-b` sigue ocupada por la
      config por defecto.
   2. **TODO 2: libera `C-b`.** Pista: `unbind C-b` (sin `-T`, actúa sobre
      la tabla `prefix`).
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix C-b
      ```
      ```
      0
      unknown key: C-b
      ```
   3. **TODO 3: tu prefix dos veces llega al panel.** Pista:
      `bind C-a send-prefix`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix C-a
      ```
      ```
      0
      bind-key -T prefix C-a send-prefix
      ```

4. **Úsalo.** En la terminal B:
   ```bash
   tmux -L lab attach -t principal
   ```
   Este servidor ya usa **tu** prefix (`C-a` en los ejemplos):
   - `C-a` `c` abre una ventana: la barra pasa a `0:bash- 1:bash*`.
   - `C-b` `c` ya no es de tmux: bash recibe `C-b` (cursor un carácter
     atrás) y la `c` aparece en la línea, `$ c`. Bórrala con `Backspace`.
   - Escribe `echo hola` sin pulsar `Enter` y pulsa `C-a` `C-a`: el cursor
     salta al inicio de la línea (con otro prefix, mira la última columna
     del paso 2). Era un `C-a` para bash. Vacía la línea con `C-u`.
   - Sal con `C-a` `d`:
     ```
     [detached (from session principal)]
     ```

5. **Dos prefixes a la vez.** Mientras te acostumbras, puedes dejar `C-b`
   como segundo prefix. En la terminal A:
   ```bash
   tmux -L lab set -g prefix2 C-b
   tmux -L lab show -g prefix2
   ```
   ```
   prefix2 C-b
   ```
   En la terminal B, `tmux -L lab attach -t principal`: ahora `C-b` `c`
   también abre una ventana. Sal con `C-a` `d`. Quítalo cuando ya no lo
   necesites (terminal A): dos prefixes son dos teclas robadas a tus
   programas.
   ```bash
   tmux -L lab set -gu prefix2
   tmux -L lab show -g prefix2
   ```
   ```
   prefix2 None
   ```

6. **Solo una sesión.** `prefix` es de sesión: puedes darle otro a una sola.
   En la terminal A:
   ```bash
   tmux -L lab new -d -s anidada
   tmux -L lab set -t anidada prefix C-b
   tmux -L lab show -A -t anidada prefix
   tmux -L lab show -A -t principal prefix
   ```
   ```
   prefix C-b
   prefix* C-a
   ```
   El `*` marca el valor heredado del global. Lo usarás en la semana 12 para
   tmux dentro de tmux.

7. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `tmux -L lab show -gv prefix` imprime tu prefix, que no es `C-b` (paso 3.1)
- [ ] `tmux -L lab list-keys -T prefix C-b` dice `unknown key: C-b` (paso 3.2)
- [ ] `tmux -L lab list-keys -T prefix TU-PREFIX` muestra `send-prefix` (paso 3.3)
- [ ] Tu prefix pulsado dos veces llega a bash con el efecto de la tabla (paso 4)
- [ ] El comentario de tu `tmux.conf` explica por qué elegiste ese prefix y qué pierdes
- [ ] Explicas la diferencia entre el `C-b` del paso 1 y el prefix

## Reto extra

El estilo de screen: `prefix` `a` envía el prefix y `prefix` `C-a` salta a la
última ventana (`last-window`). Configúralo. ¿Qué ganas y qué pierdes?
