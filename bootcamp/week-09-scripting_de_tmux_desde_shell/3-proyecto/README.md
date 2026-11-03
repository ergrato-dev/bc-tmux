# Proyecto Semana 09 — tmux-kit: `dev-up` idempotente

⏱ Duración estimada: ~3 h

## Contexto

Cada mañana abres los mismos tres sitios por proyecto: el editor, una ventana para levantar el servicio y otra para los logs, todos en el directorio del repositorio. Lo haces a mano, en otro orden cada día, y cuando cierras sin querer la ventana de logs tardas un minuto en dejarla como estaba. En el equipo hay un `dev.sh` que lo intenta, pero si lo lanzas dos veces te deja seis ventanas, con el repositorio `api` abierto se mete en la sesión `api-2` de tu compañero y un día ejecutó el nombre de una carpeta descargada.

Esta semana el kit gana **`bin/dev-up`**: dale un directorio y deja la sesión del proyecto con las ventanas `editor`, `run` y `logs`, o la reutiliza si ya existe, y se conecta. Lanzarlo diez veces da el mismo resultado que lanzarlo una. Si el proyecto trae un `.tmux-kit`, cada ventana arranca con su comando, enviado como texto y solo al crearla. Y **`bin/dev-down`** cierra esa sesión, nunca otra que se le parezca.

```
$ bin/dev-up -d ~/src/api
dev-up: sesión 'api' creada en /home/tu/src/api
$ bin/dev-up -d ~/src/api
dev-up: la sesión 'api' ya existe
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                   ← tu tmux-kit de la semana 08 + lo nuevo
├── README.md              ← añade dev-up, dev-down, .tmux-kit y la bitácora
├── .gitignore             ← local.conf
├── tmux.conf              ← sin cambios
├── conf.d/                ← sin cambios (10-options, 20-bindings, 30-status, 40-terminal)
├── docs/diagnostico.md    ← sin cambios
└── bin/
    ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option,
    │   kit-keys, kit-git-branch, kit-doctor                     (semanas 01-08)
    ├── dev-up             ← TODOs 1-5 (nuevo)
    └── dev-down           ← TODO 6 (nuevo)
```

## Lo que debes construir

1. **`bin/dev-up [-d|--no-attach] DIR [NAME]`**:
   - Sale con **2** con uso incorrecto (sin `DIR`, más de dos argumentos, una opción desconocida o un `NAME` vacío o con `.` o `:`) y con **1** si `DIR` no es un directorio.
   - Nombre de la sesión: `NAME`, o el nombre de `DIR` con `.` y `:` cambiados por `_` (`mi.app` → `mi_app`).
   - Crea la sesión con las ventanas `editor`, `run` y `logs`, en ese orden, todas en `DIR`.
   - **Idempotente**: si la sesión existe, no crea nada salvo la ventana que falte, y lo dice (`ya existe`). Con `api-2` abierta, `api` sigue siendo otra sesión.
   - Si `DIR/.tmux-kit` tiene una línea `ventana: comando`, escribe ese comando en la shell de esa ventana **al crearla**, como texto (`send-keys -l`) y con `Enter` aparte. El archivo nunca pasa por `eval` ni `source`.
   - Sin `-d`: dentro de tmux (del mismo servidor), `switch-client`; fuera, `attach`.
   - Respeta `TMUX_SOCKET` y `TMUX_BIN`; ningún nombre ni ruta llega a una shell.
2. **`bin/dev-down NAME`**: cierra la sesión `NAME` y solo esa. Sale con **1** si no existe (lo dice y no toca nada) y con **2** con uso incorrecto.
3. **README del kit** con las dos filas nuevas en la tabla de scripts, una sección `## Proyectos` con el formato de `.tmux-kit` y la fila `09` en la bitácora.

## Paso a paso

0. **Dónde.** Una terminal **fuera de tmux** (`echo "$TMUX"` no imprime nada),
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/3-proyecto/starter
   mkdir -p /tmp/kit-demo/api /tmp/kit-demo/mi.app /tmp/kit-demo/web
   ```
   Todo va contra un servidor aparte, `-L kit`, y los scripts lo reciben con
   `TMUX_SOCKET=kit`. Si algo se queda a medias,
   `tmux -L kit kill-server` y vuelve a empezar el paso. Las salidas son las
   del laboratorio; las rutas de `/tmp/kit-demo` son las mismas en tu equipo.

1. **Punto de partida.** El análisis de argumentos de los dos scripts ya está
   hecho: el uso incorrecto sale con 2 desde el principio.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
   TMUX_SOCKET=kit bin/dev-up; echo $?
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api; echo $?
   TMUX_SOCKET=kit bin/dev-down api; echo $?
   ```
   ```
   0
   Uso: dev-up [-d|--no-attach] DIR [NAME]
        TMUX_SOCKET=kit dev-up -d ~/src/api     en el servidor de tmux -L kit
   Ventanas editor, run y logs en DIR. NAME por defecto: el nombre de DIR con
   "." y ":" cambiados por "_". DIR/.tmux-kit ("ventana: comando") da el
   comando inicial de cada ventana. -d crea sin conectarse.
   Salida: 0 bien, 1 DIR no existe o tmux falla, 2 uso incorrecto.
   2
   dev-up: sin implementar (/tmp/kit-demo/api -> editor run logs, detach=1)
   1
   dev-down: sin implementar (api)
   1
   ```
   Fíjate en que `-d` puede ir antes o después de `DIR` y en que `--` corta
   las opciones: `bin/dev-up -- -raro` trata `-raro` como directorio. Para
   probar cada TODO antes de terminar, mueve las dos líneas de «sin
   implementar» al final del script según avanzas.

2. **Argumentos (TODO 1, `bin/dev-up`).** Del lab-01-crear-sin-conectarse.
   - `[[ -d "${args[0]}" ]] || die "no existe el directorio '${args[0]}'"`.
   - `dir=$(cd -- "${args[0]}" && pwd -P)`: ruta absoluta, sin enlaces, la
     misma que enseña `#{pane_current_path}`.
   - Con `NAME`: vacío o con `.` o `:` → mensaje por stderr y `exit 2`. Sin
     `NAME`: `name=$(basename -- "$dir")` y `name=${name//[.:]/_}`. tmux
     haría ese cambio por su cuenta (`new -s a.b` crea `a_b`), pero entonces
     `has-session -t "=mi.app"` no la encontraría nunca y la segunda
     ejecución intentaría crearla otra vez (`duplicate session: mi_app`).
   ```bash
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/nada; echo $?
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api mi.api; echo $?
   ```
   ```
   dev-up: no existe el directorio '/tmp/kit-demo/nada'
   1
   dev-up: nombre no válido 'mi.api' (sin '.' ni ':')
   2
   ```

3. **Crear o reutilizar la sesión (TODO 2).** Del lab-01-crear-sin-conectarse
   y el lab-06-script-roto.
   - `tmx has-session -t "=$name" 2>/dev/null`: **con `=`**. Sin él, la
     búsqueda es por prefijo y, con `api-2` abierta, `has-session -t api`
     sale con 0 aunque `api` no exista.
   - Si existe: `echo "dev-up: la sesión '$name' ya existe"` y
     `existing=$(tmx list-windows -t "=$name" -F '#{window_name}')`.
   - Si no: `pane=$(tmx new-session -d -s "$name" -n editor -c "$dir" -P -F '#{pane_id}')`.
     `-P -F` imprime el id del panel nuevo (`%3`): los comandos siguientes
     apuntan a él, sin depender de `base-index` ni del nombre de la ventana.
     Después `echo "dev-up: sesión '$name' creada en $dir"`.
   ```bash
   tmux -L kit new -d -s api-2
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
   tmux -L kit list-sessions -F '#{session_name}'
   ```
   ```
   dev-up: sesión 'api' creada en /tmp/kit-demo/api
   api
   api-2
   kit
   ```
   Si no sale `api`, te falta el `=`. Cierra la sesión para el paso
   siguiente: `tmux -L kit kill-session -t =api`.

4. **Ventanas que falten (TODO 3).** Del lab-05-idempotencia. Recorre
   `WINDOWS`; si `grep -qxF -- "$window" <<<"$existing"` la encuentra,
   `continue`. Si no:
   `pane=$(tmx new-window -d -t "=$name:" -n "$window" -c "$dir" -P -F '#{pane_id}')`.
   Los dos puntos de `"=$name:"` piden «la sesión exacta, siguiente índice
   libre»; `-d` no cambia la ventana actual. Si la sesión es nueva, recuerda
   que `editor` ya está en `existing`. Cuando una ventana se crea en una
   sesión que ya existía, avisa: `dev-up: ventana 'logs' creada de nuevo`.
   ```bash
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
   tmux -L kit list-windows -t =api -F '#{window_index} #{window_name} #{pane_current_path}'
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
   tmux -L kit kill-window -t api:logs
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
   tmux -L kit list-windows -t =api -F '#{window_index} #{window_name}'
   ```
   ```
   dev-up: sesión 'api' creada en /tmp/kit-demo/api
   1 editor /tmp/kit-demo/api
   2 run /tmp/kit-demo/api
   3 logs /tmp/kit-demo/api
   dev-up: la sesión 'api' ya existe
   dev-up: la sesión 'api' ya existe
   dev-up: ventana 'logs' creada de nuevo
   1 editor
   2 run
   3 logs
   ```
   Empieza en 1 por el `base-index` del kit. Y el nombre saneado del paso 2,
   ya con sesión de verdad:
   ```bash
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/mi.app
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/mi.app; echo $?
   ```
   ```
   dev-up: sesión 'mi_app' creada en /tmp/kit-demo/mi.app
   dev-up: la sesión 'mi_app' ya existe
   0
   ```

5. **Comandos de `.tmux-kit` (TODO 4).** Del lab-03-enviar-teclas-con-cuidado
   y el lab-04-esperar-con-wait-for.
   - `kit_command VENTANA`: `while IFS= read -r line || [[ -n "$line" ]]`
     (la segunda parte lee una última línea sin salto final). Salta las
     líneas sin `:`; la clave es lo de antes del primer `:` sin espacios
     (`${key//[[:space:]]/}`) y el comando, lo de después sin los espacios
     de delante. `# run: ...` no casa con `run`: es un comentario. Imprime
     el comando con `printf '%s'`.
   - `start PANE VENTANA`: si hay comando,
     `tmx send-keys -t "$pane" -l -- "$cmd"` y después
     `tmx send-keys -t "$pane" Enter`. `-l` manda letras, no nombres de
     teclas; `--`, que un comando que empiece por `-` no se lea como opción.
   - Llama a `start` **solo** justo después de `new-session` o `new-window`:
     así la segunda ejecución no relanza `make dev` encima del que ya corre.
   - ¿Por qué no `new-window -n run -c "$dir" "$cmd"`? Porque entonces el
     comando **es** el proceso del panel: cuando termina o falla, la ventana
     desaparece con su salida (`remain-on-exit` está en `off`). Con
     `send-keys` queda la shell, el error a la vista y el comando en el
     historial.

   Prueba con comandos que harían daño si se interpretaran, y con `wait-for`
   para no adivinar cuánto tarda la shell en arrancar:
   ```bash
   cat > /tmp/kit-demo/web/.tmux-kit <<'EOF'
   # comandos de web
   editor: echo "editor listo en $PWD"
   run: echo "C-c Enter; $((6*7))"; tmux wait-for -S web-run
     logs : date +%Y
   # run: echo comentario
   EOF
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/web
   timeout 5 tmux -L kit wait-for web-run; echo $?
   tmux -L kit capture-pane -p -t web:run | grep -x 'C-c Enter; 42'
   TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/web
   timeout 2 tmux -L kit wait-for web-run; echo $?
   ```
   ```
   dev-up: sesión 'web' creada en /tmp/kit-demo/web
   0
   C-c Enter; 42
   dev-up: la sesión 'web' ya existe
   124
   ```
   `C-c` y `Enter` salen como texto: sin `-l`, un argumento que sea
   exactamente un nombre de tecla se pulsaría. El `124` es `timeout`: la
   segunda ejecución no reenvió nada. El `tmux` de dentro del panel no lleva
   `-L kit`: lo saca de `$TMUX`.

   Y un directorio con nombre hostil (los `$(...)` llegan en un zip
   cualquiera):
   ```bash
   d='/tmp/kit-demo/x;$(cd;touch kit-pwned)'; mkdir -p "$d"
   TMUX_SOCKET=kit bin/dev-up -d "$d"
   sleep 1; ls ~/kit-pwned
   ```
   ```
   dev-up: sesión 'x;$(cd;touch kit-pwned)' creada en /tmp/kit-demo/x;$(cd;touch kit-pwned)
   ls: cannot access '/home/alumno/kit-pwned': No such file or directory
   ```
   Con `-c "$dir"` la ruta nunca pasa por una shell. Un
   `send-keys "cd $dir" Enter` la escribiría en la del panel y crearía el
   archivo.

6. **Conectarse (TODO 5).** Del lab-01-crear-sin-conectarse.
   `(( detach )) && exit 0`. Si no: dentro de tmux, y del mismo servidor
   (`${TMUX%%,*}` igual a `$(tmx display-message -p '#{socket_path}')`, el
   patrón de `kit-sessions`), `tmx switch-client -t "=$name"`; si no,
   `tmx attach-session -t "=$name"`. `attach` dentro de tmux anidaría un
   cliente en un panel.
   ```bash
   TMUX_SOCKET=kit bin/dev-up /tmp/kit-demo/api
   ```
   Entras en `api`. Dentro, `TMUX_SOCKET=kit bin/dev-up /tmp/kit-demo/web`
   te cambia a `web` sin anidar (la línea de estado lo dice). `prefix` `d`
   para salir.

   > [!NOTE]
   > `new-session -A -s api` («crea o conéctate») parece un atajo, pero no
   > sirve aquí: si la sesión existe, **siempre** intenta conectarse, también
   > con `-d`, y desde un script sin terminal falla con
   > `open terminal failed: not a terminal`. Por eso `has-session` primero.

7. **`dev-down` (TODO 6, `bin/dev-down`).** Del lab-06-script-roto.
   `tmx has-session -t "=$name" 2>/dev/null` o mensaje
   `dev-down: no existe la sesión '$name'` por stderr y `exit 1`; después
   `tmx kill-session -t "=$name"` y `dev-down: sesión '$name' cerrada`. Sin
   el `=`, `kill-session -t api` con `api` ya cerrada **cierra `api-2`**.
   ```bash
   TMUX_SOCKET=kit bin/dev-down api; echo $?
   TMUX_SOCKET=kit bin/dev-down api; echo $?
   tmux -L kit has-session -t =api-2; echo $?
   ```
   ```
   dev-down: sesión 'api' cerrada
   0
   dev-down: no existe la sesión 'api'
   1
   0
   ```

8. **README del kit.** En `starter/README.md`: las filas de `bin/dev-up` y
   `bin/dev-down` en la tabla de scripts (con sus códigos de salida), una
   sección `## Proyectos` con ejemplos de uso y el formato de `.tmux-kit`
   (y el aviso: lo que pones ahí se ejecuta en tu shell), y la fila `09` en
   la bitácora.

9. **Cierra y verifica.**
   ```bash
   tmux -L kit kill-server
   shellcheck bin/*; echo $?
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 09
   ```
   ```
   0
   Semana 09 — Scripting de tmux desde shell

     ✅ tmux.conf carga sin errores
     ✅ dev-up sin argumentos sale con 2
     ✅ dev-up con un directorio que no existe sale con 1 y lo dice
     ✅ dev-up con un NAME que lleva . o : sale con 2
     ✅ Con DIR mi.app, dos ejecuciones dejan una sola sesión mi_app
     ✅ dev-up DIR NAME llama NAME a la sesión
     ✅ dev-up crea las ventanas editor, run y logs, en ese orden
     ✅ Todos los paneles de la sesión arrancan en DIR
     ✅ Ejecutar dev-up dos veces no duplica sesiones ni ventanas
     ✅ Si cierras la ventana logs, dev-up la vuelve a crear
     ✅ Con una sesión api-2 abierta, dev-up crea api igualmente
     ✅ Un directorio con $(...) en el nombre no ejecuta nada
     ✅ La línea run: de .tmux-kit se ejecuta en la ventana run
     ✅ Volver a ejecutar dev-up no reenvía los comandos de .tmux-kit
     ✅ dev-down sin argumentos sale con 2
     ✅ dev-down api cierra la sesión api y deja api-2
     ✅ Sin sesión api, dev-down api sale con 1, lo dice y no cierra api-2
     ✅ tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

   18/18 comprobaciones superadas.
   ```
   Tarda algo más de un minuto: varias comprobaciones esperan a una shell o
   a un `timeout` a propósito.

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-09-scripting_de_tmux_desde_shell/3-proyecto/starter"
mkdir -p /tmp/kit-demo/api
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
TMUX_SOCKET=kit bin/dev-up -d /tmp/kit-demo/api
tmux -L kit list-windows -t =api -F '#{window_name}' | paste -sd' ' -
TMUX_SOCKET=kit bin/dev-down api
tmux -L kit kill-server
```
```
0
dev-up: sesión 'api' creada en /tmp/kit-demo/api
dev-up: la sesión 'api' ya existe
editor run logs
dev-down: sesión 'api' cerrada
```
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 09
```
```
18/18 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 09` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] dev-up sin argumentos sale con 2
- [ ] dev-up con un directorio que no existe sale con 1 y lo dice
- [ ] dev-up con un NAME que lleva . o : sale con 2
- [ ] Con DIR mi.app, dos ejecuciones dejan una sola sesión mi_app
- [ ] dev-up DIR NAME llama NAME a la sesión
- [ ] dev-up crea las ventanas editor, run y logs, en ese orden
- [ ] Todos los paneles de la sesión arrancan en DIR
- [ ] Ejecutar dev-up dos veces no duplica sesiones ni ventanas
- [ ] Si cierras la ventana logs, dev-up la vuelve a crear
- [ ] Con una sesión api-2 abierta, dev-up crea api igualmente
- [ ] Un directorio con $(...) en el nombre no ejecuta nada
- [ ] La línea run: de .tmux-kit se ejecuta en la ventana run
- [ ] Volver a ejecutar dev-up no reenvía los comandos de .tmux-kit
- [ ] dev-down sin argumentos sale con 2
- [ ] dev-down api cierra la sesión api y deja api-2
- [ ] Sin sesión api, dev-down api sale con 1, lo dice y no cierra api-2
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- **Idempotencia de verdad**: cada objeto se crea solo si falta (`has-session -t "=..."`, ventanas por nombre); la segunda ejecución no crea, no reenvía y no cambia la ventana actual.
- **Targets sin sorpresas**: `=` en todo comando de sesión, ids de panel de `-P -F` para `send-keys`, ningún índice de ventana escrito a mano.
- **Nada externo llega a una shell**: rutas con `-c`, comandos con `send-keys -l`, `.tmux-kit` leído con `read -r` (sin `eval`, `source` ni `bash -c`).
- Comentarios del porqué: el `=`, por qué sanear el nombre antes que tmux, por qué `send-keys` y no el comando de `new-window`, por qué no `new-session -A`, `switch-client` frente a `attach`.
- Cabecera con uso y códigos de salida en los dos scripts; mensajes de error por stderr con el nombre del script; `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- README del kit al día: tabla de scripts, sección `## Proyectos` con el formato de `.tmux-kit` y la bitácora.

## Entrega

Commit con el mensaje:
```
feat(week-09): dev-up idempotente con .tmux-kit y dev-down
```
Entrega `bin/dev-up`, `bin/dev-down` y `README.md` de tu `starter/`.
