# Proyecto Semana 10 — tmux-kit: popup de proyectos, menú y log de paneles

⏱ Duración estimada: ~3 h

## Contexto

`bin/dev-up` ya te deja cada proyecto en su sesión, pero para usarlo sales de tmux o abres una ventana, escribes la ruta entera y vuelves. Con doce repositorios en `~/src`, te acuerdas del nombre de tres. Y cuando un compañero te pide «pásame lo que salió en la terminal» al reproducir un fallo, ya es tarde: el scroll se perdió o el error estaba en un panel que cerraste.

Esta semana el kit gana interfaz dentro de tmux. **`prefix` `P`** abre un popup con tus proyectos en fzf: eliges uno y `dev-up` te cambia a su sesión. **`prefix` `K`** abre el menú del kit: abrir proyecto, cerrar la sesión (con confirmación), log del panel y los interruptores de las semanas 06 y 07. **`bin/kit-log`** guarda todo lo que sale en un panel con `pipe-pane`, y con `@kit-autolog on` lo hace un hook en cada panel nuevo. Ninguna ruta, nombre de proyecto ni de sesión llega a una shell como código.

```
$ TMUX_SOCKET=kit bin/kit-projects -l
api
web
$ TMUX_SOCKET=kit bin/kit-log kit:1.1
kit-log: on %0 -> /tmp/kit-demo/state/tmux-kit/logs/kit-1-1.log
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                   ← tu tmux-kit de la semana 09 + lo nuevo
├── README.md              ← añade kit-projects, kit-log, las teclas y la bitácora
├── .gitignore             ← local.conf
├── tmux.conf              ← sin cambios
├── conf.d/
│   ├── 10-options.conf, 20-bindings.conf, 40-terminal.conf     (sin cambios)
│   ├── 30-status.conf     ← TODO 9 (indicador LOG)
│   └── 50-hooks-popups.conf  ← TODOs 1, 4, 7 y 8 (nuevo)
├── docs/diagnostico.md    ← sin cambios
└── bin/
    ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option,
    │   kit-keys, kit-git-branch, kit-doctor, dev-up, dev-down   (semanas 01-09)
    ├── kit-log            ← TODOs 2 y 3 (nuevo)
    └── kit-projects       ← TODOs 5 y 6 (nuevo)
```

## Lo que debes construir

1. **`bin/kit-log [PANEL]`**: cada llamada abre o cierra el log del panel (por defecto, `$TMUX_PANE`).
   - Sale con **2** con uso incorrecto (más de un argumento, una opción, fuera de tmux sin `PANEL`) y con **1** si el panel no existe (`no existe el panel`).
   - Log en `${XDG_STATE_HOME:-~/.local/state}/tmux-kit/logs/SESION-VENTANA-PANEL.log`, añadiendo al final. En el nombre, la sesión solo conserva letras, cifras, `_` y `-`.
   - Una ruta con `'`, `#` o `$(...)` no ejecuta nada ni se expande.
2. **`bin/kit-projects [-d] [PROYECTO]` / `kit-projects -l`**:
   - Proyectos: los subdirectorios de `@kit-projects-dir` (por defecto `~/src`), sin ocultos ni archivos, en orden `LC_ALL=C`. `-l` los lista.
   - Sin `PROYECTO`, eliges con fzf; sin fzf, con una lista numerada. Cancelar sale con 0.
   - Abre con `dev-up` (`-d`: sin conectarse). Un nombre que no está en la lista (`..`) sale con **1**; directorio inexistente, **1**; uso incorrecto, **2**.
3. **`conf.d/50-hooks-popups.conf`**:
   - Hooks con índice fijo `[50]`: `client-attached` muestra un mensaje; `after-new-window`, `after-split-window` y `session-created` abren el log si `@kit-autolog` vale `on`. Recargar no los duplica.
   - `prefix` `P`: popup `-EE` con `kit-projects`. `prefix` `K`: menú del kit. Las dos con nota `kit:`.
4. **`LOG`** en la etiqueta de la ventana cuando su panel activo tiene log.
5. **README del kit** con las filas nuevas, las teclas, una sección de hooks y popups y la fila `10` en la bitácora.

## Paso a paso

0. **Dónde.** Una terminal **fuera de tmux** (`echo "$TMUX"` no imprime nada),
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/3-proyecto/starter
   mkdir -p /tmp/kit-demo/src/api /tmp/kit-demo/src/web /tmp/kit-demo/src/.oculto
   touch /tmp/kit-demo/src/notas.txt
   export XDG_STATE_HOME=/tmp/kit-demo/state
   ```
   Todo va contra `-L kit`. El `export` hace que los logs de prueba no
   acaben en tu `~/.local/state`; arranca el servidor **después** de
   exportarlo (los hooks heredan el entorno del servidor). Si algo se queda a
   medias, `tmux -L kit kill-server` y repite el paso.

1. **Punto de partida.** La config carga y los dos scripts nuevos ya analizan
   sus argumentos:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
   TMUX_SOCKET=kit bin/kit-log; echo $?
   TMUX_SOCKET=kit bin/kit-projects -x 2>&1 | head -1; echo $?
   TMUX_SOCKET=kit bin/kit-projects -l; echo $?
   ```
   ```
   0
   kit-log: fuera de tmux, indica el PANEL
   2
   Uso: kit-projects [-d] [PROYECTO]
   0
   kit-projects: sin implementar (-l=1 -d=0 )
   1
   ```
   (El `0` del tercero es de `head`.) Como en la semana 09, mueve las líneas
   de «sin implementar» al final según avanzas.

2. **Hooks sin duplicar (TODO 1, `conf.d/50-hooks-popups.conf`).** Del
   lab-01-hooks y el lab-06-hooks-rotos.
   ```tmux
   set-hook -g client-attached[50] {
     display-message -d 2000 "kit: #{session_name} (#{session_windows} ventanas)"
   }
   ```
   Los hooks son opciones de lista. `set-hook -ga` añade una entrada nueva en
   cada `prefix` `r` (el mensaje saldría dos, tres veces); sin `-a`, escribe
   siempre en `[0]`, que es también donde caería el de tu `local.conf`. Un
   índice fijo propio sustituye siempre la misma entrada. Las llaves `{ }`
   evitan una capa de comillas.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show-hooks -g client-attached
   ```
   ```
   client-attached[50] display-message -d 2000 "kit: #{session_name} (#{session_windows} ventanas)"
   ```
   En 3.4, dentro de `client-attached`, `#{hook_session_name}` sale vacío:
   `#{session_name}` y `#{hook_client}` sí traen valor.

3. **`kit-log` (TODOs 2 y 3, `bin/kit-log`).** Del lab-04-run-shell-y-pipe-pane.
   - Valida con `tmx list-panes -t "$pane"`: `display-message -p -t %99`
     sale con 0 y campos vacíos.
   - Un solo `display-message -p` con `#{pane_id}`, `#{pane_pipe}`,
     `#{session_name}`, `#{window_index}` y `#{pane_index}` separados por
     tabuladores, y `IFS=$'\t' read -r id piped session window index`.
   - Con `piped` a 1: `tmx pipe-pane -t "$id"` (sin comando, cierra).
   - Si no: `mkdir -p`, `file=".../${session//[^[:alnum:]_-]/_}-$window-$index.log"`
     y `tmx pipe-pane -o -t "$id" "exec cat >> '$quoted'"`. La ruta pasa por
     **dos** intérpretes: tmux expande el comando de `pipe-pane` como format
     (un `#` de la ruta empezaría un `#{...}`: escríbelo `##`) y luego
     `/bin/sh` lo ejecuta (cada `'` pasa a `'\''`).
   ```bash
   TMUX_SOCKET=kit bin/kit-log %99; echo $?
   TMUX_SOCKET=kit bin/kit-log kit:1.1
   tmux -L kit send-keys -t kit:1.1 'echo log-$((6*7))' Enter; sleep 1
   grep -ac log-42 "$XDG_STATE_HOME/tmux-kit/logs/kit-1-1.log"
   TMUX_SOCKET=kit bin/kit-log kit:1.1
   tmux -L kit display -p -t kit:1.1 '#{pane_pipe}'
   ```
   ```
   kit-log: no existe el panel %99
   1
   kit-log: on %0 -> /tmp/kit-demo/state/tmux-kit/logs/kit-1-1.log
   1
   kit-log: off %0
   0
   ```
   El log guarda los bytes tal cual: con `less -R` se leen los colores;
   `grep -a` porque lleva secuencias de escape.

4. **Autolog con hooks (TODO 4).** Del lab-01-hooks. Tres hooks
   `[50]` (`after-new-window`, `after-split-window`, `session-created`: una
   sesión nueva no lanza `after-new-window`) con el mismo cuerpo:
   ```tmux
   if -F "#{==:#{@kit-autolog},on}" {
     run-shell "#{q:@kit-dir}/bin/kit-log #{pane_id} >/dev/null"
   }
   ```
   En un hook `after-*`, `#{pane_id}` es el panel **nuevo** (`#{hook_pane}`
   sale vacío en 3.4). `if -F` decide dentro de tmux; `run-shell` sin `-b`
   espera a `kit-log`, y su salida se tira porque con un cliente conectado
   abriría el modo vista del panel. Los jobs de `run-shell` llevan `$TMUX`:
   `kit-log` habla con este servidor sin `TMUX_SOCKET`.
   ```bash
   tmux -L kit set -g @kit-autolog on
   tmux -L kit new-window -d -t kit: -n w2; tmux -L kit split-window -d -t kit:w2
   tmux -L kit list-panes -s -t =kit -F '#{window_index}.#{pane_index} #{pane_pipe}'
   tmux -L kit set -g @kit-autolog off
   ```
   ```
   1.1 0
   2.1 1
   2.2 1
   ```
   Los hooks saltan también con los comandos de los scripts: con autolog on,
   `dev-up` deja con log las ventanas `run` y `logs` que crea (y `editor`,
   por `session-created`).

5. **Listar proyectos (TODO 5, `bin/kit-projects`).** Del lab-05-fzf-en-un-popup.
   - `root=$(tmx show-options -gqv @kit-projects-dir)` solo si
     `tmx list-sessions` dice que hay servidor (`show` arrancaría uno). Por
     defecto `~/src`. Si alguien fija la opción con comillas simples, la `~`
     llega tal cual: la cambias tú por `$HOME`.
   - `for path in "$root"/*/` con `shopt -s nullglob`: `*/` solo casa con
     directorios y, sin `dotglob`, salta los ocultos. Ni `ls` ni `find |
     while read`: los nombres llegan enteros. Ordena con `LC_ALL=C sort`.
   ```bash
   TMUX_SOCKET=kit bin/kit-projects -l; echo $?
   tmux -L kit set -g @kit-projects-dir /tmp/kit-demo/src
   TMUX_SOCKET=kit bin/kit-projects -l
   ```
   ```
   kit-projects: no existe el directorio de proyectos '/home/alumno/src' (@kit-projects-dir)
   1
   api
   web
   ```
   Para tu máquina, pon tu directorio en `local.conf`:
   `set -g @kit-projects-dir "~/proyectos"`.

6. **Elegir y abrir (TODO 6).** Del lab-05-fzf-en-un-popup.
   - Con fzf: `name=$(printf '%s\n' "${projects[@]}" | fzf --prompt='proyecto> ' --reverse) || rc=$?`.
     130 (Esc) y 1 (sin coincidencias) son cancelar: `exit 0`.
   - Sin fzf: el `select` de bash, con `PS3` como pregunta. C-d deja el
     nombre vacío: `exit 0`.
   - El nombre tiene que estar en la lista (`grep -qxF`). `-d ..` es un
     directorio que existe, pero no un proyecto.
   - `exec "$(dirname "$0")/dev-up" "${opts[@]}" -- "$root/$name"`: el
     nombre es un argumento, nunca parte de una cadena que interprete una
     shell o tmux. `dev-up` ya sabe si toca `switch-client` o `attach`.
   ```bash
   TMUX_SOCKET=kit bin/kit-projects -d api
   TMUX_SOCKET=kit bin/kit-projects -d ..; echo $?
   ```
   ```
   dev-up: sesión 'api' creada en /tmp/kit-demo/src/api
   kit-projects: no existe el proyecto '..' en '/tmp/kit-demo/src'
   1
   ```
   La lista numerada se prueba sin terminal escondiendo fzf del `PATH`:
   `printf '2\n' | PATH=/sin/fzf:... bin/kit-projects -d` abre `web`.

7. **Popup de proyectos (TODO 7).** Del lab-02-popups. `prefix` `P` está
   libre en 3.4 (`p` es la ventana anterior):
   ```tmux
   bind -N "kit: elige un proyecto (popup)" P display-popup -EE -w 60% -h 60% -T " proyectos " \
     'exec "$(tmux show -gv @kit-dir)/bin/kit-projects"'
   ```
   - `-EE`: se cierra si `kit-projects` termina bien o lo cancelas; si
     falla, se queda con el error hasta que pulses Escape. Con `-E` el
     error desaparecería con el popup.
   - **En 3.4 el comando del popup no se expande como format**:
     `#{@kit-dir}` llegaría literal a la shell. La ruta se pregunta desde
     dentro; el popup tiene `$TMUX`, así que `tmux show` habla con este
     servidor.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit list-keys -T prefix P
   ```
   ```
   bind-key -T prefix P display-popup -EE -T " proyectos " -h "60%" -w "60%" "exec \"$(tmux show -gv @kit-dir)/bin/kit-projects\""
   ```
   Pruébalo de verdad: `tmux -L kit attach -t kit`, `prefix` `P`, escribe
   `web`, Enter. La barra dice `web`. Otra vez `prefix` `P` y Escape: no
   pasa nada.

8. **Menú del kit (TODO 8).** Del lab-03-menus-y-prompts. `prefix` `K`
   ("kit"): `prefix` `M` ya es `select-pane -M`. `display-menu -T ... -x C -y C`
   y, por entrada, `"Nombre" tecla 'comando'`; `""` es un separador.
   - `"Abrir proyecto" p` → el mismo `display-popup` del paso 7.
   - `"Cerrar esta sesión" x` → `confirm-before -p "¿cerrar la sesión? (y/n)" kill-session`.
     Sin `-t`: cierra la del cliente. No metas `#{session_name}` en el
     comando: una `'` en el nombre lo rompería.
   - `"#{?pane_pipe,Parar,Empezar} log del panel" l` →
     `run-shell "#{q:@kit-dir}/bin/kit-log #{pane_id} >/dev/null"`.
   - `"#{?#{==:#{@kit-nav},on},Apagar,Encender} navegación C-h/j/k/l" n` →
     `set -gF @kit-nav "#{?#{==:#{@kit-nav},on},off,on}"`. Igual con
     `@kit-status-git`.
   - `"kit-doctor" d` → `display-popup` **sin** `-E`: el informe sigue a la
     vista; Escape lo cierra.

   display-menu expande los formats de nombres **y comandos** al abrirse: la
   etiqueta dice el estado de ese momento. El kit no usa `command-prompt`;
   si lo usas, escribe la plantilla entre llaves (`{ rename-window "%%" }`):
   como texto entre comillas, una respuesta como `q"; set -g @x 1; "` ejecuta
   el segundo comando (lo ves en el lab-03).
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   TMUX_SOCKET=kit bin/kit-keys prefix | grep -E '^prefix (P|K) '
   ```
   ```
   prefix K  kit: menú del kit
   prefix P  kit: elige un proyecto (popup)
   ```
   Con el cliente conectado: `prefix` `K` `n` apaga la navegación (la barra
   dice `NAV off`), `prefix` `K` `x` `n` no cierra nada, `prefix` `K` `d`
   abre `kit-doctor`.

9. **`LOG` en la barra (TODO 9, `conf.d/30-status.conf`).** Añade
   `#{?pane_pipe, LOG,}` al final de `@kit-window-label`. Con `prefix` `K`
   `l` la ventana pasa a `1:bash LOG` (la barra se redibuja cada
   `status-interval`).

10. **README del kit.** En `starter/README.md`: filas de `bin/kit-projects`
    y `bin/kit-log` (con sus códigos de salida), la fila de
    `conf.d/50-hooks-popups.conf`, `prefix` `P` y `prefix` `K` en la tabla de
    teclas, una sección `## Hooks, popups y menú` (con el aviso: un log
    guarda todo lo que sale en pantalla) y la fila `10` en la bitácora.

11. **Cierra y verifica.**
    ```bash
    tmux -L kit kill-server
    shellcheck bin/*; echo $?
    cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 10
    ```
    ```
    0
    Semana 10 — Hooks, popups y menús
    ...
    18/18 comprobaciones superadas.
    ```

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-10-hooks_popups_y_menus/3-proyecto/starter"
mkdir -p /tmp/kit-demo/src/api /tmp/kit-demo/src/web
export XDG_STATE_HOME=/tmp/kit-demo/state
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
tmux -L kit show-hooks -g | grep -c kit
tmux -L kit set -g @kit-projects-dir /tmp/kit-demo/src
TMUX_SOCKET=kit bin/kit-projects -l
TMUX_SOCKET=kit bin/kit-projects -d api
TMUX_SOCKET=kit bin/kit-log api:1.1
TMUX_SOCKET=kit bin/kit-log api:1.1
tmux -L kit kill-server
```
```
0
4
api
web
dev-up: sesión 'api' creada en /tmp/kit-demo/src/api
kit-log: on %1 -> /tmp/kit-demo/state/tmux-kit/logs/api-1-1.log
kit-log: off %1
```
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 10
```
```
18/18 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 10` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] Al conectarse un cliente, un hook muestra un mensaje
- [ ] Recargar la config dos veces no duplica los hooks del kit
- [ ] kit-log PANEL guarda lo que sale en el panel en SESION-VENTANA-PANEL.log
- [ ] kit-log dos veces sobre el mismo panel cierra el log
- [ ] Un XDG_STATE_HOME con comillas, # y $(...) no ejecuta nada
- [ ] kit-log con un panel que no existe sale con 1 y lo dice
- [ ] Con @kit-autolog on, las ventanas y los paneles nuevos empiezan con log
- [ ] kit-projects -l lista los subdirectorios de @kit-projects-dir en orden, sin ocultos ni archivos
- [ ] Con el @kit-projects-dir por defecto, kit-projects -l lista ~/src
- [ ] Con un @kit-projects-dir que no existe, kit-projects -l sale con 1 y lo dice
- [ ] kit-projects -d api abre el proyecto api con dev-up
- [ ] kit-projects -d .. sale con 1 y no crea ninguna sesión
- [ ] Un proyecto con $(...) en el nombre no ejecuta nada
- [ ] prefix P abre kit-projects en un popup que se cierra al terminar
- [ ] El menú del kit (prefix K) cierra la sesión solo tras confirmar
- [ ] prefix P y prefix K llevan nota kit:
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- **Hooks idempotentes**: índice fijo (o `-u` antes), ningún `set-hook -ga` en la config; el autolog decide con `if -F`, no con una shell.
- **Nada externo llega a una shell ni a tmux como código**: ruta del log con `##` y `'\''`, nombres de proyecto como argumentos de `dev-up`, ningún `#{session_name}` dentro de un comando del menú, ningún `command-prompt` con la plantilla como texto entre comillas.
- **Popups que se comportan**: `-EE` donde un fallo debe verse, sin `-E` donde hay que leer un informe; la ruta del kit preguntada desde dentro (3.4 no expande el comando).
- Comentarios del porqué: el índice `[50]`, `#{pane_id}` frente a `#{hook_pane}`, por qué `list-panes` para validar, por qué `run-shell` sin `-b` y con la salida tirada, `prefix K` y no `M`.
- `kit-projects` funciona sin fzf; cancelar no es un error.
- Cabecera con uso y códigos de salida en los dos scripts; errores por stderr con el nombre del script; `shellcheck bin/*` sin avisos.
- README del kit al día: tabla de scripts, teclas, sección de hooks y popups (con el aviso sobre lo que guarda un log) y la bitácora.

## Entrega

Commit con el mensaje:
```
feat(week-10): popup de proyectos, menú del kit y kit-log con hooks
```
Entrega `conf.d/50-hooks-popups.conf`, `conf.d/30-status.conf`, `bin/kit-log`, `bin/kit-projects` y `README.md` de tu `starter/`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — Hooks rotos](../2-practicas/lab-06-hooks-rotos/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 10](../README.md)
