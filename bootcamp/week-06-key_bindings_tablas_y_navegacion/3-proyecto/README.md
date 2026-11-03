# Proyecto Semana 06 — tmux-kit: modo resize, navegación sin prefix y teclas documentadas

⏱ Duración estimada: ~3 h

## Contexto

Llevas una semana con el kit modular y ya te pesan tres cosas cada día. Para agrandar un panel pulsas `prefix` `C-→` diez veces. Para ir al panel de al lado pulsas `prefix` `→`, y si dentro hay `less` o un editor, sus propias teclas de movimiento chocan con las tuyas. Y cuando un compañero te pregunta "¿qué teclas tiene tu kit?", no lo sabes sin abrir `conf.d/20-bindings.conf`.

Esta semana tu kit gana un **modo resize** (`prefix` `R` y después `h` `j` `k` `l` tantas veces como quieras, hasta `q`), **navegación sin prefix** con `C-h` `C-j` `C-k` `C-l` que se aparta cuando el panel muestra un programa a pantalla completa, splits que abren en el directorio donde estás y una **nota `kit:` en cada tecla**, que `prefix` `?` y el nuevo **`bin/kit-keys`** muestran.

```bash
$ kit-keys kit-resize
kit-resize Enter  kit: sale del modo resize
kit-resize Escape  kit: sale del modo resize
kit-resize H  kit: borde a la izquierda (1)
...
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                 ← tu tmux-kit de la semana 05 + lo nuevo
├── README.md            ← añade las teclas, kit-keys y la bitácora
├── .gitignore           ← local.conf
├── tmux.conf            ← sin cambios: carga conf.d/
├── conf.d/
│   ├── 10-options.conf  ← TODO 6
│   └── 20-bindings.conf ← TODOs 1-5, 7 y 8
└── bin/
    ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option   (semanas 01-05)
    └── kit-keys         ← TODOs 9-11 (nuevo)
```

## Lo que debes construir

1. **Notas en todas las teclas del kit**: cada `bind` del kit lleva `-N "kit: ..."`, también las que ya tenías (`C-a`, `r` y las cuatro de copy mode).
2. **Splits en el mismo directorio**: `prefix` `|` divide a la derecha y `prefix` `-` debajo, los dos con `-c "#{pane_current_path}"`.
3. **Modo resize**: `prefix` `R` mete al cliente en la tabla `kit-resize`. Ahí `h` `j` `k` `l` mueven el borde 5 celdas y `H` `J` `K` `L` 1, y el cliente sigue en la tabla; `q`, `Escape` y `Enter` lo devuelven a `root`.
4. **Navegación sin prefix**: `C-h` `C-j` `C-k` `C-l` cambian de panel en la tabla `root`, salvo que el panel muestre un programa a pantalla completa (`#{alternate_on}`) o `@kit-nav` valga `off`: entonces la tecla le llega al programa. `@kit-nav` vale `on` en `10-options.conf`. `prefix` `C-l` envía `C-l` para limpiar la pantalla.
5. **`bin/kit-keys [TABLA]`**: imprime `TABLA TECLA  NOTA` de las teclas cuya nota empieza por `kit:`. Sin `TABLA`, las de `prefix`, `root`, `kit-resize` y `copy-mode-vi`. Sale con **1** si no hay servidor (sin arrancar uno) o la tabla no existe, y con **2** si el uso es incorrecto.
6. **README del kit** con una sección de teclas, `kit-keys` en la tabla de scripts y la bitácora de la semana.

## Paso a paso

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte y pulsar
   teclas. En la A, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/3-proyecto/starter
   ```
   Todo va contra un servidor aparte, `-L kit`, con ruta absoluta. El kit
   fija el prefix desde la semana 05: aquí es `C-a`; si elegiste otro,
   cámbialo en cada paso. Si no lo tienes: `sudo apt install shellcheck`
   (macOS: `brew install shellcheck`).

1. **Punto de partida.** Lo que el kit todavía no tiene:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s api
   tmux -L kit list-keys -T prefix R
   tmux -L kit list-keys -T prefix -
   tmux -L kit list-keys -T root C-h
   TMUX_SOCKET=kit bin/kit-keys; echo $?
   TMUX_SOCKET=kit bin/kit-keys a b; echo $?
   ```
   ```
   unknown key: R
   bind-key -T prefix - delete-buffer
   unknown key: C-h
   kit-keys: sin implementar
   1
   Uso: kit-keys [TABLA]
   Sin TABLA, las de prefix, root, kit-resize y copy-mode-vi.
   Imprime "TABLA TECLA  NOTA", una tecla por línea.
   2
   ```
   `prefix` `-` es hoy `delete-buffer`, de tmux: el TODO 2 lo pisa (los
   buffers se siguen borrando desde `prefix` `=`, tecla `d`). El uso
   incorrecto de `kit-keys` ya funciona; el resto, en el paso 6. Deja el
   servidor arrancado: después de cada TODO lo recargas con
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; echo $?
   ```
   ```
   0
   ```
   Si sale `1`, el mensaje de encima dice el archivo y la línea.

2. **Notas en lo que ya había (TODO 1, `conf.d/20-bindings.conf`).** Añade
   `-N "kit: ..."` a `C-a`, `r` y las cuatro teclas de copy mode
   (lab-01-bind-unbind-y-list-keys). Sintaxis:
   `bind -N "kit: recarga la config" r source-file ...` y, en otra tabla,
   `bind -T copy-mode-vi -N "kit: copia al portapapeles" y send -X copy-pipe-and-cancel`.
   Recarga y mira las notas de las dos tablas:
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; echo $?
   tmux -L kit list-keys -N -T prefix | grep kit:
   tmux -L kit list-keys -N -T copy-mode-vi
   ```
   ```
   0
   C-a     kit: envía C-a al programa del panel
   r       kit: recarga la config
   C-v    kit: selección rectangular
   Escape kit: sale de copy mode
   v      kit: empieza la selección
   y      kit: copia al portapapeles
   ```
   `list-keys` sin `-N` no enseña la nota: la tecla sigue igual.
   ```bash
   tmux -L kit list-keys -T prefix r
   ```
   ```
   bind-key -T prefix r source-file -F "#{@kit-dir}/tmux.conf" \; display-message "config recargada"
   ```

3. **Splits en el mismo directorio (TODO 2).** Dos líneas, cada una con su
   nota: `bind -N "kit: ..." | split-window -h -c "#{pane_current_path}"`
   y lo mismo con `-` y `split-window -v`. El formato va entre comillas
   dobles: tmux lo expande al pulsar la tecla, en el panel actual.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit list-keys -T prefix '|'
   tmux -L kit list-keys -T prefix -
   ```
   ```
   bind-key -T prefix | split-window -h -c "#{pane_current_path}"
   bind-key -T prefix - split-window -v -c "#{pane_current_path}"
   ```
   Ahora de verdad. En la terminal B:
   ```bash
   cd / && tmux -L kit attach -t api
   ```
   Dentro, escribe `cd /tmp` y `Enter`; después pulsa `C-a` `|` y, en el
   panel nuevo, `C-a` `-`. En la A:
   ```bash
   tmux -L kit list-panes -t api -F '#{pane_index} #{pane_current_path}'
   ```
   ```
   1 /tmp
   2 /tmp
   3 /tmp
   ```
   Sin `-c`, los paneles 2 y 3 abrirían en el directorio de la sesión, el
   `starter/` desde el que la creaste. Cierra los dos nuevos desde la A
   (la B sigue conectada):
   ```bash
   tmux -L kit kill-pane -t api:1.3; tmux -L kit kill-pane -t api:1.2
   ```
   ```
   (sin salida)
   ```

4. **Modo resize (TODOs 3-5).** Es la tabla del lab-03-tablas-propias con
   otro nombre. Pistas:
   - TODO 3: `bind -N "kit: entra en el modo resize" R switch-client -T kit-resize`.
   - TODO 4: `bind -T kit-resize -N "kit: borde a la izquierda (5)" h resize-pane -L 5 \; switch-client -T kit-resize`,
     y `j` `-D`, `k` `-U`, `l` `-R`; `H` `J` `K` `L` igual con `1`. tmux
     devuelve el cliente a `root` **antes** de ejecutar cada tecla de una
     tabla propia: el `switch-client` final lo vuelve a meter.
   - TODO 5: `q`, `Escape` y `Enter` con `switch-client -T root`.

   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit list-keys -T kit-resize h
   tmux -L kit list-keys -T kit-resize q
   ```
   ```
   bind-key -T kit-resize h resize-pane -L 5 \; switch-client -T kit-resize
   bind-key -T kit-resize q switch-client -T root
   ```
   En la B, pulsa `C-a` `|` para tener dos paneles. En la A:
   ```bash
   tmux -L kit list-panes -t api -F '#{pane_index} #{pane_width} #{pane_active}'
   ```
   Algo como (los anchos dependen de tu terminal B; aquí, 80 columnas):
   ```
   1 40 0
   2 39 1
   ```
   En la B, pulsa `C-a` `R`. En la A, la tabla del cliente:
   ```bash
   tmux -L kit list-clients -F '#{client_key_table}'
   ```
   ```
   kit-resize
   ```
   En la B, pulsa `h` tres veces (sin prefix) y una vez `L`: el borde
   se mueve 15 celdas a la izquierda y vuelve 1. En la A:
   ```bash
   tmux -L kit list-clients -F '#{client_key_table}'
   tmux -L kit list-panes -t api -F '#{pane_index} #{pane_width} #{pane_active}'
   ```
   ```
   kit-resize
   1 26 0
   2 53 1
   ```
   Sigues en el modo. Pulsa `q` en la B y repite el `list-clients` en la A:
   ```
   root
   ```
   Prueba también `C-a` `R` y `Escape`: vuelve a `root`. Una tecla que no
   está en la tabla (`x`) también saca del modo, sin hacer nada.

5. **Navegación sin prefix (TODOs 6-8).** Del lab-05-navegacion-consciente.
   1. **TODO 6**, en `conf.d/10-options.conf`: `set -g @kit-nav on`.
      ```bash
      tmux -L kit source-file "$PWD/tmux.conf"
      tmux -L kit show -gv @kit-nav
      ```
      ```
      on
      ```
   2. **TODO 7**, en `conf.d/20-bindings.conf`, cuatro líneas:
      `bind -n -N "kit: panel de la izquierda" C-h if -F '#{||:#{alternate_on},#{!=:#{@kit-nav},on}}' 'send-keys C-h' 'select-pane -L'`,
      y `C-j` `-D`, `C-k` `-U`, `C-l` `-R`. Se lee: "si hay un programa a
      pantalla completa o la navegación está apagada, la tecla es para el
      programa; si no, cambia de panel". `pane_current_command` no sirve:
      con `seq 100 | less` dice `bash`. Y `#{!:...}` no existe en 3.4:
      `#{!:0}` se expande a `!:0`, que cuenta como verdadero.
      ```bash
      tmux -L kit source-file "$PWD/tmux.conf"
      tmux -L kit list-keys -T root C-h
      ```
      ```
      bind-key -T root C-h if-shell -F "#{||:#{alternate_on},#{!=:#{@kit-nav},on}}" "send-keys C-h" "select-pane -L"
      ```
      La B tiene dos paneles con el 2 activo. Pulsa `C-h` en la B y, tras
      cada tecla, mira en la A qué panel está activo:
      ```bash
      tmux -L kit display -p -t api '#{pane_index}'
      ```
      ```
      1
      ```
      Pulsa `C-l`: vuelve a `2`. Ahora, en el panel 2 de la B, escribe
      `seq 100 | less` y `Enter`. En la A:
      ```bash
      tmux -L kit display -p -t api '#{pane_index} #{alternate_on} #{pane_current_command}'
      ```
      ```
      2 1 bash
      ```
      Pulsa `C-h` en la B y repite el `display` de antes, `'#{pane_index}'`:
      sigue `2`; el `C-h` le llegó a `less`. Sal de `less` con `q` y apaga
      la navegación desde la A:
      ```bash
      tmux -L kit set -g @kit-nav off
      ```
      Pulsa `C-h` en la B: el panel sigue siendo el `2`. Enciéndela otra vez:
      ```bash
      tmux -L kit set -g @kit-nav on
      ```
      y `C-h` en la B ya lleva al `1`.
   3. **TODO 8**: en la shell, `C-l` ya no limpia la pantalla, lo atrapa
      tmux. `bind -N "kit: envía C-l (limpia la pantalla)" C-l send-keys C-l`.
      ```bash
      tmux -L kit source-file "$PWD/tmux.conf"
      tmux -L kit list-keys -T prefix C-l
      ```
      ```
      bind-key -T prefix C-l send-keys C-l
      ```
      En la B, `C-a` `C-l` limpia la pantalla del panel activo. (`C-h` es
      también "borrar" en algunas terminales: si tu `Backspace` deja de
      borrar en la shell, tu terminal envía `C-h`; el lab 05 explica cómo
      verlo.)

   Sal de la B con `C-a` `d`: `[detached (from session api)]`.

6. **`bin/kit-keys` (TODOs 9-11).** Al final hay un
   `echo "kit-keys: sin implementar"` y un `exit 1`: se borran en el
   TODO 11.
   1. **TODO 9**, sin servidor. `list-keys` **arranca** un servidor si no
      hay ninguno; `list-sessions` no. Pista:
      `tmx list-sessions >/dev/null 2>&1 || die "no hay servidor de tmux en este socket"`.
      ```bash
      TMUX_SOCKET=nada bin/kit-keys; echo $?
      test -e "${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)/nada"; echo $?
      ```
      ```
      kit-keys: no hay servidor de tmux en este socket
      1
      1
      ```
      El segundo `1` dice que no existe el socket `nada`: no arrancó ningún
      servidor.
   2. **TODO 10**, `list_table`. Lo que hay que leer:
      ```bash
      tmux -L kit list-keys -N -T kit-resize | head -3
      ```
      ```
      Enter  kit: sale del modo resize
      Escape kit: sale del modo resize
      H      kit: borde a la izquierda (1)
      ```
      La tecla es la primera palabra y la nota el resto. Pista:
      `rows=$(tmx list-keys -N -T "$table" 2>/dev/null) || return 1` y un
      `awk -v t="$table"` que guarde `key = $1`, quite la primera palabra
      con `sub(/^[^ ]+ +/, "")` e imprima `printf "%s %s  %s\n", t, key, $0`
      solo si `$0 ~ /^kit:/`.
   3. **TODO 11**, las tablas.
      ```bash
      TMUX_SOCKET=kit bin/kit-keys kit-resize
      TMUX_SOCKET=kit bin/kit-keys nada; echo $?
      TMUX_SOCKET=kit bin/kit-keys | wc -l
      shellcheck bin/*; echo $?
      ```
      ```
      kit-resize Enter  kit: sale del modo resize
      kit-resize Escape  kit: sale del modo resize
      kit-resize H  kit: borde a la izquierda (1)
      kit-resize J  kit: borde abajo (1)
      kit-resize K  kit: borde arriba (1)
      kit-resize L  kit: borde a la derecha (1)
      kit-resize h  kit: borde a la izquierda (5)
      kit-resize j  kit: borde abajo (5)
      kit-resize k  kit: borde arriba (5)
      kit-resize l  kit: borde a la derecha (5)
      kit-resize q  kit: sale del modo resize
      kit-keys: no existe la tabla nada
      1
      25
      0
      ```
      `TMUX_SOCKET=kit bin/kit-keys` sin tabla empieza por
      `prefix C-a  kit: envía C-a al programa del panel` y termina por
      `copy-mode-vi y  kit: copia al portapapeles`.

7. **Ninguna tecla sin nota.** El autograding compara las teclas de tmux
   sin config con las del kit: todo lo que el kit añade o cambia tiene que
   tener nota `kit:`. Hazlo tú:
   ```bash
   d=$(mktemp -d)
   tmux -L vacio -f /dev/null new -d; tmux -L vacio list-keys | tr -s " " > "$d/defecto"; tmux -L vacio kill-server
   tmux -L kit list-keys | tr -s " " | grep -vxFf "$d/defecto" | wc -l
   ```
   ```
   24
   ```
   Son 24 y `kit-keys` lista 25: `copy-mode-vi` `C-v` hace lo mismo que la
   de tmux (`rectangle-toggle`) y no cuenta como cambio, pero tiene nota.
   Si te salen más de 24, quita el `| wc -l` para verlas y busca la que
   falta en `kit-keys`. Mira también todas las notas en la B: conéctate otra
   vez (`tmux -L kit attach -t api`), pulsa `C-a` `?` y sal con `q`.

8. **README del kit.** En `starter/README.md`: una sección `## Teclas` con
   los splits, el modo resize, `C-h/j/k/l`, `prefix` `C-l` y cómo apagar la
   navegación con `@kit-nav`; la fila de `bin/kit-keys` en la tabla de
   scripts; `20-bindings.conf` en la tabla de estructura; y la fila `06` en
   la bitácora.

9. **Cierra y verifica.** El `kill-server` expulsa a la B si seguía
   conectada (`[server exited]`). En la terminal A:
   ```bash
   tmux -L kit kill-server
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 06
   ```
   ```
   Semana 06 — Key bindings, tablas y navegación

     ✅ tmux.conf carga sin errores
     ✅ prefix | divide a la derecha en el directorio del panel
     ✅ prefix - divide debajo en el directorio del panel
     ✅ prefix R mete al cliente en la tabla kit-resize
     ✅ En kit-resize, h redimensiona el panel y el cliente sigue en kit-resize
     ✅ q y Escape devuelven el cliente a la tabla root
     ✅ C-h sin prefix cambia al panel de la izquierda en la shell
     ✅ C-l llega al programa cuando el panel está a pantalla completa
     ✅ Con @kit-nav off, C-l ya no cambia de panel
     ✅ prefix C-l envía C-l al programa del panel
     ✅ Todas las teclas que el kit añade o cambia tienen una nota kit:
     ✅ kit-keys sale con 2 si recibe más de una tabla
     ✅ kit-keys kit-resize lista h con su nota
     ✅ kit-keys sin argumentos lista las teclas del kit de prefix y root
     ✅ kit-keys sale con 1 sin servidor y no arranca ninguno
     ✅ tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

   16/16 comprobaciones superadas.
   ```
   Tarda un minuto y medio: varias comprobaciones conectan un cliente y
   pulsan las teclas de verdad (`send-keys -K`). Cada fallo trae una pista
   al paso que lo arregla.

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-06-key_bindings_tablas_y_navegacion/3-proyecto/starter"
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
tmux -L kit show -gv @kit-nav
tmux -L kit list-keys -T prefix R
TMUX_SOCKET=kit bin/kit-keys root
tmux -L kit kill-server
```
```
0
on
bind-key -T prefix R switch-client -T kit-resize
root C-h  kit: panel de la izquierda
root C-j  kit: panel de abajo
root C-k  kit: panel de arriba
root C-l  kit: panel de la derecha
```
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 06
```
```
16/16 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 06` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] prefix | divide a la derecha en el directorio del panel
- [ ] prefix - divide debajo en el directorio del panel
- [ ] prefix R mete al cliente en la tabla kit-resize
- [ ] En kit-resize, h redimensiona el panel y el cliente sigue en kit-resize
- [ ] q y Escape devuelven el cliente a la tabla root
- [ ] C-h sin prefix cambia al panel de la izquierda en la shell
- [ ] C-l llega al programa cuando el panel está a pantalla completa
- [ ] Con @kit-nav off, C-l ya no cambia de panel
- [ ] prefix C-l envía C-l al programa del panel
- [ ] Todas las teclas que el kit añade o cambia tienen una nota kit:
- [ ] kit-keys sale con 2 si recibe más de una tabla
- [ ] kit-keys kit-resize lista h con su nota
- [ ] kit-keys sin argumentos lista las teclas del kit de prefix y root
- [ ] kit-keys sale con 1 sin servidor y no arranca ninguno
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Teclas agrupadas por función en `20-bindings.conf` (prefix, recarga, splits, resize, navegación, copy mode) y alineadas para leerse como tabla.
- Comentarios del porqué: por qué cada tecla de `kit-resize` vuelve a entrar en la tabla, por qué `alternate_on` y no `pane_current_command`, qué tecla de tmux pisas (`prefix` `-`) y qué cuesta robar `C-l` a la shell.
- Notas `kit:` cortas que dicen qué hace la tecla, no cómo.
- `kit-keys` explica en un comentario por qué pregunta con `list-sessions` antes de `list-keys`; errores por stderr con los códigos documentados.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.

## Entrega

Commit con el mensaje:
```
feat(week-06): modo resize, navegación C-h/j/k/l, notas kit: y kit-keys
```
