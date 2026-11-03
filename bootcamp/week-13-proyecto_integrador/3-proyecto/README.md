# Proyecto Semana 13 — tmux-kit: instalador, checks propios y entrega final

⏱️ 3 horas

## Contexto

En Norte Datos tu tmux-kit ya lo usa medio equipo, y cada alta nueva es la
misma conversación: "clónalo y haz un `ln -s`". La semana pasada Marta lo
lanzó con `ln -s ~/tmux-kit ~/.config/tmux` sobre una carpeta que ya existía:
`ln` creó el enlace **dentro** de su carpeta, tmux siguió cargando su config
vieja y nadie entendió por qué el prefix no era `C-a`. Otro compañero borró su
`~/.config/tmux` "para dejar sitio" y perdió dos años de ajustes.

Además, cada vez que tocas `conf.d/` lo compruebas a mano: abres tmux, pulsas
teclas, miras la barra. Un día un `set -g` con una errata llegó al repositorio
y el kit de todo el equipo arrancó con un error que nadie leyó.

Esta semana el kit se vuelve **instalable, desinstalable y comprobable por su
dueño**: `install.sh` enlaza el kit sin perder la config que había (backup),
se puede ensayar (`--dry-run`) y deshacer (`--uninstall`); `tests/run`
comprueba el kit sobre un servidor aislado y falla cuando alguien lo rompe.
Cierras con el README final y una auditoría.

## Estructura del proyecto

```
starter/                     # tu tmux-kit de la semana 12
├── install.sh               # TODO 1–6: rutas, enlace con backup, --dry-run, versión, --uninstall
├── tests/
│   └── run                  # TODO 7–10: servidor aislado, check(), tests del kit
├── tmux.conf
├── conf.d/                  # 10-options.conf … 70-remote.conf, sin cambios
├── bin/                     # los scripts de semanas anteriores, sin cambios
├── plugin/tmux-kit.tmux
├── docs/diagnostico.md
└── README.md                # paso 12: Instalación, Desinstalación, Atajos, Tests y bitácora
```

## Lo que debes construir

| Archivo | Qué hace |
|---|---|
| `install.sh` | Enlaza el directorio del kit en `${XDG_CONFIG_HOME:-~/.config}/tmux`. Idempotente: la segunda vez no cambia nada y sale con 0. Si ya había config (un directorio o un enlace a otro sitio), la mueve a `tmux.bak.AAAAMMDD-HHMMSS`. `--dry-run` imprime lo que haría sin tocar nada. `--uninstall` borra el enlace solo si apunta al kit (si no, sale con 1) y restaura el backup más reciente. Comprueba la versión con `bin/check-version` y avisa si existe `~/.tmux.conf`. Sale con 2 ante una opción desconocida |
| `tests/run` | Checks propios sobre un servidor aislado (`TMUX_SOCKET`, por defecto `kit-test-PID`) y un `HOME` temporal: la config carga, el prefix es `C-a`, recargar no duplica, `dev-up` e `install.sh` son idempotentes y tmux arranca con la config instalada. Una línea ✅/❌ por check; sale con 0 si pasan todos y con 1 si falla alguno. No deja servidores |
| `README.md` del kit | Secciones `## Instalación`, `## Desinstalación`, `## Atajos`, `## Scripts` y `## Tests`, y fila 13 de la bitácora |

**Contrato de `tests/run`** (lo que tiene que detectar): un `conf.d/` con un
error, un prefix que no es `C-a`, una recarga que añade teclas o hooks, un
`dev-up` que crea una segunda sesión, un `install.sh` que deja algo más que
un enlace al kit, y un enlace instalado con el que tmux no arranca con el kit.

## Paso a paso

0. **Dónde.** Todo se hace en el laboratorio. Desde la raíz del repositorio,
   en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás en una shell del laboratorio, fuera de tmux (`echo "$TMUX"` no
   imprime nada). Entra en el starter y prepara un `HOME` de usar y tirar:
   **nada de este proyecto toca tu `~/.config` real**.
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   H=$(mktemp -d)
   ins() { env -u XDG_CONFIG_HOME HOME="$H" ./install.sh "$@"; }
   ```
   (sin salida)

   `ins` lanza tu `install.sh` con ese `HOME`. Si cierras la shell, repite
   estas tres líneas. Los servidores de este proyecto son `-L kit-test` (el de
   `tests/run`) y `-L p13`; ninguno es el tuyo.

1. **Punto de partida.** El análisis de argumentos ya está hecho; instalar no,
   y `tests/run` no comprueba nada:
   ```bash
   ./install.sh --nope; echo $?
   ins; echo $?
   TMUX_SOCKET=kit-test tests/run; echo $?
   tmux -L kit-test ls
   tmux -L kit-test kill-server
   ```
   ```
   install.sh: opción desconocida: --nope
   Uso: install.sh                enlaza el kit en ${XDG_CONFIG_HOME:-~/.config}/tmux
        install.sh --dry-run      dice lo que haría, sin tocar nada (vale con --uninstall)
        install.sh --uninstall    quita el enlace, solo si apunta a este kit, y restaura el último backup
        install.sh -h | --help    esta ayuda
   Salida: 0 bien (también si no había nada que hacer), 1 tmux viejo, enlace ajeno o fallo, 2 uso incorrecto.
   2
   install.sh: instalar sin implementar
   1
   
   0/0 checks superados
   0
   tests: 1 windows (created Tue Nov  3 23:21:09 2026)
   ```
   Fíjate en dos cosas: `tests/run` sale con **0** sin comprobar nada (un test
   que nunca falla no prueba nada) y deja un servidor en marcha (la fecha
   varía). El último `kill-server` lo cierra (sin salida).

2. **Rutas e `is_ours` (TODO 1 y 2, `install.sh`).**

   a. **TODO 1.** Sustituye `kit=""` y `dest=""`:
   ```bash
   kit=$(cd "$(dirname "$0")" && pwd -P)
   dest="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
   ```
   `$PWD` sería el directorio desde el que lanzas el script, no el del kit, y
   `dirname "$0"` a secas vale `.` con `./install.sh`: el enlace apuntaría a
   sí mismo. `pwd -P` da la ruta absoluta y real (sin `readlink -f`, que el
   macOS de serie no tiene). Para probarlo, añade **temporalmente** justo
   debajo:
   ```bash
   echo "kit=$kit"; echo "dest=$dest"; exit 0
   ```
   y lánzalo desde el kit, desde otro directorio y con `XDG_CONFIG_HOME`:
   ```bash
   ins
   cd /tmp && env -u XDG_CONFIG_HOME HOME="$H" "$OLDPWD/install.sh"; cd - >/dev/null
   XDG_CONFIG_HOME="$H/xdg" HOME="$H" ./install.sh
   ```
   Algo como (cambia el nombre de `/tmp/tmp.…`):
   ```
   kit=/bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   dest=/tmp/tmp.OiVLY2vHh0/.config/tmux
   kit=/bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   dest=/tmp/tmp.OiVLY2vHh0/.config/tmux
   kit=/bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   dest=/tmp/tmp.OiVLY2vHh0/xdg/tmux
   ```
   Borra la línea temporal.

   b. **TODO 2.** `is_ours` decide qué se puede borrar: solo un enlace que,
   seguido, lleva al kit.
   ```bash
   is_ours() {
     [[ -L "$dest" ]] && [[ "$(cd "$dest" 2>/dev/null && pwd -P)" == "$kit" ]]
   }
   ```
   Pruébalo con otra línea temporal, justo antes del `case "$mode" in` final:
   ```bash
   if is_ours; then echo nuestro; else echo ajeno; fi; exit 0
   ```
   ```bash
   ins
   mkdir -p "$H/.config" && ln -s "$PWD" "$H/.config/tmux" && ins
   rm "$H/.config/tmux" && ln -s /tmp "$H/.config/tmux" && ins
   rm "$H/.config/tmux"
   ```
   ```
   ajeno
   nuestro
   ajeno
   ```
   Borra la línea temporal.

3. **Instalar (TODO 3, `install_kit`).** Borra el `: "$kit"` y el
   `die "instalar sin implementar"` y escribe:
   ```bash
   if is_ours; then
     echo "tmux-kit ya está instalado: $dest -> $kit"
   else
     if exists "$dest"; then
       run mv "$dest" "$(backup_name)"
     fi
     run mkdir -p "$(dirname "$dest")"
     run ln -sfn "$kit" "$dest"
   fi
   ```
   El backup va **antes** del enlace: sobre un directorio real, hasta
   `ln -sfn` crea el enlace dentro. `-n` importa cuando `$dest` ya es un
   enlace a un directorio: sin él, `ln` lo seguiría. `backup_name` ya está
   hecha. Instala dos veces:
   ```bash
   ins; echo $?
   readlink "$H/.config/tmux"
   ins; echo $?
   ls -A "$H/.config"
   ```
   ```
   0
   /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   tmux-kit ya está instalado: /tmp/tmp.OiVLY2vHh0/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   0
   tmux
   ```
   La primera vez no imprime nada todavía (eso llega con el TODO 4). Ahora
   tmux **sin `-f`** carga el kit, porque lee `~/.config/tmux/tmux.conf`:
   ```bash
   env -u XDG_CONFIG_HOME HOME="$H" tmux -L p13 new -d; tmux -L p13 show -gv prefix; tmux -L p13 kill-server
   ```
   ```
   C-a
   ```
   Y con una config real en su sitio, la guarda:
   ```bash
   rm "$H/.config/tmux"; mkdir "$H/.config/tmux"; echo "set -g status off # mía" > "$H/.config/tmux/tmux.conf"
   ins; echo $?
   ls -A "$H/.config"
   cat "$H"/.config/tmux.bak.*/tmux.conf
   ```
   Algo como (la fecha y hora del backup cambian):
   ```
   0
   tmux
   tmux.bak.20261103-232109
   set -g status off # mía
   ```

4. **`--dry-run` (TODO 4, `run`).** Borra el `: "$dry"`:
   ```bash
   run() {
     if (( dry )); then
       echo "(dry-run) $*"
     else
       echo "$*"
       "$@"
     fi
   }
   ```
   Todo cambio pasa por `run`, así que el ensayo cuenta exactamente lo que
   haría. Vuelve a la config real de antes y ensaya:
   ```bash
   rm -rf "$H"/.config/tmux.bak.* "$H/.config/tmux"; mkdir "$H/.config/tmux"; echo "set -g status off # mía" > "$H/.config/tmux/tmux.conf"
   ins --dry-run; echo $?
   ls -A "$H/.config"
   ins; echo $?
   ```
   Algo como:
   ```
   (dry-run) mv /tmp/tmp.OiVLY2vHh0/.config/tmux /tmp/tmp.OiVLY2vHh0/.config/tmux.bak.20261103-232109
   (dry-run) mkdir -p /tmp/tmp.OiVLY2vHh0/.config
   (dry-run) ln -sfn /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter /tmp/tmp.OiVLY2vHh0/.config/tmux
   0
   tmux
   mv /tmp/tmp.OiVLY2vHh0/.config/tmux /tmp/tmp.OiVLY2vHh0/.config/tmux.bak.20261103-232109
   mkdir -p /tmp/tmp.OiVLY2vHh0/.config
   ln -sfn /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter /tmp/tmp.OiVLY2vHh0/.config/tmux
   0
   ```
   Tras el ensayo, `.config` sigue teniendo solo `tmux` (la carpeta real).

5. **Versión y `~/.tmux.conf` (TODO 5).** Al principio de `install_kit`:
   ```bash
   "$kit/bin/check-version" >/dev/null || exit 1
   ```
   y al final, fuera del `if`:
   ```bash
   if [[ -e "$HOME/.tmux.conf" ]]; then
     echo "aviso: también existe ~/.tmux.conf y tmux lo carga junto al kit; muévelo si no lo quieres" >&2
   fi
   ```
   tmux 3.4 carga **todos** los archivos de config que existen, y
   `~/.tmux.conf` antes que el de `~/.config/tmux`. Prueba los dos casos
   (`TMUX_BIN=/bin/false` simula un tmux que no funciona):
   ```bash
   TMUX_BIN=/bin/false ins; echo $?
   touch "$H/.tmux.conf"; ins; echo $?
   rm "$H/.tmux.conf"
   ```
   ```
   tmux no está instalado o '/bin/false' no se puede ejecutar
   1
   tmux-kit ya está instalado: /tmp/tmp.OiVLY2vHh0/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter
   aviso: también existe ~/.tmux.conf y tmux lo carga junto al kit; muévelo si no lo quieres
   0
   ```

6. **Desinstalar (TODO 6, `uninstall_kit`).** Borra el `die` y escribe:
   ```bash
   if ! exists "$dest"; then
     echo "tmux-kit no está instalado en $dest: nada que hacer"
     return
   fi
   is_ours || die "$dest no es un enlace a este kit ($kit): no lo toco"

   run rm "$dest"
   local backups
   shopt -s nullglob
   backups=("$dest".bak.*)
   if (( ${#backups[@]} )); then
     run mv "${backups[${#backups[@]}-1]}" "$dest"
   fi
   ```
   El glob sale ordenado y la fecha va de año a segundo: el último es el más
   nuevo. Desinstala, repite, y prueba sin nada y con un enlace ajeno:
   ```bash
   ins --uninstall; echo $?
   ls -A "$H/.config"; cat "$H/.config/tmux/tmux.conf"
   ins --uninstall; echo $?
   rm -rf "$H/.config/tmux"; ins --uninstall; echo $?
   ln -s /tmp "$H/.config/tmux"; ins --uninstall; echo $?
   readlink "$H/.config/tmux"; rm "$H/.config/tmux"
   ```
   Algo como:
   ```
   rm /tmp/tmp.OiVLY2vHh0/.config/tmux
   mv /tmp/tmp.OiVLY2vHh0/.config/tmux.bak.20261103-232109 /tmp/tmp.OiVLY2vHh0/.config/tmux
   0
   tmux
   set -g status off # mía
   install.sh: /tmp/tmp.OiVLY2vHh0/.config/tmux no es un enlace a este kit (/bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter): no lo toco
   1
   tmux-kit no está instalado en /tmp/tmp.OiVLY2vHh0/.config/tmux: nada que hacer
   0
   install.sh: /tmp/tmp.OiVLY2vHh0/.config/tmux no es un enlace a este kit (/bc-tmux/bootcamp/week-13-proyecto_integrador/3-proyecto/starter): no lo toco
   1
   /tmp
   ```
   La segunda desinstalación encuentra tu carpeta real y **no la toca**; el
   enlace a `/tmp` tampoco. `install.sh` está terminado.

7. **Servidor aislado que se cierra (TODO 7, `tests/run`).** `kill-server`
   vuelve antes de que el servidor salga, y arrancar otro en ese hueco choca
   con el que muere. En tmux 3.4 el archivo del socket **se queda** al salir,
   así que la señal es que `list-sessions` falle:
   ```bash
   stop_server() {
     local i
     tmx kill-server 2>/dev/null || true
     for (( i = 0; i < 100; i++ )); do
       tmx list-sessions >/dev/null 2>&1 || return 0
       sleep 0.05
     done
   }

   cleanup() { stop_server; rm -rf "$tmp"; }
   ```
   ```bash
   TMUX_SOCKET=kit-test tests/run; echo $?
   tmux -L kit-test ls
   ```
   ```
   
   0/0 checks superados
   0
   no server running on /tmp/tmux-1000/kit-test
   ```
   Ya no queda servidor (compáralo con el paso 1).

8. **`check` (TODO 8).**
   ```bash
   check() {
     if "$2" >/dev/null 2>&1; then
       echo "✅ $1"
       passed=$(( passed + 1 ))
     else
       echo "❌ $1"
       failed=$(( failed + 1 ))
     fi
   }
   ```
   `(( passed++ ))` vale 0 la primera vez y `set -e` cortaría el script. Y
   como cada test corre dentro del `if`, `set -e` **no** lo para en el primer
   error: por eso los tests encadenan sus pasos con `&&`.
   ```bash
   TMUX_SOCKET=kit-test tests/run; echo $?
   ```
   ```
   ✅ tmux.conf carga sin errores
   ❌ El prefix es C-a
   ❌ Recargar dos veces no duplica teclas ni hooks
   ❌ bin/dev-up dos veces deja una sola sesión
   ❌ install.sh dos veces deja un solo enlace al kit
   ❌ tmux arranca con la config instalada

   1/6 checks superados
   1
   ```
   `t_config_loads` venía hecho: `source-file` sale con 1 si la config tiene un
   error. Arrancar con `-f` no sirve para esto: `tmux -f conf_rota new -d`
   sale con 0.

9. **Prefix y recarga (TODO 9).** Borra los dos `false`:
   ```bash
   t_prefix() { [[ "$(tmx show -gv prefix)" == C-a ]]; }

   t_reload() {
     local keys hooks
     keys=$(tmx list-keys | wc -l) &&
       hooks=$(tmx show-hooks -g | wc -l) &&
       tmx source-file "$kit/tmux.conf" &&
       tmx source-file "$kit/tmux.conf" &&
       [[ "$(tmx list-keys | wc -l)" == "$keys" ]] &&
       [[ "$(tmx show-hooks -g | wc -l)" == "$hooks" ]]
   }
   ```
   ```bash
   TMUX_SOCKET=kit-test tests/run; echo $?
   ```
   ```
   ✅ tmux.conf carga sin errores
   ✅ El prefix es C-a
   ✅ Recargar dos veces no duplica teclas ni hooks
   ❌ bin/dev-up dos veces deja una sola sesión
   ❌ install.sh dos veces deja un solo enlace al kit
   ❌ tmux arranca con la config instalada

   3/6 checks superados
   1
   ```

10. **`dev-up` e instalación (TODO 10).** `TMUX_SOCKET` está exportado, así
    que `dev-up` habla con el servidor de los tests; `HOME` es el temporal de
    `tests/run`.
    ```bash
    t_dev_up() {
      mkdir -p "$tmp/api" &&
        "$kit/bin/dev-up" -d "$tmp/api" &&
        "$kit/bin/dev-up" -d "$tmp/api" &&
        [[ "$(tmx list-sessions -F '#{session_name}' | grep -cx api)" == 1 ]]
    }

    t_install() {
      "$kit/install.sh" &&
        "$kit/install.sh" &&
        [[ -L "$HOME/.config/tmux" ]] &&
        [[ "$(cd "$HOME/.config/tmux" && pwd -P)" == "$kit" ]] &&
        [[ "$(cd "$HOME/.config" && echo *)" == tmux ]]
    }

    t_installed_starts() {
      stop_server &&
        tmx new-session -d -s tests &&
        [[ "$(tmx show -gv prefix)" == C-a ]] &&
        [[ "$(tmx display -p '#{config_files}')" == "$kit/tmux.conf" ]]
    }
    ```
    `#{config_files}` da la ruta ya resuelta (la del kit), no la del enlace.
    ```bash
    TMUX_SOCKET=kit-test tests/run; echo $?
    ```
    ```
    ✅ tmux.conf carga sin errores
    ✅ El prefix es C-a
    ✅ Recargar dos veces no duplica teclas ni hooks
    ✅ bin/dev-up dos veces deja una sola sesión
    ✅ install.sh dos veces deja un solo enlace al kit
    ✅ tmux arranca con la config instalada

    6/6 checks superados
    0
    ```

11. **Mutación: rompe el kit a propósito.** Un test que nunca ha estado en
    rojo no está probado. Sobre una copia (nunca sobre tu kit):
    ```bash
    M=$(mktemp -d); cp -r . "$M"; echo "set -g prefix C-b" > "$M/conf.d/99-mutante.conf"; "$M/tests/run"; echo $?
    ```
    ```
    ✅ tmux.conf carga sin errores
    ❌ El prefix es C-a
    ✅ Recargar dos veces no duplica teclas ni hooks
    ✅ bin/dev-up dos veces deja una sola sesión
    ✅ install.sh dos veces deja un solo enlace al kit
    ❌ tmux arranca con la config instalada

    4/6 checks superados
    1
    ```
    Ahora con un error de sintaxis en `conf.d/`:
    ```bash
    echo "set -g opcion-que-no-existe on" > "$M/conf.d/99-mutante.conf"; "$M/tests/run"; echo $?
    rm -rf "$M"
    ```
    ```
    ❌ tmux.conf carga sin errores
    ✅ El prefix es C-a
    ❌ Recargar dos veces no duplica teclas ni hooks
    ✅ bin/dev-up dos veces deja una sola sesión
    ✅ install.sh dos veces deja un solo enlace al kit
    ✅ tmux arranca con la config instalada

    4/6 checks superados
    1
    ```
    Con el error, tmux **arranca igual** con el prefix bueno: solo
    `source-file` lo delata.

12. **README final del kit.** En `starter/README.md`:
    - `## Instalación`: `install.sh`, `--dry-run`, el backup
      `tmux.bak.FECHA`, el aviso de `~/.tmux.conf` y los códigos de salida
      (cambia el `ln -s` que había: sin `-n` es justo el fallo de Marta).
    - `## Desinstalación`: `--uninstall`, qué borra y qué no.
    - `## Atajos`: renombra `## Teclas`.
    - `## Tests`: cómo lanzar `tests/run`, `TMUX_SOCKET` y el contrato (qué
      detecta, la lista de [Lo que debes construir](#lo-que-debes-construir)).
    - `## Scripts` ya existe. Añade `install.sh` y `tests/run` a
      `## Estructura` y la fila 13 a la bitácora.

    Comprueba los títulos:
    ```bash
    grep -xE '## (Instalación|Desinstalación|Atajos|Scripts|Tests)' README.md
    ```
    ```
    ## Scripts
    ## Instalación
    ## Desinstalación
    ## Tests
    ## Atajos
    ```
    (el orden es el de tu README).

13. **Auditoría.** shellcheck de todo lo ejecutable, ningún TODO y el tiempo
    de arranque:
    ```bash
    shellcheck install.sh tests/run bin/* plugin/*.tmux; echo $?
    grep -rn --exclude-dir=plugins TODO . ; echo $?
    time (tmux -L p13 -f "$PWD/tmux.conf" new -d; tmux -L p13 kill-server)
    ```
    Algo como (los tiempos varían):
    ```
    0
    1
    
    real	0m0.030s
    user	0m0.003s
    sys	0m0.003s
    ```
    `grep` sale con 1: no encontró ningún TODO. Si el arranque pasa de unas
    décimas, busca un `#()` caro en la barra (`1-teoria/`). Sal del
    laboratorio (`exit`) y verifica desde tu equipo.

## Verificación

Desde la raíz del repositorio, en tu equipo (tarda unos minutos):

```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 13
```
```
Semana 13 — Proyecto integrador

  ✅ install.sh enlaza ~/.config/tmux al directorio del kit
  ✅ install.sh instala en $XDG_CONFIG_HOME/tmux cuando XDG_CONFIG_HOME está definida
  ✅ Lanzado como ./install.sh desde el kit, el enlace guarda la ruta absoluta
  ✅ Ejecutar install.sh dos veces sale con 0 y no crea backups
  ✅ install.sh guarda la config que había en un backup, con su contenido intacto
  ✅ Tras install.sh, tmux sin -f arranca con la config del kit (prefix C-a)
  ✅ install.sh --dry-run explica lo que haría sin cambiar nada
  ✅ install.sh avisa si también existe ~/.tmux.conf
  ✅ install.sh --uninstall quita el enlace y devuelve la config que había
  ✅ install.sh --uninstall sale con 0 si no hay nada instalado y con 1 ante un enlace ajeno, que no toca
  ✅ install.sh sale con 2 ante una opción desconocida, sin tocar nada
  ✅ tests/run tiene al menos 5 checks y todos pasan
  ✅ tests/run falla si alguien cambia el prefix
  ✅ tests/run falla si un archivo de conf.d tiene un error
  ✅ tests/run no deja ningún servidor de tmux en marcha
  ✅ El README del kit tiene las secciones Instalación, Desinstalación, Atajos, Scripts y Tests
  ✅ install.sh, tests/run, bin/ y plugin/ pasan shellcheck
  ✅ El kit no tiene ningún TODO

18/18 comprobaciones superadas.
```

## ✅ Requisitos verificables

- [ ] install.sh enlaza ~/.config/tmux al directorio del kit
- [ ] install.sh instala en $XDG_CONFIG_HOME/tmux cuando XDG_CONFIG_HOME está definida
- [ ] Lanzado como ./install.sh desde el kit, el enlace guarda la ruta absoluta
- [ ] Ejecutar install.sh dos veces sale con 0 y no crea backups
- [ ] install.sh guarda la config que había en un backup, con su contenido intacto
- [ ] Tras install.sh, tmux sin -f arranca con la config del kit (prefix C-a)
- [ ] install.sh --dry-run explica lo que haría sin cambiar nada
- [ ] install.sh avisa si también existe ~/.tmux.conf
- [ ] install.sh --uninstall quita el enlace y devuelve la config que había
- [ ] install.sh --uninstall sale con 0 si no hay nada instalado y con 1 ante un enlace ajeno, que no toca
- [ ] install.sh sale con 2 ante una opción desconocida, sin tocar nada
- [ ] tests/run tiene al menos 5 checks y todos pasan
- [ ] tests/run falla si alguien cambia el prefix
- [ ] tests/run falla si un archivo de conf.d tiene un error
- [ ] tests/run no deja ningún servidor de tmux en marcha
- [ ] El README del kit tiene las secciones Instalación, Desinstalación, Atajos, Scripts y Tests
- [ ] install.sh, tests/run, bin/ y plugin/ pasan shellcheck
- [ ] El kit no tiene ningún TODO

## Calidad

Además de los checks, se revisa (40 pts, ver la [rúbrica](../rubrica-evaluacion.md)):

- **Nunca se pierde config**: backup antes del enlace, `--uninstall` que solo borra un enlace propio, ningún `rm -rf` sobre `$dest`.
- **Idempotencia y ensayo**: la segunda ejecución no cambia nada; todo cambio pasa por `run`, así que `--dry-run` cuenta exactamente lo que haría.
- **Portabilidad**: `pwd -P` en vez de `readlink -f`, nada de `${array[-1]}`, `XDG_CONFIG_HOME` respetado, ninguna ruta del autor escrita a mano.
- **Tests que valen**: servidor aislado, `HOME` temporal, `trap` que limpia, pasos encadenados con `&&`; los dos mutantes del paso 11 los ponen en rojo.
- Comentarios del porqué: `-n` en `ln`, el orden backup → enlace, por qué `source-file` y no `-f`, por qué se espera tras `kill-server`.
- README final como contrato: instalación, desinstalación, atajos, scripts, tests y bitácora al día.

## Entrega

Commit con el mensaje:
```
feat(week-13): install.sh, tests/run y README final del kit
```
Entrega `install.sh`, `tests/run` y `README.md` de tu `starter/`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — Instalador roto](../2-practicas/lab-06-instalador-roto/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 13](../README.md)
