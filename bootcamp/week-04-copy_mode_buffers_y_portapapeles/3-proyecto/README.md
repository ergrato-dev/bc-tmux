# Proyecto Semana 04 — tmux-kit: copiar en local y por SSH

⏱ Duración estimada: ~3 h

## Contexto

Trabajas en tu portátil con WSL y, dos veces al día, por SSH en un servidor de staging. En local copias un comando de un log con el ratón y pegas en Slack: llega `aÃ±o` en lugar de `año`. En staging copias con `y` en copy mode y no pega nada, porque `xclip` copió en un portapapeles del servidor que nadie ve. Cada sitio necesita un camino distinto, y tu config debería elegirlo sola.

Añades a tu `tmux-kit` su **primer `tmux.conf`** (copy mode con teclas de vim, historial amplio, OSC 52) y el script **`bin/kit-copiar`**: recibe texto por stdin y lo deja en **tu** portapapeles, estés donde estés.

```bash
$ printf 'año' | kit-copiar                  # WSL: win32yank.exe; macOS: pbcopy; ...
$ ssh staging
staging$ printf 'año' | kit-copiar           # por SSH: OSC 52 hasta tu terminal
```

## Estructura del proyecto

```
starter/                 ← tu tmux-kit de la semana 03 + lo nuevo
├── README.md            ← añade kit-copiar, cómo instalar tmux.conf y la bitácora
├── tmux.conf            ← TODOs (nuevo)
└── bin/
    ├── check-version    (semana 01)
    ├── kit-tree         (semana 01)
    ├── kit-layout       (semana 02)
    ├── sesiones         (semana 03)
    └── kit-copiar       ← TODOs (nuevo)
tests/                   ← herramientas falsas para el autograding (no se tocan)
├── path-falso
└── falso-clip
```

El kit se instala enlazando el directorio entero, para que `tmux.conf`
encuentre `bin/` a su lado:

```bash
ln -s ~/tmux-kit ~/.config/tmux
```

## Lo que debes construir

### `tmux.conf`

1. Copy mode con teclas de vi fijadas (`setw -g mode-keys vi`), `history-limit` de al menos 10000, `set-clipboard on` y `copy-command` apuntando a `bin/kit-copiar` del propio kit con `set -sF ... "#{d:current_file}/bin/kit-copiar"`. En la tabla `copy-mode-vi`: `v` empieza la selección, `C-v` la vuelve rectangular e `y` copia con `copy-pipe-and-cancel` **sin comando**. Resultado: copiar con `y` en copy mode llega a tu portapapeles.

### `bin/kit-copiar`

2. **OSC 52** cuando estás por SSH (`SSH_CONNECTION` o `SSH_TTY`) o no hay portapapeles gráfico. Dentro de tmux (`$TMUX` no vacío), con `tmx load-buffer -w -`; fuera, escribiendo `\033]52;c;BASE64\a` en una sola línea a `"${KIT_TTY:-/dev/tty}"` (`KIT_TTY` existe para que el autograding lea la secuencia).
3. En local, la herramienta de cada plataforma, en este orden: macOS (`uname` = `Darwin`) `pbcopy`; WSL (`WSL_DISTRO_NAME`) `win32yank.exe -i` o `clip.exe`; Wayland (`WAYLAND_DISPLAY`) `wl-copy`; X11 (`DISPLAY`) `xclip -selection clipboard` o `xsel --clipboard --input`. SSH va antes que todo: por SSH, una herramienta local copiaría en la máquina remota.
4. Si la plataforma se detecta pero falta su herramienta, sale con **1** y dice por stderr qué instalar (`instala wl-clipboard (sudo apt install wl-clipboard)`).
5. Con argumentos, muestra el uso y sale con **2** (ya viene hecho en el starter).

### Kit

6. Añade `kit-copiar` a la tabla del `README.md` con un ejemplo, documenta la instalación con `ln -s` y escribe la bitácora de la semana.

## Verificación

```bash
cd starter
F=../tests/path-falso
f=$($F wl-copy); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=w bin/kit-copiar; cat "$f/wl-copy.datos"   # hola
f=$($F); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=w bin/kit-copiar; echo $?   # instala wl-clipboard..., 1
printf hola | env -i PATH="$PATH" SSH_CONNECTION=x KIT_TTY=/tmp/osc bin/kit-copiar; cat -v /tmp/osc   # ^[]52;c;aG9sYQ==^G
tmux -L kit -f "$PWD/tmux.conf" new -d \; show -sv copy-command   # ruta absoluta a bin/kit-copiar
tmux -L kit kill-server; cd ..

./scripts/verificar-semana.sh 04              # desde la raíz del repositorio
```

En tu máquina, la prueba que cuenta: `tmux -L kit -f "$PWD/starter/tmux.conf"`
(ruta absoluta: `copy-command` se ejecuta desde tu `$HOME`),
copia con `v` ... `y` y pega con `Ctrl+V` fuera de tmux. Si tienes acceso a
un servidor por SSH, copia el kit allí y repite: debe pegar en tu portátil.

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
