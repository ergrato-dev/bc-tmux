# Proyecto Semana 05 — tmux-kit: config modular y recarga en caliente

⏱ Duración estimada: ~3 h

## Contexto

Tu `tmux.conf` de la semana 04 tiene veinte líneas. Dentro de tres semanas tendrá ciento cincuenta: status line, teclas de navegación, terminal. Si todo sigue en un archivo, cada cambio es buscar entre líneas que no recuerdas por qué están, y cada `prefix` `r` es rezar para no duplicar nada. Además, te has dado cuenta de que no sabes de dónde sale el valor de una opción cuando un panel se comporta distinto que los demás.

Esta semana tu kit pasa a ser **modular**: un `tmux.conf` que solo carga `conf.d/`, opciones agrupadas por alcance, un prefix elegido por ti, una recarga que no duplica nada y **`bin/kit-option`**, que te dice qué valor tiene una opción y de qué nivel sale.

```bash
$ kit-option remain-on-exit api:1.2
on (panel)
$ kit-option escape-time api
10 (servidor)
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                 ← tu tmux-kit de la semana 04 + lo nuevo
├── README.md            ← añade la estructura, tu prefix, kit-option y la bitácora
├── .gitignore           ← local.conf
├── tmux.conf            ← hoy, la config de la semana 04 (TODO 1); al terminar, solo el punto de entrada
├── conf.d/
│   ├── 10-options.conf ← TODOs 2-6
│   └── 20-bindings.conf ← TODOs 7-9
└── bin/
    ├── check-version, kit-tree, kit-layout, sesiones, kit-copy   (semanas 01-04)
    └── kit-option       ← TODOs 10-12 (nuevo)
```

## Lo que debes construir

1. **`tmux.conf`**: solo el punto de entrada. Guarda su directorio en `@kit-dir`, carga `conf.d/*.conf` con `source-file -F` y, si existe, `local.conf` con `source-file -qF`. Ningún otro `set` ni `bind`: la config carga entera arranques tmux desde donde arranques.
2. **`conf.d/10-options.conf`**: todas las opciones, agrupadas por alcance y con su flag explícito (`-s`, `-g`, `setw -g`). Lo que traías de la semana 04 (`mode-keys`, `history-limit`, `set-clipboard` y `copy-command`, ahora con `#{@kit-dir}/bin/kit-copy`) y lo nuevo: `escape-time` de 20 ms o menos, `base-index`, `pane-base-index`, `renumber-windows`, `mouse` y `WAYLAND_DISPLAY` en `update-environment` sin que recargar lo duplique.
3. **`conf.d/20-bindings.conf`**: tu prefix (no `C-b`) con un comentario del porqué; `C-b` liberada; tu prefix dos veces llega al programa del panel; `prefix` `r` recarga `#{@kit-dir}/tmux.conf` y muestra `config recargada`; las teclas de copy mode de la semana 04.
4. **Recarga**: recargar dos veces deja exactamente las mismas opciones y teclas.
5. **`bin/kit-option OPCION [TARGET]`**: imprime `VALOR (NIVEL)`, con `NIVEL` en `panel`, `ventana`, `sesión`, `global` o `servidor`: el primer nivel, del más concreto al más general, en el que la opción está fijada. `TARGET` es un panel; dentro de tmux, por defecto el actual (`$TMUX_PANE`). Sale con **1** si el target o la opción no existen y con **2** si el uso es incorrecto.
6. **README del kit** con la nueva estructura, cómo probarlo sin instalarlo, tu prefix y por qué, `kit-option` en la tabla y la bitácora de la semana.

## Paso a paso

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En la A,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/3-proyecto/starter
   ```
   Todo va contra un servidor aparte, `-L kit`, siempre con ruta absoluta
   (`@kit-dir` sale de ella). Hasta el TODO 7 el kit no fija prefix: es
   `C-b`. Los ejemplos usan `C-a` como tu prefix; cámbialo por el tuyo. Si
   no lo tienes: `sudo apt install shellcheck` (macOS:
   `brew install shellcheck`).

1. **Punto de partida.** Lo que hace hoy el kit de la semana 04:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s api \; show -gv prefix \; show -gv mouse \; show -sv escape-time
   tmux -L kit kill-server
   ```
   ```
   C-b
   off
   500
   ```

2. **`conf.d/10-options.conf` (TODOs 2-6).** Escribe cada TODO debajo de
   su comentario. Las líneas que dicen "trae" se **mueven** de `tmux.conf`
   (bórralas allí; el TODO 1 lo deja vacío). Pruébalo solo, en un servidor
   sin config, con `@kit-dir` puesto a mano (lo que hará `tmux.conf`):
   ```bash
   tmux -L kit kill-server 2>/dev/null
   tmux -L kit -f /dev/null new -d -s api \; set -g @kit-dir "$PWD" \; source-file "$PWD/conf.d/10-options.conf"; echo $?
   ```
   ```
   0
   ```
   Si sale `1`, el mensaje de encima dice qué línea falla. Después, cada
   TODO:
   1. **TODO 2**, `escape-time`:
      ```bash
      tmux -L kit show -sv escape-time
      ```
      ```
      10
      ```
   2. **TODO 3**, portapapeles. Desde un módulo, `#{d:current_file}`
      apuntaría a `conf.d/`: por eso la ruta sale de `@kit-dir`.
      ```bash
      tmux -L kit show -sv set-clipboard
      test -x "$(tmux -L kit show -sv copy-command)"; echo $?
      ```
      ```
      on
      0
      ```
   3. **TODO 4**, sesión (pista: `set -g base-index 1`,
      `set -g renumber-windows on`, `set -g history-limit 50000`,
      `set -g mouse on`):
      ```bash
      tmux -L kit show -gv base-index \; show -gv renumber-windows \; show -gv history-limit \; show -gv mouse
      ```
      ```
      1
      on
      50000
      on
      ```
   4. **TODO 5**, `update-environment`. Recarga el módulo dos veces más y
      mira el final de la lista:
      ```bash
      tmux -L kit source-file "$PWD/conf.d/10-options.conf"
      tmux -L kit source-file "$PWD/conf.d/10-options.conf"
      tmux -L kit show -g update-environment | tail -2
      ```
      ```
      update-environment[7] XAUTHORITY
      update-environment[8] WAYLAND_DISPLAY
      ```
      Con un solo `set -ga`, verías `[8]`, `[9]` y `[10]` (lab 04, paso 4).
   5. **TODO 6**, ventana:
      ```bash
      tmux -L kit show -gwv mode-keys \; show -gwv pane-base-index
      ```
      ```
      vi
      1
      ```

3. **`conf.d/20-bindings.conf` (TODOs 7-9).** Igual: servidor sin config y
   solo este módulo.
   ```bash
   tmux -L kit kill-server
   tmux -L kit -f /dev/null new -d -s api \; set -g @kit-dir "$PWD" \; source-file "$PWD/conf.d/20-bindings.conf"; echo $?
   ```
   ```
   0
   ```
   1. **TODO 7**, prefix (lab 02):
      ```bash
      tmux -L kit show -gv prefix
      tmux -L kit list-keys -T prefix C-a
      tmux -L kit list-keys -T prefix C-b
      ```
      ```
      C-a
      bind-key -T prefix C-a send-prefix
      unknown key: C-b
      ```
   2. **TODO 8**, recarga (lab 04):
      ```bash
      tmux -L kit list-keys -T prefix r
      ```
      ```
      bind-key -T prefix r source-file -F "#{@kit-dir}/tmux.conf" \; display-message "config recargada"
      ```
   3. **TODO 9**, copy mode (las cuatro líneas de la semana 04):
      ```bash
      tmux -L kit list-keys -T copy-mode-vi y
      ```
      ```
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      ```

4. **`tmux.conf` (TODO 1).** Ya no queda ninguna opción ni tecla en él
   (las moviste en los pasos 2 y 3). Debajo de los comentarios, tres líneas,
   cada una con un comentario del porqué:
   ```tmux
   set -gF @kit-dir "#{d:current_file}"
   source-file -F "#{@kit-dir}/conf.d/*.conf"
   source-file -qF "#{@kit-dir}/local.conf"
   ```
   Arranca el kit entero desde `/` y pide los errores de arranque:
   ```bash
   tmux -L kit kill-server
   (cd / && tmux -L kit -f "$OLDPWD/tmux.conf" new -d -s api)
   tmux -L kit source-file /dev/null; echo $?
   tmux -L kit show -gv prefix \; show -gv base-index \; show -sv escape-time
   ```
   ```
   0
   C-a
   1
   10
   ```
   Ningún error encima del `0`. (`$OLDPWD`, dentro del paréntesis, es
   `starter/`.)

5. **`prefix` `r` de verdad.** En la terminal B, desde otro directorio:
   ```bash
   cd / && tmux -L kit attach -t api
   ```
   En la terminal A, estropea una opción a mano:
   ```bash
   tmux -L kit set -g base-index 7
   ```
   En la B, pulsa `C-a` `r`: la barra muestra `config recargada`. En A:
   ```bash
   tmux -L kit show -gv base-index
   ```
   ```
   1
   ```
   La tecla recargó el kit aunque el cliente esté en `/`. Sal de la B con
   `C-a` `d`: `[detached (from session api)]`.

6. **Recarga idempotente.** Con el script del lab 04 (el tuyo,
   `../../2-practicas/lab-04-recarga-en-caliente/starter/compare-reload.sh`,
   o el de la solución):
   ```bash
   TMUX_SOCKET=kit ../../2-practicas/lab-04-recarga-en-caliente/solucion/compare-reload.sh "$PWD/tmux.conf"; echo $?
   ```
   Algo como (la ruta es la de tu repositorio):
   ```
   idéntico: recargar /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/3-proyecto/starter/tmux.conf no cambia nada
   0
   ```
   Si sale un `diff`, la línea marcada con `>` es la que se añade en cada
   recarga.

7. **`bin/kit-option` (TODOs 10-12).** Es `scope.sh` del lab 03 ampliado a
   cinco niveles (referencia:
   `../../2-practicas/lab-03-alcances-y-herencia/solucion/scope.sh`). Al
   final hay un `echo "sin implementar"` y un `exit 1`: se borran en el
   TODO 12. Prepara una ventana con dos paneles y un valor en cada nivel:
   ```bash
   tmux -L kit split-window -d -t api:1
   tmux -L kit set -p -t api:1.2 remain-on-exit on
   tmux -L kit set -w -t api:1 automatic-rename off
   tmux -L kit list-panes -t api:1 -F '#{pane_index}'
   ```
   ```
   1
   2
   ```
   (Desde aquí, el autograding y tus pruebas hablan con este servidor por
   `TMUX_SOCKET=kit`.)
   1. **TODO 10**, el target (pista: `list-panes -t "$target"`, como
      `scope.sh`):
      ```bash
      TMUX_SOCKET=kit bin/kit-option base-index api:nada; echo $?
      TMUX_SOCKET=kit bin/kit-option base-index api; echo $?
      ```
      ```
      kit-option: no existe el panel api:nada
      1
      kit-option: sin implementar (base-index en api)
      1
      ```
   2. **TODO 11**, `value`. La tubería es la de `scope.sh`; pruébala suelta
      con la lista del servidor:
      ```bash
      tmux -L kit show -s | awk -v o=escape-time '$1 == o { sub(/^[^ ]+ /, ""); print; f = 1; exit } END { exit !f }'; echo $?
      ```
      ```
      10
      0
      ```
      En el script lleva `2>/dev/null` tras `show`: con `-p` o `-w`, un
      error no debe ensuciar la salida.
   3. **TODO 12**, los niveles. Pista: una cadena
      `if v=$(value -s); then level=servidor elif v=$(value -p -t "$target"); then level=panel ...`
      hasta `elif v=$(value -gw) || v=$(value -g); then level=global`, y al
      final `echo "$v ($level)"`. `-s` va primero: una opción de servidor
      solo existe en ese nivel.
      ```bash
      TMUX_SOCKET=kit bin/kit-option escape-time api
      TMUX_SOCKET=kit bin/kit-option remain-on-exit api:1.2
      TMUX_SOCKET=kit bin/kit-option automatic-rename api:1.1
      TMUX_SOCKET=kit bin/kit-option base-index api
      tmux -L kit set -t api base-index 3
      TMUX_SOCKET=kit bin/kit-option base-index api
      TMUX_SOCKET=kit bin/kit-option no-existe api; echo $?
      bin/kit-option base-index; echo $?
      ```
      ```
      10 (servidor)
      on (panel)
      off (ventana)
      1 (global)
      3 (sesión)
      kit-option: la opción no-existe no existe o no tiene valor
      1
      kit-option: fuera de tmux, indica el TARGET
      2
      ```
      Un límite conocido: las opciones de **lista** salen en `show` como
      `nombre[N]`, así que hay que pedirlas con el índice:
      ```bash
      TMUX_SOCKET=kit bin/kit-option update-environment api; echo $?
      TMUX_SOCKET=kit bin/kit-option 'update-environment[8]' api
      ```
      ```
      kit-option: la opción update-environment no existe o no tiene valor
      1
      WAYLAND_DISPLAY (global)
      ```
      Explícalo en un comentario del script. Por último:
      ```bash
      shellcheck bin/*; echo $?
      ```
      ```
      0
      ```

8. **README del kit.** En `starter/README.md`: una sección `## Estructura`
   (qué contiene `tmux.conf`, cada `conf.d/` y `local.conf`), cómo probar
   el kit sin instalarlo (`tmux -L kit -f "$PWD/tmux.conf"`), una sección
   `## Prefix` con el tuyo y por qué, la fila de `bin/kit-option` en la
   tabla de scripts y la fila `05` en la bitácora.

9. **Cierra y verifica.** El `kill-server` expulsa a la B si seguía
   conectada (`[server exited]`). En la terminal A:
   ```bash
   tmux -L kit kill-server
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 05
   ```
   ```
   Semana 05 — Configuración y alcance de opciones

     ✅ tmux.conf carga sin errores
     ✅ tmux.conf no define opciones ni teclas: carga conf.d/
     ✅ Las opciones viven en conf.d/10-options.conf
     ✅ Las teclas viven en conf.d/20-bindings.conf
     ✅ La config carga entera aunque arranques tmux desde otro directorio
     ✅ El prefix ya no es C-b
     ✅ El prefix pulsado dos veces llega al programa del panel
     ✅ C-b ya no tiene ninguna función en la tabla prefix
     ✅ escape-time es de 20 ms o menos
     ✅ prefix r recarga la config del kit desde cualquier directorio
     ✅ Recargar la config dos veces no cambia ninguna opción ni tecla
     ✅ update-environment incluye WAYLAND_DISPLAY
     ✅ copy-command sigue apuntando a bin/kit-copy
     ✅ kit-option dice que un valor viene del panel
     ✅ kit-option dice que un valor viene de la ventana
     ✅ kit-option dice que un valor heredado viene de global
     ✅ kit-option reconoce las opciones de servidor
     ✅ tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

   18/18 comprobaciones superadas.
   ```
   Cada fallo trae una pista al paso de lab que lo explica.

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 05` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] tmux.conf no define opciones ni teclas: carga conf.d/
- [ ] Las opciones viven en conf.d/10-options.conf
- [ ] Las teclas viven en conf.d/20-bindings.conf
- [ ] La config carga entera aunque arranques tmux desde otro directorio
- [ ] El prefix ya no es C-b
- [ ] El prefix pulsado dos veces llega al programa del panel
- [ ] C-b ya no tiene ninguna función en la tabla prefix
- [ ] escape-time es de 20 ms o menos
- [ ] prefix r recarga la config del kit desde cualquier directorio
- [ ] Recargar la config dos veces no cambia ninguna opción ni tecla
- [ ] update-environment incluye WAYLAND_DISPLAY
- [ ] copy-command sigue apuntando a bin/kit-copy
- [ ] kit-option dice que un valor viene del panel
- [ ] kit-option dice que un valor viene de la ventana
- [ ] kit-option dice que un valor heredado viene de global
- [ ] kit-option reconoce las opciones de servidor
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Cada opción con su flag de alcance explícito y en el bloque de su alcance.
- Comentarios del porqué: `@kit-dir` y `-F`, el orden de `conf.d/`, `escape-time`, `-gu` antes de `-ga`, tu prefix.
- `kit-option` explica en un comentario por qué lista los niveles sin nombre de opción y el límite de las opciones de lista; mensajes de error por stderr con los códigos documentados.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- `local.conf` en `.gitignore` y ninguna ruta a tu home dentro del kit.

## Entrega

Commit con el mensaje:
```
feat(week-05): tmux.conf modular con conf.d/, recarga idempotente y kit-option
```
