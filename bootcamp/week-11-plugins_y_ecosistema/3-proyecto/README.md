# Proyecto Semana 11 — tmux-kit: plugin propio y plugins de terceros fijados

⏱ Duración estimada: ~3 h

## Contexto

Tu equipo empieza a compartir el kit: tres personas lo enlazan en `~/.config/tmux` y cada una ha pegado en su `local.conf` un par de plugins copiados de un README, sin versión. Al mes, en una máquina `prefix` `C-s` guarda las sesiones y en otra no hace nada, y nadie sabe qué versión de qué tiene cada uno. Mientras tanto, la status line sigue con el `#(...)` de la rama git escrito a mano en medio de un format de 300 caracteres.

Esta semana el kit gana **un plugin propio**, `plugin/tmux-kit.tmux`: un script que, como cualquier plugin de tmux, solo llama a `tmux show` y `tmux set`. Cambia los marcadores `#{kit_git}` y `#{kit_sessions}` de la barra por formats de verdad, lee su opción `@kit-sessions-label` con un valor por defecto y se carga con un simple `run-shell`, sin TPM. Los plugins de terceros (TPM, tmux-resurrect y tmux-continuum) quedan **fijados por tag** en `conf.d/60-plugins.conf`, se instalan dentro del kit con **`bin/kit-plugins install`** y `bin/kit-plugins check` falla si alguien añade uno sin versión. Sin TPM instalado, el kit carga igual: es lo que ve el autograding.

```
$ TMUX_SOCKET=kit bin/kit-plugins list
tpm                v3.1.0   instalado
tmux-resurrect     v4.0.0   instalado
tmux-continuum     v3.1.0   instalado
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                   ← tu tmux-kit de la semana 10 + lo nuevo
├── README.md              ← añade kit-plugins, la sección de plugins y la bitácora
├── .gitignore             ← TODO 7
├── tmux.conf              ← sin cambios
├── conf.d/
│   ├── 10-options.conf, 20-bindings.conf, 40-terminal.conf,
│   │   50-hooks-popups.conf                                  (sin cambios)
│   ├── 30-status.conf     ← TODO 3 (marcadores)
│   └── 60-plugins.conf    ← TODOs 4, 5, 6, 8 y 9 (nuevo)
├── plugin/
│   └── tmux-kit.tmux      ← TODOs 1 y 2 (nuevo)
├── docs/diagnostico.md    ← sin cambios
└── bin/
    ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option,
    │   kit-keys, kit-git-branch, kit-doctor, dev-up, dev-down,
    │   kit-projects, kit-log                                 (semanas 01-10)
    └── kit-plugins        ← TODOs 10 a 13 (nuevo)
```

## Lo que debes construir

1. **`plugin/tmux-kit.tmux`**, ejecutable, que funciona con `run-shell` y con TPM:
   - Cambia `#{kit_sessions}` por `#{server_sessions} #{@kit-sessions-label}` y `#{kit_git}` por `#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})`, en `status-left` y `status-right`.
   - Da a `@kit-sessions-label` el valor `ses` y a `@kit-dir` su directorio padre, **solo si no tienen valor**.
   - Ejecutarlo otra vez no cambia nada.
2. **`conf.d/30-status.conf`**: la derecha usa `#{kit_git}` y `#{kit_sessions}` en lugar del `#(...)` escrito a mano.
3. **`conf.d/60-plugins.conf`**:
   - Carga el plugin propio con `run-shell`.
   - `@tpm_plugins` con `tmux-plugins/tpm#v3.1.0`, `tmux-plugins/tmux-resurrect#v4.0.0` y `tmux-plugins/tmux-continuum#v3.1.0`.
   - `TMUX_PLUGIN_MANAGER_PATH` en `plugins/` dentro del kit.
   - resurrect en `~/.local/share/tmux/resurrect` con el contenido de los paneles; continuum cada 15 min y con restauración al arrancar.
   - Ejecuta TPM al final, solo si `plugins/tpm/tpm` existe.
4. **`bin/kit-plugins list|check|install`**:
   - `list`: `NOMBRE TAG instalado|falta`, en el orden de `@tpm_plugins`.
   - `check`: sale con **1** y nombra cada plugin sin tag o fijado a una rama (`master`, `main`, `HEAD`).
   - `install`: clona TPM con su tag (si no está), ejecuta `install_plugins` contra el servidor de `TMUX_SOCKET` y recarga.
   - Sin servidor, **1** (`no hay servidor`); uso incorrecto, **2**.
5. **`.gitignore`** con `plugins/`.
6. **README del kit** con la fila de `bin/kit-plugins`, las de `conf.d/60-plugins.conf` y `plugin/`, una sección `## Plugins` y la fila `11` en la bitácora.

## Paso a paso

0. **Dónde.** Una terminal **fuera de tmux** (`echo "$TMUX"` no imprime nada),
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter
   mkdir -p /tmp/kit-demo/home
   ```
   (sin salida)

   Todo va contra servidores aparte: `-L kit` con tu config y `-L plug`
   vacío (`-f /dev/null`) para probar el plugin solo. `/tmp/kit-demo/home`
   hace de `HOME` en el paso 11: lo que instales y guardes no toca tu
   `~/.config/tmux` ni tu `~/.local/share`. Si algo se queda a medias,
   `tmux -L kit kill-server` (y `-L plug`) y repite el paso.

1. **Punto de partida.** La config carga y `kit-plugins` ya analiza sus
   argumentos:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
   TMUX_SOCKET=kit bin/kit-plugins; echo $?
   TMUX_SOCKET=kit bin/kit-plugins list; echo $?
   tmux -L kit kill-server
   ```
   ```
   0
   Uso: kit-plugins list       cada plugin de @tpm_plugins: nombre, versión y si está instalado
        kit-plugins check      comprueba que todos están fijados a un tag
        kit-plugins install    clona TPM con su tag e instala los plugins (necesita red)
   Salida: 0 bien, 1 sin servidor, plugins sin fijar o instalación fallida, 2 uso incorrecto.
   2
   kit-plugins: sin implementar: list
   1
   ```
   Como en las semanas 09 y 10, borra cada `die "sin implementar: ..."`
   cuando escribas esa función.

2. **Marcador de sesiones y opción con valor por defecto (TODO 1,
   `plugin/tmux-kit.tmux`).** Del lab-03-anatomia-de-un-plugin y el
   lab-04-interpolacion-en-la-status.
   ```bash
   set_default() {
     [[ -n "$(tmx show -gqv "$1")" ]] || tmx set -g "$1" "$2"
   }
   set_default @kit-sessions-label ses
   ```
   - Sin `-q`, `show` sale con 1 si la opción no existe y `set -e` cortaría
     el plugin.
   - El marcador se cambia por un **format**, no por el número de ahora:
     `sessions='#{server_sessions} #{@kit-sessions-label}'`. tmux lo expande
     cada vez que dibuja, así que la cuenta y la etiqueta salen al día.
   - Bucle: `for option in status-left status-right`, `value=$(tmx show -gqv "$option")`,
     `new=${value//'#{kit_sessions}'/"$sessions"}` y `tmx set -g "$option" "$new"`
     solo si `new` es distinto. El reemplazo va entre comillas: en bash 5.2
     un `&` sin comillas significa «lo encontrado».

   Pruébalo sin el kit, en un servidor vacío:
   ```bash
   tmux -L plug -f /dev/null new -d
   tmux -L plug set -g status-right 'S #{kit_sessions}'
   tmux -L plug run-shell "$PWD/plugin/tmux-kit.tmux"; echo $?
   tmux -L plug show -gv status-right
   tmux -L plug display -p '#{E:status-right}'
   ```
   ```
   0
   S #{server_sessions} #{@kit-sessions-label}
   S 1 ses
   ```
   La opción se lee al dibujar, no al cargar el plugin:
   ```bash
   tmux -L plug set -g @kit-sessions-label sesiones
   tmux -L plug display -p '#{E:status-right}'
   tmux -L plug run-shell "$PWD/plugin/tmux-kit.tmux"; tmux -L plug show -gv status-right
   ```
   ```
   S 1 sesiones
   S #{server_sessions} #{@kit-sessions-label}
   ```
   La segunda ejecución no tocó nada (ya no quedaban marcadores) y respetó
   `sesiones`.

3. **Marcador de git (TODO 2, `plugin/tmux-kit.tmux`).** En el mismo bucle,
   `#{kit_git}` pasa a `'#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})'`,
   el mismo `#(...)` de la semana 07. Cargado sin el kit nadie fijó
   `@kit-dir`: `set_default @kit-dir "$kit_dir"`, con
   `kit_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)`.
   ```bash
   tmux -L plug set -g status-right '#{kit_git}'
   tmux -L plug run-shell "$PWD/plugin/tmux-kit.tmux"
   tmux -L plug show -gv status-right
   tmux -L plug show -gv @kit-dir
   tmux -L plug kill-server
   ```
   ```
   #(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})
   /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter
   ```
   (La segunda línea, algo como eso: cambia la ruta de tu repositorio.)

4. **Marcadores en la barra y carga del plugin (TODOs 3 y 4).**
   - En `conf.d/30-status.conf`, cambia
     `#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path})` por
     `#{kit_git}` (dentro del mismo condicional de `@kit-status-git`) y
     añade `#{kit_sessions} ` delante de `#{host_short}`. Sin el plugin, un
     marcador se expande a nada: la barra no se rompe.
   - En `conf.d/60-plugins.conf`: `run-shell "#{q:@kit-dir}/plugin/tmux-kit.tmux"`.
     El glob de `tmux.conf` carga `60-` después de `30-`, así que los
     marcadores ya están puestos. Sin `-b`, la config espera a que el plugin
     termine.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
   tmux -L kit show -gv status-right | grep -oE 'kit_[a-z]+|server_sessions|bin/kit-git-branch'
   tmux -L kit source-file "$PWD/tmux.conf"; tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -gv status-right | grep -oE 'kit_[a-z]+|server_sessions|bin/kit-git-branch'
   ```
   ```
   0
   bin/kit-git-branch
   server_sessions
   bin/kit-git-branch
   server_sessions
   ```
   Ningún `kit_` sin sustituir, y dos recargas dejan lo mismo: cada
   `source-file` vuelve a poner los marcadores y el plugin los vuelve a
   cambiar.

5. **Plugins fijados (TODO 5, `conf.d/60-plugins.conf`).** Del
   lab-01-tpm-desde-cero y el lab-06-plugins-rotos. TPM **no le pregunta a
   tmux** por las líneas `set -g @plugin`: las busca con `awk` en
   `~/.config/tmux/tmux.conf` y en los `source-file` con ruta literal de ese
   archivo. El `source-file -F "#{@kit-dir}/conf.d/*.conf"` del kit no lo
   entiende y `install_plugins` sale con 0 sin instalar nada. Además, para
   tmux `@plugin` es una opción más: cada línea pisa la anterior.
   ```bash
   tmux -L kit set -g @plugin 'tmux-plugins/tmux-resurrect'; tmux -L kit set -g @plugin 'tmux-plugins/tmux-continuum'; tmux -L kit show -g @plugin; tmux -L kit set -gu @plugin
   ```
   ```
   @plugin tmux-plugins/tmux-continuum
   ```
   La lista va en `@tpm_plugins`, la forma antigua que TPM 3.1.0 sigue
   leyendo y que sí pide al servidor. Es una sola opción: recargar la
   sustituye.
   ```tmux
   set -g @tpm_plugins '                 \
     tmux-plugins/tpm#v3.1.0             \
     tmux-plugins/tmux-resurrect#v4.0.0  \
     tmux-plugins/tmux-continuum#v3.1.0  \
   '
   ```
   Explícalo en un comentario: quien lea el kit esperará `@plugin`.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -gv @tpm_plugins | xargs -n1
   ```
   ```
   tmux-plugins/tpm#v3.1.0
   tmux-plugins/tmux-resurrect#v4.0.0
   tmux-plugins/tmux-continuum#v3.1.0
   ```

6. **Dónde se instalan (TODOs 6 y 7).** TPM instala en
   `$TMUX_PLUGIN_MANAGER_PATH` si ya existe; si no, en
   `~/.config/tmux/plugins/` (o `~/.tmux/plugins/` sin config XDG). Dentro
   del kit, una copia de pruebas no carga los plugins de tu config real.
   - `conf.d/60-plugins.conf`: `setenv -gF TMUX_PLUGIN_MANAGER_PATH "#{@kit-dir}/plugins/"`.
     La barra final hace falta: TPM le pega el nombre del plugin detrás.
   - `.gitignore`: cambia el TODO por `plugins/`. Los plugins se instalan,
     no se versionan.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show-environment -g TMUX_PLUGIN_MANAGER_PATH
   git check-ignore -v --no-index plugins/tpm/tpm
   ```
   Algo como (cambia la ruta de tu repositorio):
   ```
   TMUX_PLUGIN_MANAGER_PATH=/ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/
   bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/.gitignore:2:plugins/	plugins/tpm/tpm
   ```
   Si la segunda línea empieza por `.gitignore:12:`, la regla que coincide
   es la del repositorio del bootcamp, no la de tu kit.

7. **resurrect y continuum (TODO 8, `conf.d/60-plugins.conf`).** Del
   lab-02-resurrect-y-continuum.
   ```tmux
   set -g @resurrect-dir '~/.local/share/tmux/resurrect'
   set -g @resurrect-capture-pane-contents on
   set -g @continuum-save-interval 15
   set -g @continuum-restore on
   ```
   resurrect v4.0.0 guarda por defecto en `~/.tmux/resurrect`. Comillas
   **simples**: entre dobles, tmux cambia la `~` por tu `HOME` al leer la
   config; con simples se guarda tal cual y la cambia resurrect cada vez que
   guarda.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -g | grep -E '^@(resurrect|continuum)'
   ```
   ```
   @continuum-restore on
   @continuum-save-interval 15
   @resurrect-capture-pane-contents on
   @resurrect-dir \~/.local/share/tmux/resurrect
   ```
   (`show` sin `-v` escapa la `~`; `show -gv @resurrect-dir` la imprime sin `\`.)

8. **TPM solo si está (TODO 9, `conf.d/60-plugins.conf`).** Del
   lab-06-plugins-rotos. Así falla un `run-shell` a un TPM que no existe:
   ```bash
   tmux -L kit run-shell "$PWD/plugins/tpm/tpm"; echo $?
   ```
   ```
   127
   ```
   Escrito así en la config, `source-file` saldría con 127 en cada máquina
   sin TPM. Al final del archivo (TPM ejecuta los plugins con las opciones
   que ya estén puestas):
   ```tmux
   if-shell "test -x #{q:@kit-dir}/plugins/tpm/tpm" {
     run-shell "#{q:@kit-dir}/plugins/tpm/tpm"
   }
   ```
   `if-shell` expande el format antes de pasar el comando a la shell.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; echo $?
   ```
   ```
   0
   ```

9. **`kit-plugins list` (TODOs 10 y 11, `bin/kit-plugins`).**
   - `load`: `list=$(tmx show -gqv @tpm_plugins) || die "no hay servidor de tmux en este socket"`
     (`show` no arranca un servidor) y `read -r -d '' -a entries <<<"$list" || true`,
     que parte por espacios y saltos de línea sin expandir globs. La ruta:
     `tmx show-environment -g TMUX_PLUGIN_MANAGER_PATH` imprime
     `NOMBRE=VALOR`; quédate con `${env#*=}`.
   - `split` ya está: deja `repo`, `ref` y `name` (el directorio que crea TPM).
   - `list`: `printf '%-18s %-8s %s\n' "$name" "${ref:--}" "$state"`, con
     `state` a `instalado` si existe `"$plugins_dir$name"`.
   ```bash
   TMUX_SOCKET=nadie bin/kit-plugins list; echo $?
   TMUX_SOCKET=kit bin/kit-plugins list
   ```
   ```
   kit-plugins: no hay servidor de tmux en este socket
   1
   tpm                v3.1.0   falta
   tmux-resurrect     v4.0.0   falta
   tmux-continuum     v3.1.0   falta
   ```

10. **`kit-plugins check` (TODO 12).** Un plugin sin `#` o con
    `#master`/`#main`/`#HEAD` no está fijado: una rama se mueve con cada
    commit. Un aviso por plugin, por stderr, con el repo; si hubo alguno,
    `exit 1`.
    ```bash
    TMUX_SOCKET=kit bin/kit-plugins check; echo $?
    tmux -L kit set -ga @tpm_plugins ' tmux-plugins/tmux-sensible tmux-plugins/tmux-yank#master'
    TMUX_SOCKET=kit bin/kit-plugins check; echo $?
    tmux -L kit source-file "$PWD/tmux.conf"; TMUX_SOCKET=kit bin/kit-plugins check
    ```
    ```
    kit-plugins: 3 plugins fijados
    0
    kit-plugins: sin fijar: tmux-plugins/tmux-sensible (añade #tag)
    kit-plugins: sin fijar: tmux-plugins/tmux-yank#master es una rama, no un tag
    1
    kit-plugins: 3 plugins fijados
    ```
    La recarga devuelve la lista del archivo: `set -g` sustituye lo que
    añadiste a mano.

11. **`kit-plugins install` (TODO 13).** Necesita red. Pasos:
    `check >/dev/null`; busca la entrada cuyo `name` es `tpm`; si no existe
    `"${plugins_dir}tpm/tpm"`, `git clone --depth 1 --branch "$tag"`
    (`--branch` acepta tags); ejecuta `"${plugins_dir}tpm/bin/install_plugins"`
    con `TMUX="$(tmx display-message -p '#{socket_path}'),0,0"` delante (TPM
    llama a `tmux` a secas: así le habla a este servidor y no al de siempre)
    y recarga con `tmx source-file -F '#{@kit-dir}/tmux.conf'`.

    Arranca el servidor con el `HOME` de pruebas: los scripts de los
    plugins heredan su entorno. `HOME=` delante de `kit-plugins` hace que
    TPM no lea los `@plugin` de tu `~/.config/tmux` real.
    ```bash
    tmux -L kit kill-server
    env -u XDG_CONFIG_HOME -u XDG_DATA_HOME HOME=/tmp/kit-demo/home tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
    HOME=/tmp/kit-demo/home TMUX_SOCKET=kit bin/kit-plugins install; echo $?
    TMUX_SOCKET=kit bin/kit-plugins list
    ```
    ```
    0
    Already installed "tpm"
    Installing "tmux-resurrect"
      "tmux-resurrect" download success
    Installing "tmux-continuum"
      "tmux-continuum" download success
    kit-plugins: listo. Compruébalo con: kit-plugins list
    0
    tpm                v3.1.0   instalado
    tmux-resurrect     v4.0.0   instalado
    tmux-continuum     v3.1.0   instalado
    ```
    (`Already installed "tpm"`: lo acaba de clonar `kit-plugins`.) Otra vez
    no clona nada:
    ```bash
    HOME=/tmp/kit-demo/home TMUX_SOCKET=kit bin/kit-plugins install
    tmux -L kit list-keys -T prefix | grep -E 'resurrect|tpm/bindings' | awk '{ print $4, $5, $6 }'
    ```
    ```
    Already installed "tpm"
    Already installed "tmux-resurrect"
    Already installed "tmux-continuum"
    kit-plugins: listo. Compruébalo con: kit-plugins list
    C-r run-shell /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/tmux-resurrect/scripts/restore.sh
    C-s run-shell /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/tmux-resurrect/scripts/save.sh
    I run-shell /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/tpm/bindings/install_plugins
    U run-shell /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/tpm/bindings/update_plugins
    M-u run-shell /ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter/plugins/tpm/bindings/clean_plugins
    ```
    Si la ruta de tu repositorio tiene espacios, las teclas de resurrect no
    aparecen: TPM ejecuta los `*.tmux` sin comillas y no carga nada.

    Guarda, mata el servidor y vuelve a arrancarlo. `save.sh` es lo mismo
    que `prefix` `C-s`, sin cliente:
    ```bash
    tmux -L kit new-window -d -t kit: -n logs; tmux -L kit new-window -d -t kit: -n run
    tmux -L kit run-shell "$PWD/plugins/tmux-resurrect/scripts/save.sh"; echo $?
    ls /tmp/kit-demo/home/.local/share/tmux/resurrect
    tmux -L kit kill-server; sleep 1
    env -u XDG_CONFIG_HOME -u XDG_DATA_HOME HOME=/tmp/kit-demo/home tmux -L kit -f "$PWD/tmux.conf" new -d -s tmp; sleep 3
    tmux -L kit list-windows -t =kit -F '#{window_index}:#{window_name}'
    ```
    ```
    0
    last
    pane_contents.tar.gz
    save
    tmux_resurrect_20261103T194406.txt
    1:bash
    2:logs
    3:run
    ```
    (El nombre del `.txt` lleva la fecha y la hora.) La sesión `kit` volvió
    sola: `@continuum-restore on` la restaura cuando arranca el servidor.
    Si no aparece, `tmux -L kit run-shell "$PWD/plugins/tmux-resurrect/scripts/restore.sh"`
    (o `prefix` `C-r`) la restaura a mano.

    El guardado cada 15 minutos lo hace un `#(...)` que continuum pone
    delante de `status-right`. Solo lo pone si este es el **único**
    servidor de tmux en marcha (cuenta los procesos `tmux`): con tu tmux de
    siempre abierto, aquí no aparece.
    ```bash
    tmux -L kit show -gv status-right | cut -c1-60
    tmux -L kit kill-server
    ```
    Sin otro tmux abierto, algo como:
    ```
    #(/ruta/al/repo/bootcamp/week-11-plugins_y_ecosistema/3-pr
    ```

12. **README del kit.** En `starter/README.md`: la fila de
    `bin/kit-plugins` (con sus códigos de salida), las de
    `conf.d/60-plugins.conf`, `plugin/tmux-kit.tmux` y `plugins/` en la
    estructura, `#{kit_git}` y `#{kit_sessions}` en la tabla de la status
    line, una sección `## Plugins` (qué hace cada uno, su tag, por qué
    `@tpm_plugins` y no `@plugin`) y la fila `11` en la bitácora.

13. **Cierra y verifica.** Si no tienes shellcheck:
    `sudo apt install shellcheck` (Ubuntu) o `brew install shellcheck` (macOS).
    ```bash
    shellcheck bin/* plugin/*.tmux; echo $?
    cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 11
    ```
    ```
    0
    Semana 11 — Plugins y ecosistema
    ...
    18/18 comprobaciones superadas.
    ```
    Los checks no usan la red ni tus `plugins/`: copian el kit a un
    directorio temporal cuando necesitan uno sin TPM.

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-11-plugins_y_ecosistema/3-proyecto/starter"
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
tmux -L kit show -gv status-right | grep -c kit_
TMUX_SOCKET=kit bin/kit-plugins check
TMUX_SOCKET=kit bin/kit-plugins list
tmux -L kit kill-server
```
Con los plugins instalados en el paso 11:
```
0
0
kit-plugins: 3 plugins fijados
tpm                v3.1.0   instalado
tmux-resurrect     v4.0.0   instalado
tmux-continuum     v3.1.0   instalado
```
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 11
```
```
18/18 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 11` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores en una máquina sin TPM
- [ ] El plugin del kit, cargado solo con run-shell, cambia #{kit_sessions} por el número de sesiones
- [ ] El plugin respeta un @kit-sessions-label fijado antes de cargarlo
- [ ] La rama git de la barra sale del marcador #{kit_git} del plugin
- [ ] Recargar la config y volver a ejecutar el plugin deja la status line igual
- [ ] @tpm_plugins declara tpm v3.1.0, tmux-resurrect v4.0.0 y tmux-continuum v3.1.0
- [ ] TPM instala los plugins en plugins/ dentro del kit
- [ ] Con plugins/tpm/tpm instalado, la config lo ejecuta al cargar
- [ ] resurrect guarda en ~/.local/share/tmux/resurrect, no en ~/.tmux
- [ ] continuum restaura el último guardado al arrancar el servidor
- [ ] kit-plugins sin subcomando o con uno desconocido sale con 2
- [ ] kit-plugins list sin servidor sale con 1 y lo dice
- [ ] kit-plugins list dice de cada plugin si está instalado, en el orden de @tpm_plugins
- [ ] kit-plugins check sale con 0 con los plugins del kit
- [ ] kit-plugins check sale con 1 y nombra un plugin sin tag
- [ ] kit-plugins check sale con 1 con un plugin fijado a master
- [ ] El .gitignore del kit deja fuera plugins/
- [ ] tmux.conf, conf.d/, bin/ y plugin/ no tienen TODOs y bin/ y plugin/ pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- **El plugin es un plugin**: ejecutable, sin rutas fijas (su directorio sale de `BASH_SOURCE`), habla con `tmux` a secas porque corre dentro del servidor, valores por defecto solo si la opción está vacía, idempotente.
- **Marcadores como formats**: `#{server_sessions}` y `#{@kit-sessions-label}` se expanden al dibujar; ninguna ruta llega a `#(...)` sin `#{q:...}`.
- **Versiones fijadas**: todos los plugins con `#tag`, ninguno con rama; `kit-plugins check` lo comprueba y `install` se niega si falla.
- **La config no depende de lo instalado**: carga sin TPM (`if-shell` + `test -x`), TPM al final, plugins dentro del kit y fuera de git.
- Comentarios del porqué: `@tpm_plugins` y no `@plugin` (TPM lee archivos, no el servidor), comillas simples en `@resurrect-dir`, la barra final de `TMUX_PLUGIN_MANAGER_PATH`, el `TMUX=` delante de `install_plugins`, por qué continuum necesita la barra.
- Cabecera con uso y códigos de salida en `kit-plugins`; errores por stderr con el nombre del script; `shellcheck bin/* plugin/*.tmux` sin avisos.
- README del kit al día: scripts, estructura, status line, sección de plugins y bitácora.

## Entrega

Commit con el mensaje:
```
feat(week-11): plugin propio del kit y plugins fijados con TPM
```
Entrega `plugin/tmux-kit.tmux`, `conf.d/60-plugins.conf`, `conf.d/30-status.conf`, `bin/kit-plugins`, `.gitignore` y `README.md` de tu `starter/`. No entregues `plugins/`: lo deja fuera el `.gitignore`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — Plugins rotos](../2-practicas/lab-06-plugins-rotos/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 11](../README.md)
