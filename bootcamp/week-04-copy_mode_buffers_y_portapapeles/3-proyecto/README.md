# Proyecto Semana 04 — tmux-kit: copiar en local y por SSH

⏱ Duración estimada: ~3 h

## Contexto

Trabajas en tu portátil con WSL y, dos veces al día, por SSH en un servidor de staging. En local copias un comando de un log con el ratón y pegas en Slack: llega `aÃ±o` en lugar de `año`. En staging copias con `y` en copy mode y no pega nada, porque `xclip` copió en un portapapeles del servidor que nadie ve. Cada sitio necesita un camino distinto, y tu config debería elegirlo sola.

Añades a tu `tmux-kit` su **primer `tmux.conf`** (copy mode con teclas vi fijadas, historial amplio, OSC 52) y el script **`bin/kit-copiar`**: recibe texto por stdin y lo deja en **tu** portapapeles, estés donde estés.

```bash
$ printf 'año' | kit-copiar                  # WSL: win32yank.exe; macOS: pbcopy; ...
$ ssh staging
staging$ printf 'año' | kit-copiar           # por SSH: OSC 52 hasta tu terminal
```

## Estructura del proyecto

```
starter/                 ← tu tmux-kit de la semana 03 + lo nuevo (aquí trabajas)
├── README.md            ← añade kit-copiar, cómo instalar tmux.conf y la bitácora
├── tmux.conf            ← TODOs 1-5 (nuevo)
└── bin/
    ├── check-version    (semana 01)
    ├── kit-tree         (semana 01)
    ├── kit-layout       (semana 02)
    ├── sesiones         (semana 03)
    └── kit-copiar       ← TODOs 1-2 (nuevo)
tests/                   ← herramientas falsas para el autograding (no se tocan)
├── path-falso
└── falso-clip
```

Se trabaja sobre `3-proyecto/starter/`: es lo que corrige el autograding.

## Lo que debes construir

### `tmux.conf`

1. Copy mode con teclas vi fijadas (`setw -g mode-keys vi`), `history-limit` de al menos 10000, `set-clipboard on` y `copy-command` apuntando a `bin/kit-copiar` del propio kit con `set -sF ... "#{d:current_file}/bin/kit-copiar"`. En la tabla `copy-mode-vi`: `v` empieza la selección, `C-v` la vuelve rectangular e `y` copia con `copy-pipe-and-cancel` **sin comando**. Resultado: copiar con `y` en copy mode llega a tu portapapeles.

### `bin/kit-copiar`

2. **OSC 52** cuando estás por SSH (`SSH_CONNECTION` o `SSH_TTY`) o no hay portapapeles gráfico. Dentro de tmux (`$TMUX` no vacío), con `tmx load-buffer -w -`; fuera, escribiendo `\033]52;c;BASE64\a` en una sola línea a `"${KIT_TTY:-/dev/tty}"` (`KIT_TTY` existe para que el autograding lea la secuencia).
3. En local, la herramienta de cada plataforma, en este orden: macOS (`uname` = `Darwin`) `pbcopy`; WSL (`WSL_DISTRO_NAME`) `win32yank.exe -i` o `clip.exe`; Wayland (`WAYLAND_DISPLAY`) `wl-copy`; X11 (`DISPLAY`) `xclip -selection clipboard` o `xsel --clipboard --input`. SSH va antes que todo: por SSH, una herramienta local copiaría en la máquina remota.
4. Si la plataforma se detecta pero falta su herramienta, sale con **1** y dice por stderr qué instalar (`instala wl-clipboard (sudo apt install wl-clipboard)`).
5. Con argumentos, muestra el uso y sale con **2** (ya viene hecho en el starter).

### Kit

6. Añade `kit-copiar` a la tabla del `README.md` con un ejemplo, documenta la instalación con `ln -s` y escribe la bitácora de la semana.

## Paso a paso

0. Abre una terminal **fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía). Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/3-proyecto/starter
   F="$PWD/../tests/path-falso"
   ```
   Las pruebas de `tmux.conf` usan un servidor aparte, `-L kit`, que se
   arranca y se para en cada prueba. `F` crea un `PATH` con herramientas de
   portapapeles falsas (lab 05, paso 3): guardan lo que reciben en
   `NOMBRE.datos` y sus argumentos en `NOMBRE.args`.

1. **`tmux.conf`, TODO 1**: teclas vi fijadas.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d \; show -gwv mode-keys; tmux -L kit kill-server
   ```
   ```
   vi
   ```

2. **TODO 2**: `history-limit`.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d \; show -gv history-limit; tmux -L kit kill-server
   ```
   ```
   50000
   ```

3. **TODO 3**: `set-clipboard on`.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d \; show -sv set-clipboard; tmux -L kit kill-server
   ```
   ```
   on
   ```

4. **TODO 4**: `copy-command` con `set -sF` y `#{d:current_file}`.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d \; show -sv copy-command; tmux -L kit kill-server
   tmux -L kit -f tmux.conf new -d \; show -sv copy-command; tmux -L kit kill-server
   ```
   Algo como (tu ruta hasta el repositorio):
   ```
   /home/tú/bc-tmux/bootcamp/week-04-copy_mode_buffers_y_portapapeles/3-proyecto/starter/bin/kit-copiar
   ./bin/kit-copiar
   ```
   La primera es absoluta porque pasaste `-f` con `$PWD`. La segunda no
   funcionaría: tmux ejecuta `copy-command` desde tu `$HOME`. Instalado en
   `~/.config/tmux`, la ruta siempre es absoluta.

5. **TODO 5**: las tres teclas de `copy-mode-vi`.
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d \; list-keys -T copy-mode-vi | grep -E ' (v|C-v|y) '; tmux -L kit kill-server
   ```
   ```
   bind-key -T copy-mode-vi C-v               send-keys -X rectangle-toggle
   bind-key -T copy-mode-vi v                 send-keys -X begin-selection
   bind-key -T copy-mode-vi y                 send-keys -X copy-pipe-and-cancel
   ```

6. **`bin/kit-copiar`, TODO 1** (al final del archivo): la elección del
   método. Borra las dos líneas `sin implementar` del final y escribe la
   cadena `if`/`elif` del comentario (la forma es la de `copiar.sh` del lab
   05, con SSH delante de todo). Pruébala rama a rama:
   ```bash
   f=$("$F" wl-copy); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=w bin/kit-copiar; cat "$f/wl-copy.datos"; echo
   f=$("$F"); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=w bin/kit-copiar; echo $?
   f=$("$F" xclip); printf hola | env -i PATH="$f" DISPLAY=:0 bin/kit-copiar; cat "$f/xclip.datos"; echo; cat "$f/xclip.args"
   f=$("$F" xsel); printf hola | env -i PATH="$f" DISPLAY=:0 bin/kit-copiar; cat "$f/xsel.datos"; echo
   f=$("$F" pbcopy darwin); printf hola | env -i PATH="$f" bin/kit-copiar; cat "$f/pbcopy.datos"; echo
   f=$("$F" clip.exe); printf hola | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu bin/kit-copiar; ls "$f" | grep datos
   f=$("$F" clip.exe win32yank.exe); printf hola | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu bin/kit-copiar; ls "$f" | grep datos
   ```
   ```
   hola
   kit-copiar: instala wl-clipboard (sudo apt install wl-clipboard)
   1
   hola
   -selection clipboard
   hola
   hola
   clip.exe.datos
   win32yank.exe.datos
   ```
   (`darwin` hace que el `uname` falso diga `Darwin`; sin él dice `Linux`,
   también si estás en un Mac.) Las ramas de OSC 52 todavía salen con 99:
   las arregla el TODO 2.

7. **TODO 2**: la función `osc52`. Borra sus dos líneas `sin implementar`.
   Fuera de tmux, la secuencia va a `KIT_TTY` (aquí, un archivo); por SSH
   gana a cualquier herramienta local:
   ```bash
   f=$("$F" wl-copy); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=w SSH_CONNECTION=x KIT_TTY=/tmp/osc bin/kit-copiar; cat -v /tmp/osc; echo; ls "$f" | grep -c datos
   f=$("$F"); printf hola | env -i PATH="$f" KIT_TTY=/tmp/osc bin/kit-copiar; cat -v /tmp/osc; echo
   ```
   ```
   ^[]52;c;aG9sYQ==^G
   0
   ^[]52;c;aG9sYQ==^G
   ```
   (`0`: `wl-copy` no recibió nada. `cat -v` escribe Escape como `^[` y el
   `\a` final como `^G`.) Dentro de tmux, por `load-buffer -w`. Simúlalo con
   un servidor de prueba y `TMUX` apuntando a él:
   ```bash
   tmux -L kit -f /dev/null new -d
   f=$("$F"); printf hola | env -i PATH="$f" SSH_CONNECTION=x TMUX_SOCKET=kit TMUX="$(tmux -L kit display -p '#{socket_path}'),1,0" bin/kit-copiar; tmux -L kit show-buffer; echo
   tmux -L kit kill-server
   ```
   ```
   hola
   ```
   Y el uso, que ya venía hecho:
   ```bash
   printf hola | bin/kit-copiar algo; echo $?
   ```
   ```
   Uso: ... | kit-copiar
   Elige el método según dónde se ejecuta:
     - por SSH, o sin portapapeles gráfico: OSC 52 (lo pega tu terminal local)
     - macOS: pbcopy · WSL: win32yank.exe o clip.exe · Wayland: wl-copy
     - X11: xclip o xsel
   Salida: 0 copiado, 1 falta la herramienta de tu sistema, 2 uso incorrecto.
   2
   ```

8. **Sin TODOs y sin avisos.** Borra los comentarios `TODO` de `tmux.conf` y
   de `bin/kit-copiar`, y deja en su lugar el porqué de cada línea (ver
   [Calidad](#calidad)). Después (`sudo apt install shellcheck` o
   `brew install shellcheck` si no lo tienes):
   ```bash
   grep -n TODO bin/* tmux.conf; shellcheck bin/*; echo $?
   ```
   ```
   0
   ```
   (El `grep` no imprime nada.)

9. **La prueba que cuenta: copiar y pegar.** Haz la versión de tu sitio.
   En las dos, el prefix es `C-b` (el kit todavía no define otro, semana 05)
   y la copia es: `echo hola`, `C-b` `[`, `?` `hola` `Enter` (el cursor va a
   la salida `hola`), `v` (empieza), `e` (fin de palabra), `y` (copia y sale).

   - **En tu máquina.** Arranca el kit y quédate conectado en esta terminal
     (ruta absoluta en `-f`, por el paso 4):
     ```bash
     tmux -L kit -f "$PWD/tmux.conf"
     ```
     Copia, sal con `C-b` `d` (`[detached (from session 0)]`) y comprueba
     el portapapeles de tu sistema (o pega con `Ctrl+V`/`Cmd+V` en el
     navegador):

     | Sistema | Comando | Imprime |
     |---|---|---|
     | macOS | `pbpaste; echo` | `hola` |
     | WSL | `win32yank.exe -o; echo` (o `powershell.exe -NoProfile -Command Get-Clipboard`) | `hola` |
     | Wayland | `wl-paste` | `hola` |
     | X11 | `xclip -o -selection clipboard; echo` | `hola` |

   - **En el laboratorio**, sin portapapeles: herramientas falsas, como en
     el lab 05.
     ```bash
     f=$("$F" wl-copy)
     env -i PATH="$f" HOME="$HOME" TERM="$TERM" WAYLAND_DISPLAY=w tmux -L kit -f "$PWD/tmux.conf"
     ```
     Copia, sal con `C-b` `d` y:
     ```bash
     cat "$f/wl-copy.datos"; echo
     ```
     ```
     hola
     ```

   Con `set-clipboard on`, al copiar tmux envía **también** su propio OSC 52
   a tu terminal: en local, el texto llega dos veces al mismo portapapeles.
   Por SSH, `kit-copiar` usa `load-buffer -w` y verás dos buffers iguales
   (`tmux -L kit list-buffers`). Es inofensivo, y se deja así porque cada
   camino cubre lo que el otro no: el OSC 52 de tmux llega aunque
   `copy-command` falle, y `kit-copiar` funciona también en un pipe
   (`cat log | bin/kit-copiar`). Al terminar:
   ```bash
   tmux -L kit kill-server
   ```

10. **Por SSH** (si tienes un servidor). Tu terminal local tiene que aceptar
    OSC 52 (lab 06, paso 1). Copia el kit al servidor y pruébalo allí:
    ```bash
    scp -r "$PWD" servidor:tmux-kit
    ssh servidor
    tmux -L kit -f ~/tmux-kit/tmux.conf
    ```
    Dentro, `echo hola` y las mismas teclas. Pega en tu portátil: `hola`. Si
    el `ssh` lo lanzas desde un tmux local, ese tmux también necesita
    `set-clipboard on` para dejar pasar la secuencia. Sal con `C-b` `d`,
    `tmux -L kit kill-server` y `exit`.

11. **Instalar** (opcional: toca tu config real). Mira antes si ya tienes una:
    ```bash
    ls -ld ~/.config/tmux ~/.tmux.conf
    ```
    Para cada uno que no exista verás `No such file or directory`; lo que
    exista, apártalo. tmux 3.4 carga `~/.tmux.conf` **y**
    `~/.config/tmux/tmux.conf` si existen los dos:
    ```bash
    mv ~/.config/tmux ~/.config/tmux.antes     # solo si existía
    mv ~/.tmux.conf ~/.tmux.conf.antes         # solo si existía
    mkdir -p ~/.config && ln -s "$PWD" ~/.config/tmux
    ls -l ~/.config/tmux
    ```
    Algo como `~/.config/tmux -> /home/tú/bc-tmux/.../3-proyecto/starter`.
    Un servidor que ya estaba arrancado no lee la config nueva hasta que
    ejecutes `tmux source-file ~/.config/tmux/tmux.conf` dentro de él (o
    lo cierres y vuelvas a abrir); `history-limit` solo afecta a los paneles
    nuevos.

12. **Autograding**, desde la raíz del repositorio:
    ```bash
    cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 04
    ```
    ```
    Semana 04 — Copy mode, buffers y portapapeles

      ✅ copy mode usa las teclas de vi
      ✅ history-limit es de al menos 10000 líneas
      ...
      ✅ Los scripts de bin/ no tienen TODOs y pasan shellcheck

    19/19 comprobaciones superadas.
    ```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 04` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] copy mode usa las teclas de vi
- [ ] history-limit es de al menos 10000 líneas
- [ ] set-clipboard está en on
- [ ] copy-command apunta a bin/kit-copiar del kit
- [ ] v selecciona, C-v hace rectángulo e y copia con copy-pipe
- [ ] Copiar con y en copy mode llega al portapapeles
- [ ] En Wayland copia con wl-copy
- [ ] En Wayland sin wl-copy sale con 1 y dice qué instalar
- [ ] En Wayland sin wl-copy el código de salida es 1
- [ ] En X11 copia con xclip en CLIPBOARD, no en PRIMARY
- [ ] En X11 sin xclip usa xsel
- [ ] En macOS copia con pbcopy
- [ ] En WSL copia con clip.exe
- [ ] En WSL prefiere win32yank.exe, que respeta la ñ
- [ ] Por SSH usa OSC 52 aunque haya herramientas locales
- [ ] Sin entorno gráfico usa OSC 52
- [ ] Dentro de tmux, OSC 52 pasa por load-buffer -w
- [ ] Con argumentos, kit-copiar sale con 2
- [ ] Los scripts de bin/ no tienen TODOs y pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Comentarios del porqué en `tmux.conf` y `kit-copiar`: `-F` y `current_file`, `set-clipboard on`, SSH antes que todo, `load-buffer -w`, `-selection clipboard`, la ñ de `clip.exe`.
- Mensajes de error por stderr que dicen qué instalar, con los códigos 1 y 2 documentados en la cabecera.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- Ninguna ruta absoluta a tu home en `tmux.conf`: el kit funciona dondequiera que lo enlaces.
- README con `kit-copiar`, la instalación y la bitácora.

## Entrega

Commit con el mensaje:
```
feat(week-04): tmux.conf y kit-copiar para copiar en local y por SSH
```
