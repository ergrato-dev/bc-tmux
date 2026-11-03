# Lab 05 — Config modular

⏱ Duración estimada: ~60 min

## Objetivo

Dividir una config en un punto de entrada y módulos de `conf.d/` que cargan en orden desde cualquier directorio, y comprobar con un script que cada módulo carga por sí solo.

## Contexto

- `tmux.conf` queda como punto de entrada: guarda su directorio en `@lab-dir` y carga `conf.d/*.conf`. El glob se ordena por nombre.
- `#{d:current_file}` es el directorio del archivo **que se está leyendo**: en un módulo de `conf.d/`, es `conf.d/`.
- Un `local.conf` opcional, fuera de git, guarda lo propio de cada máquina.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte (solo en el
   paso 6). En las dos, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-05-config-modular
   ```
   El servidor es `-L lab`. El starter fija el prefix **`C-a`** (línea
   `set -g prefix C-a`): es el que usas al conectarte. Como la config se lee
   al arrancar, casi todas las pruebas empiezan con
   `tmux -L lab kill-server 2>/dev/null` (el `2>/dev/null` calla el aviso si
   no había servidor).

1. **Lee** `starter/tmux.conf`: opciones, prefix y teclas en un solo
   archivo. Al terminar el lab tendrás:
   ```
   starter/
   ├── tmux.conf              # solo @lab-dir y source-file
   ├── conf.d/
   │   ├── 10-opciones.conf
   │   └── 20-bindings.conf
   ├── bin/copiar
   └── verificar-modulos.sh
   ```

2. **Divide.** Crea el directorio:
   ```bash
   mkdir -p starter/conf.d
   ```
   Mueve las líneas de `starter/tmux.conf` (bórralas de allí) a dos
   archivos nuevos, tal cual:

   `starter/conf.d/10-opciones.conf`, las opciones:
   ```tmux
   set -s escape-time 10
   set -sF copy-command "#{d:current_file}/bin/copiar"

   set -g base-index 1
   set -g mouse on

   setw -g mode-keys vi
   setw -g pane-base-index 1
   ```
   `starter/conf.d/20-bindings.conf`, prefix y teclas:
   ```tmux
   set -g prefix C-a
   unbind C-b
   bind C-a send-prefix
   bind -T copy-mode-vi y send -X copy-pipe-and-cancel
   ```
   En `starter/tmux.conf` quedan la cabecera, los comentarios de los TODOs
   y dos líneas: la del **TODO 1** (pista: `set -gF @lab-dir
   "#{d:current_file}"`) y, para el **TODO 2**, empieza por lo evidente:
   ```tmux
   source-file conf.d/*.conf
   ```
   Pruébalo arrancando **desde `starter/`**:
   ```bash
   tmux -L lab kill-server 2>/dev/null
   (cd starter && tmux -L lab -f "$PWD/tmux.conf" new -d \; show -gv base-index \; show -gv prefix)
   ```
   ```
   1
   C-a
   ```
   Ahora desde la carpeta del lab, que es donde estás:
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index
   tmux -L lab source-file /dev/null
   ```
   Algo como (el número es la línea de tu `source-file`):
   ```
   0
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-05-config-modular/starter/tmux.conf:17: conf.d/*.conf: No such file or directory
   ```
   No cargó ningún módulo: la ruta relativa se resuelve desde el directorio
   en el que **arrancas tmux**, no desde el archivo. El error no sale al
   arrancar con `new -d`: queda guardado hasta el primer cliente o el primer
   `source-file` (lab 01, paso 4).

3. **Desde cualquier directorio.** Cambia la línea por la versión con
   `@lab-dir` (`-F` expande el formato antes de buscar el archivo):
   ```tmux
   source-file -F "#{@lab-dir}/conf.d/*.conf"
   ```
   Repite desde `/` y desde aquí:
   ```bash
   tmux -L lab kill-server
   (cd / && tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d \; show -gv base-index)
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index
   ```
   ```
   1
   1
   ```
   (`$OLDPWD`, dentro del paréntesis, es la carpeta del lab.)

4. **Rutas dentro de un módulo.** `copy-command` usaba
   `#{d:current_file}` cuando vivía en `tmux.conf`. Mira a dónde apunta
   ahora:
   ```bash
   tmux -L lab show -sv copy-command
   test -x "$(tmux -L lab show -sv copy-command)"; echo $?
   ```
   Algo como:
   ```
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-05-config-modular/starter/conf.d/bin/copiar
   1
   ```
   `current_file` ya es `conf.d/10-opciones.conf`, y `conf.d/bin/copiar`
   no existe: copiar no haría nada, sin error. En `10-opciones.conf`, cambia
   la línea por:
   ```tmux
   set -sF copy-command "#{@lab-dir}/bin/copiar"
   ```
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -sv copy-command
   test -x "$(tmux -L lab show -sv copy-command)"; echo $?
   ```
   Algo como:
   ```
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-05-config-modular/starter/bin/copiar
   0
   ```

5. **El orden.** Crea un módulo de prueba que quieres que sea la "base":
   ```bash
   echo 'set -g base-index 5' > starter/conf.d/5-prueba.conf
   printf '%s\n' starter/conf.d/*.conf
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index
   ```
   ```
   starter/conf.d/10-opciones.conf
   starter/conf.d/20-bindings.conf
   starter/conf.d/5-prueba.conf
   5
   ```
   Querías una base que `10-opciones.conf` afina, pero `5-` va **después**
   de `20-` en orden alfabético y gana. Renómbralo con dos cifras:
   ```bash
   mv starter/conf.d/5-prueba.conf starter/conf.d/05-prueba.conf
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index
   rm starter/conf.d/05-prueba.conf
   ```
   ```
   1
   ```
   Siempre dos cifras delante.

6. **Lo de cada máquina.** Añade al final de `starter/tmux.conf` (es el
   resto del TODO 2):
   ```tmux
   source-file -qF "#{@lab-dir}/local.conf"
   ```
   Sin `local.conf`, `-q` no se queja:
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d
   tmux -L lab source-file /dev/null; echo $?
   ```
   ```
   0
   ```
   Crea uno, reinicia y conéctate:
   ```bash
   echo 'set -g status-style bg=colour22' > starter/local.conf
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv status-style
   ```
   ```
   bg=colour22
   ```
   En la terminal B, `tmux -L lab attach`: la barra es verde. Sal con
   `C-a` `d` (el prefix de este starter): `[detached (from session 0)]`.
   `local.conf` no se versiona. En la terminal A:
   ```bash
   echo 'local.conf' > starter/.gitignore
   git check-ignore -v starter/local.conf
   rm starter/local.conf
   ```
   Algo como (la ruta del `.gitignore` es desde la raíz del repositorio):
   ```
   bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-05-config-modular/starter/.gitignore:1:local.conf	starter/local.conf
   ```

7. **Por versión.** Al final de `starter/conf.d/10-opciones.conf`, un bloque
   que solo se aplica en tmux 3.5 o posterior:
   ```tmux
   %if "#{>=:#{version},3.5}"
   set -g @lab-moderno on
   %else
   set -g @lab-moderno off
   %endif
   ```
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv @lab-moderno
   tmux -L lab display -p '#{version} #{>=:3.10,3.5}'
   ```
   ```
   off
   3.4 0
   ```
   `off` en el laboratorio (3.4). Se evalúa al leer el archivo, sin lanzar
   ninguna shell. Ojo: `>=` compara **texto**, no números: sirve de 3.4 a
   3.9, pero `3.10` saldría menor que `3.5` (la segunda columna, `0`).

8. **Cada módulo, por separado.** `starter/verificar-modulos.sh DIR` carga
   cada archivo de `DIR/conf.d/` en un servidor limpio y propio
   (`-L verificar-modulos`) y dice cuáles fallan. Ya valida `DIR` y define
   `sock` y `tmx`; al final hay un `echo "sin implementar"` y un `exit 1`
   que borras en el TODO 2. Si no lo tienes: `sudo apt install shellcheck`
   (macOS: `brew install shellcheck`).

   1. **TODO 2: el bucle** (primero este, para poder probar el 1). Pista:
      ```bash
      fallos=0
      for f in "$dir"/conf.d/*.conf; do
        tmux -L "$sock" kill-server 2>/dev/null || true   # servidor limpio por módulo
        tmx -f /dev/null new -d
        tmx set -g @lab-dir "$dir"                         # los módulos lo usan
        if err=$(tmx source-file "$f" 2>&1); then ... else ... fi
      done
      ```
      En el `then`, `echo "ok     ${f##*/}"`; en el `else`,
      `echo "error  ${f##*/}: ${err//$'\n'/; }"` (los mensajes en una línea)
      y `fallos=$((fallos + 1))`. Borra el `echo "sin implementar"` y el
      `exit 1`.
      ```bash
      ./starter/verificar-modulos.sh starter; echo $?
      ```
      ```
      ok     10-opciones.conf
      ok     20-bindings.conf
      0
      ```
   2. **TODO 1: no dejar servidores vivos.** Sin limpieza, el último
      servidor sigue arrancado:
      ```bash
      tmux -L verificar-modulos ls
      ```
      Algo como (cambia la fecha):
      ```
      0: 1 windows (created Mon Nov  2 23:58:10 2026)
      ```
      Pista: `trap 'tmux -L "$sock" kill-server 2>/dev/null || true' EXIT`,
      antes del bucle. Repite el script y la pregunta:
      ```bash
      ./starter/verificar-modulos.sh starter >/dev/null
      tmux -L verificar-modulos ls
      ```
      Algo como (cambia el uid de la ruta):
      ```
      no server running on /tmp/tmux-1000/verificar-modulos
      ```
   3. **TODO 3: el código de salida.** Pista: última línea
      `(( fallos == 0 ))`: con `set -e`, sale con 1 si es falso.
      ```bash
      echo 'set -g base-indx 5' > starter/conf.d/30-roto.conf
      ./starter/verificar-modulos.sh starter; echo $?
      rm starter/conf.d/30-roto.conf
      shellcheck starter/verificar-modulos.sh; echo $?
      ```
      ```
      ok     10-opciones.conf
      ok     20-bindings.conf
      error  30-roto.conf: invalid option: base-indx
      1
      0
      ```
   Referencia: `solucion/verificar-modulos.sh`.

9. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `starter/tmux.conf` no tiene ningún `set` salvo el de `@lab-dir`, ni ningún `bind` (paso 2)
- [ ] Arrancando desde `/`, `show -gv base-index` imprime `1` (paso 3)
- [ ] `test -x "$(tmux -L lab show -sv copy-command)"` sale con 0 (paso 4)
- [ ] Explicas por qué `5-prueba.conf` ganaba a `10-opciones.conf` (paso 5)
- [ ] Con y sin `local.conf`, la config carga sin errores, y `git check-ignore` confirma que no se versiona (paso 6)
- [ ] Explicas por qué `#{>=:...}` no sirve para comparar `3.10` con `3.5` (paso 7)
- [ ] `verificar-modulos.sh` da las salidas del paso 8, no deja servidor vivo y `shellcheck` sale con 0

## Reto extra

Haz que `prefix` `R` (mayúscula) abra en una ventana nueva `$EDITOR` sobre
`conf.d/` y recargue al cerrar el editor. Pista: `new-window` acepta un
comando, y `source-file` puede ir detrás con `;`.
