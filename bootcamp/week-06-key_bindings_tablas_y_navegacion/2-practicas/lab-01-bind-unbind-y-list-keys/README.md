# Lab 01 — bind, unbind y list-keys

⏱ Duración estimada: ~60 min

## Objetivo

Crear, pisar, quitar y documentar teclas de la tabla `prefix`, y comprobar cada cambio con `list-keys` en lugar de pulsarlas a ciegas.

## Contexto

- `list-keys -T TABLA TECLA` dice qué hace una tecla **ahora**, en el servidor vivo. Es la forma de comprobar un binding sin pulsarlo.
- Un `bind` sobre una tecla ocupada la sustituye sin avisar, aunque sea una tecla por defecto. Y si el nuevo `bind` no lleva `-N`, la nota desaparece con él.
- `-N "nota"` es la documentación de tu config: la ves con `list-keys -N` y con `prefix` `?`.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-01-bind-unbind-y-list-keys
   ```
   Todo va contra el servidor `-L lab`. Ni `-f /dev/null` ni el starter
   cambian el prefix: en este lab es **`C-b`**.

1. **Lo que trae tmux.** En la terminal A, con la config por defecto:
   ```bash
   tmux -L lab -f /dev/null new -d -s lab
   tmux -L lab list-keys -T prefix | wc -l
   tmux -L lab list-keys -T prefix %
   tmux -L lab list-keys -T prefix '"'
   tmux -L lab list-keys -T prefix m
   tmux -L lab list-keys -T prefix -
   ```
   ```
   85
   bind-key -T prefix \% split-window -h
   bind-key -T prefix \" split-window
   bind-key -T prefix m select-pane -m
   bind-key -T prefix - delete-buffer
   ```
   85 teclas detrás de `C-b`. `m` marca el panel y `-` borra el último
   buffer de copia: las dos están ocupadas aunque no las uses. Ahora las
   notas:
   ```bash
   tmux -L lab list-keys -N -T prefix m
   tmux -L lab list-keys -N | head -4
   tmux -L lab list-keys -T prefix F5; echo $?
   ```
   ```
   m Toggle the marked pane
   C-b C-b     Send the prefix key
   C-b C-o     Rotate through the panes
   C-b C-z     Suspend the current client
   C-b Space   Select next layout
   ```
   ```
   unknown key: F5
   1
   ```
   Sin `-T`, `list-keys -N` antepone el prefix (`C-b C-o`): es lo que
   pulsas. Una tecla libre da `unknown key` y sale con 1.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

2. **Dos `bind` para la misma tecla.** Lee las primeras líneas de
   `starter/tmux.conf`: `m` aparece dos veces, la primera con nota. Arranca
   con el starter (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab list-keys -T prefix m
   tmux -L lab list-keys -N -T prefix m; echo $?
   ```
   ```
   bind-key -T prefix m display-message "m de mensaje"
   unknown key: m
   1
   ```
   Gana la última línea, sin error ni aviso. Y la nota se perdió:
   `unknown key` aquí significa "esa tecla no tiene nota". Lo arreglas en el
   TODO 4.

3. **Los TODOs del starter.** Cada uno se prueba recargando con
   `source-file` (el servidor sigue arrancado).

   1. **TODO 1: `prefix` `|`.** Debajo del comentario `TODO 1`, añade:
      ```tmux
      bind -N "lab: dividir a los lados" | split-window -h
      ```
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -N -T prefix '|'
      tmux -L lab list-keys -T prefix '|'
      ```
      ```
      0
      | lab: dividir a los lados
      bind-key -T prefix | split-window -h
      ```
      En la shell, `|` va entre comillas (si no, es una tubería); en
      `tmux.conf` no hace falta.
   2. **TODO 2: `prefix` `-`.** Pista:
      `bind -N "lab: dividir arriba y abajo" - split-window -v`. Pisa el
      `delete-buffer` del paso 1: es un precio que pagas a sabiendas.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -N -T prefix -
      ```
      ```
      0
      - lab: dividir arriba y abajo
      ```
   3. **TODO 3: libera `"` y `%`.** Pista: `unbind '"'` y `unbind %` (sin
      `-T`, `unbind` actúa sobre la tabla `prefix`).
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix %
      tmux -L lab list-keys -T prefix '"'
      ```
      ```
      0
      unknown key: %
      unknown key: "
      ```
   4. **TODO 4: una sola línea para `m`.** Borra la línea
      `bind m display "m de mensaje"`. Recarga y mira:
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T prefix m
      tmux -L lab list-keys -N -T prefix m; echo $?
      ```
      ```
      0
      bind-key -T prefix m select-pane -m
      m lab: marcar el panel
      0
      ```
      Ahora la línea con `-N` es la última que toca `m`: vuelven el comando
      y la nota. Si un día una tecla no hace lo que dice tu config, busca
      otra línea posterior para la misma tecla (`grep -n ' m ' starter/tmux.conf`).

4. **Un script para ver tus teclas documentadas.** `starter/keys-of.sh
   TABLA` lista las teclas de una tabla que tienen nota y cuántas son del
   total. Habla con el servidor `-L lab` (o con `TMUX_SOCKET`, si la
   defines). Hoy no hace nada:
   ```bash
   ./starter/keys-of.sh prefix; echo $?
   ```
   ```
   keys-of.sh: sin implementar
   1
   ```
   Si no tienes `shellcheck`: `sudo apt install shellcheck` (macOS:
   `brew install shellcheck`).

   1. **TODO 1: uso.** Pista: `if [[ $# -ne 1 ]]; then echo "uso:
      keys-of.sh TABLA" >&2; exit 2; fi` y después `table="$1"`.
      ```bash
      ./starter/keys-of.sh; echo $?
      ./starter/keys-of.sh a b; echo $?
      ```
      ```
      uso: keys-of.sh TABLA
      2
      uso: keys-of.sh TABLA
      2
      ```
   2. **TODO 2: hay servidor.** Pista: `tmx list-sessions >/dev/null 2>&1
      || { echo "keys-of.sh: no hay servidor en el socket
      ${TMUX_SOCKET:-lab}" >&2; exit 1; }`. Prueba contra un socket vacío:
      ```bash
      TMUX_SOCKET=nada ./starter/keys-of.sh prefix; echo $?
      ```
      ```
      keys-of.sh: no hay servidor en el socket nada
      1
      ```
   3. **TODO 3: la tabla existe.** `list-keys -T` falla con una tabla que
      no existe (`table resize doesn't exist`). Pista: `if ! all=$(tmx
      list-keys -T "$table" 2>/dev/null); then ...; fi`. Así `all` guarda
      además todas las teclas para el TODO 4.
      ```bash
      ./starter/keys-of.sh resize; echo $?
      ```
      ```
      keys-of.sh: no existe la tabla resize
      1
      ```
   4. **TODO 4: la lista y el recuento.** Pista: `tmx list-keys -N -T
      "$table"` y después `echo "con nota: $(tmx list-keys -N -T "$table" |
      wc -l) de $(printf '%s\n' "$all" | wc -l)"`. Borra el `echo
      "keys-of.sh: sin implementar"` y el `exit 1` del final.
      ```bash
      ./starter/keys-of.sh prefix | grep lab:
      ./starter/keys-of.sh prefix | tail -1
      ./starter/keys-of.sh root; echo $?
      ./starter/keys-of.sh copy-mode-vi | tail -1
      ```
      ```
      -       lab: dividir arriba y abajo
      m       lab: marcar el panel
      |       lab: dividir a los lados
      con nota: 82 de 84
      con nota: 0 de 16
      0
      con nota: 0 de 87
      ```
      84 = 85 − 2 (`unbind`) + 1 (`|`); `-` y `m` ya existían. En `root`
      (las teclas sin prefix, casi todas de ratón) y en `copy-mode-vi` tmux
      no trae notas: `list-keys -N` no basta para saber qué hacen; hay que
      leer el comando con `list-keys -T`.
      ```bash
      shellcheck starter/keys-of.sh && echo limpio
      ```
      ```
      limpio
      ```

5. **Úsalo.** En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   - `C-b` `?` abre la lista de teclas con nota (las de tmux en inglés,
     las tuyas con `lab:`). Arriba a la derecha, `[52/52]`: estás al
     principio; baja con `↓` o `PageDown`. Sal con `q`.
   - `C-b` `|`: dos paneles a los lados. `C-b` `-`: el de la derecha se
     parte en dos, uno encima del otro. Comprueba en la terminal A:
     ```bash
     tmux -L lab list-panes -F '#{pane_index} #{pane_width}x#{pane_height}'
     ```
     ```
     0 60x30
     1 59x15
     2 59x14
     ```
     (Los tamaños dependen de tu terminal.)
   - `C-b` `%` ya no hace nada: no es de tmux ni llega a la shell.
   - Sal con `C-b` `d`:
     ```
     [detached (from session lab)]
     ```

6. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `list-keys -N -T prefix m` dio `unknown key` en el paso 2 aunque la tecla existía
- [ ] `tmux -L lab list-keys -N -T prefix '|'` imprime `| lab: dividir a los lados` (paso 3.1)
- [ ] `tmux -L lab list-keys -N -T prefix -` imprime `- lab: dividir arriba y abajo` (paso 3.2)
- [ ] `tmux -L lab list-keys -T prefix %` imprime `unknown key: %` (paso 3.3)
- [ ] `tmux -L lab list-keys -N -T prefix m` imprime `m lab: marcar el panel` (paso 3.4)
- [ ] `./starter/keys-of.sh` sale con 2 sin argumentos, con 1 sin servidor o con una tabla que no existe, e imprime `con nota: 82 de 84` en `prefix` (paso 4)
- [ ] `shellcheck starter/keys-of.sh` no da avisos (paso 4.4)

## Reto extra

Dos teclas de la tabla `prefix` no tienen nota (82 de 84). Encuéntralas
comparando `list-keys -T prefix` con `list-keys -N -T prefix`, y añade a
`keys-of.sh` una opción `-a` que las liste también (pista: `list-keys -aN`).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Repetición y la tabla root](../lab-02-repeticion-y-tabla-root/README.md) → |

[↑ Semana 06](../../README.md)
