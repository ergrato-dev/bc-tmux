# Lab 04 — Recarga en caliente

⏱ Duración estimada: ~60 min

## Objetivo

Recargar la config con `C-b` `r` sin cerrar nada y escribirla de forma que recargar dos veces dé el mismo resultado, comprobándolo con un script.

## Contexto

- `source-file` ejecuta la config **encima** del estado actual: no vuelve a los valores por defecto antes.
- Por eso, lo que borras de la config sigue activo, y lo que añades con `-a` se añade otra vez en cada recarga.
- Una config está bien escrita si recargarla diez veces deja lo mismo que recargarla una.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En la
   terminal A, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-04-recarga-en-caliente
   ```
   La B no necesita `cd`: se conecta desde `/` a propósito. El servidor es
   `-L lab` y el starter no fija prefix, así que es **`C-b`**.

1. **Arranca** con el starter (ruta absoluta: `@lab-dir` sale de ella) y
   mira qué hace hoy `C-b` `r` (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d
   tmux -L lab show -gv @lab-dir
   tmux -L lab list-keys -T prefix r
   ```
   Algo como (la ruta es la de tu repositorio):
   ```
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-04-recarga-en-caliente/starter
   bind-key -T prefix r refresh-client
   ```
   Por defecto, `r` vuelve a dibujar la pantalla. No recarga nada.

2. **TODO 1: la tecla.** Al final de `starter/tmux.conf`, debajo del
   comentario `TODO 1`, añade:
   ```tmux
   bind r source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```
   `-F` expande `#{@lab-dir}` **al pulsar** la tecla, así que funciona estés
   en el directorio que estés. El servidor ya está arrancado: carga el
   cambio a mano una vez (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T prefix r
   ```
   ```
   0
   bind-key -T prefix r source-file -F "#{@lab-dir}/tmux.conf" \; display-message "config recargada"
   ```
   Ahora conéctate desde otro directorio, en la terminal B:
   ```bash
   cd / && tmux -L lab attach
   ```
   Pulsa `C-b` `r`: la barra (arriba, por `status-position top`) muestra
   `config recargada` durante un segundo. Si `source-file` no encontrara el
   archivo, verías `…/tmux.conf: No such file or directory` en su lugar. Si
   el archivo tiene un **error dentro**, el mensaje sale igual y el error no
   se ve: después de editar, compruébalo en la terminal A con
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?`.
   Deja la B conectada.

3. **Borrar no deshace.** En la terminal A, abre `starter/tmux.conf` con tu
   editor, borra la línea `set -g  status-position top` y guarda. En la B,
   pulsa `C-b` `r`: `config recargada`, y la barra **sigue arriba**. En A:
   ```bash
   tmux -L lab show -gv status-position
   ```
   ```
   top
   ```
   Nadie volvió a poner `bottom`. Para deshacerlo sin reiniciar:
   ```bash
   tmux -L lab set -gu status-position
   tmux -L lab show -gv status-position
   ```
   ```
   bottom
   ```
   En la B, la barra baja. Lo mismo con las teclas: borrar un `bind` de la
   config deja la tecla puesta hasta un `unbind` o un `kill-server`.

4. **Añadir se acumula.** Para contar desde cero, reinicia el servidor. El
   `kill-server` expulsa a la B (`[server exited]`). En la terminal A:
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d
   ```
   En la B, `cd / && tmux -L lab attach` y pulsa `C-b` `r` **tres veces**.
   En A:
   ```bash
   tmux -L lab show -g update-environment | tail -4
   ```
   ```
   update-environment[8] WAYLAND_DISPLAY
   update-environment[9] WAYLAND_DISPLAY
   update-environment[10] WAYLAND_DISPLAY
   update-environment[11] WAYLAND_DISPLAY
   ```
   Uno del arranque y uno por cada recarga: cada vez se ejecuta `set -ga`
   otra vez. Arréglalo para que la línea dé el mismo resultado siempre: en
   `starter/tmux.conf`, justo **encima** de `set -ga update-environment
   WAYLAND_DISPLAY`, añade la línea que devuelve la lista a su valor por
   defecto:
   ```tmux
   set -gu update-environment
   set -ga update-environment WAYLAND_DISPLAY
   ```
   Guarda, pulsa `C-b` `r` tres veces en la B y mira en A:
   ```bash
   tmux -L lab show -g update-environment | tail -3
   ```
   ```
   update-environment[6] WINDOWID
   update-environment[7] XAUTHORITY
   update-environment[8] WAYLAND_DISPLAY
   ```
   Un solo `WAYLAND_DISPLAY`. Sal de la B con `C-b` `d`:
   `[detached (from session 0)]`.

5. **Comprobarlo con un script.** `starter/comparar-recarga.sh CONF`
   recarga dos veces, compara el estado de las dos y enseña la diferencia.
   Habla con el servidor `-L lab` (o con `TMUX_SOCKET`, si la defines), que
   tiene que estar arrancado. Al final del archivo hay un
   `echo "sin implementar"` y un `exit 1`: se borran en el TODO 4. Si no lo
   tienes: `sudo apt install shellcheck` (macOS: `brew install shellcheck`).

   Para ver el fallo, vuelve a dejar la config **rota**: pon un `#` delante
   de `set -gu update-environment` y guarda.

   1. **TODO 1: hay servidor.** Pista:
      `tmx list-sessions >/dev/null 2>&1 || { echo "comparar-recarga.sh: no hay servidor en el socket ${TMUX_SOCKET:-lab}" >&2; exit 1; }`.
      Prueba contra un socket vacío:
      ```bash
      TMUX_SOCKET=nada ./starter/comparar-recarga.sh "$PWD/starter/tmux.conf"; echo $?
      ```
      ```
      comparar-recarga.sh: no hay servidor en el socket nada
      1
      ```
   2. **TODO 2: la función `estado`.** Pista:
      `estado() { tmx show -s; tmx show -g; tmx show -gw; tmx list-keys; }`:
      opciones de los tres alcances y todas las teclas. Prueba lo mismo a
      mano, contando líneas:
      ```bash
      { tmux -L lab show -s; tmux -L lab show -g; tmux -L lab show -gw; tmux -L lab list-keys; } | wc -l
      ```
      Algo como (depende de cuántas recargas lleves): `398`.
   3. **TODO 3: dos recargas.** Pista: `tmx source-file "$conf"`,
      `antes=$(estado)`, otra vez `tmx source-file "$conf"`,
      `despues=$(estado)`. La primera recarga es la referencia: arrancar y
      recargar pueden diferir con razón (un `unbind` de algo que ya no
      está); recargar y recargar, no. Prueba que recarga dos veces:
      ```bash
      tmux -L lab show -g update-environment | tail -1
      ./starter/comparar-recarga.sh "$PWD/starter/tmux.conf"
      tmux -L lab show -g update-environment | tail -1
      ```
      Algo como (los números dependen de las recargas anteriores; la
      segunda es dos más):
      ```
      update-environment[8] WAYLAND_DISPLAY
      comparar-recarga.sh: sin implementar (/bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-04-recarga-en-caliente/starter/tmux.conf)
      update-environment[10] WAYLAND_DISPLAY
      ```
   4. **TODO 4: el veredicto.** Pista: si `[[ "$antes" == "$despues" ]]`,
      imprime `idéntico: recargar CONF no cambia nada`; si no,
      `diff <(printf '%s\n' "$antes") <(printf '%s\n' "$despues") || true`
      y `exit 1` (el `|| true` evita que `set -e` corte antes del `exit`).
      Borra el `echo "sin implementar"` y el `exit 1`. Con la config rota:
      ```bash
      ./starter/comparar-recarga.sh "$PWD/starter/tmux.conf"; echo $?
      ```
      Algo como (cambian el número de línea y el índice):
      ```
      82a83
      > update-environment[12] WAYLAND_DISPLAY
      1
      ```
      Quita el `#` de `set -gu update-environment`, guarda y repite:
      ```bash
      ./starter/comparar-recarga.sh "$PWD/starter/tmux.conf"; echo $?
      shellcheck starter/comparar-recarga.sh; echo $?
      ```
      Algo como:
      ```
      idéntico: recargar /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-04-recarga-en-caliente/starter/tmux.conf no cambia nada
      0
      0
      ```
   El autograding del proyecto hace la misma comprobación con tu kit.
   Referencia: `solucion/comparar-recarga.sh`.

6. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `tmux -L lab list-keys -T prefix r` muestra `source-file -F` con `@lab-dir` (paso 2)
- [ ] `C-b` `r` muestra `config recargada` en un cliente conectado desde `/` (paso 2)
- [ ] Explicas por qué la barra seguía arriba en el paso 3 y lo deshaces sin reiniciar
- [ ] Tras tres recargas con la línea arreglada, `show -g update-environment` tiene un solo `WAYLAND_DISPLAY` (paso 4)
- [ ] `comparar-recarga.sh` sale con 1 y muestra la línea repetida en la config rota, y con 0 en la arreglada (paso 5.4)
- [ ] `shellcheck starter/comparar-recarga.sh` sale con 0 sin avisos (paso 5.4)

## Reto extra

Tras varias recargas seguidas no sabes si el mensaje es el de ahora o el de
antes. Haz que diga la hora: `display` interpreta los formatos de `strftime`,
como `%H:%M:%S`. Añade también cuántas sesiones hay, con un formato de
tmux (`#{server_sessions}`).
