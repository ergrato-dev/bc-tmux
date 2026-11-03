# tmux-kit

Mi kit personal de tmux: configuración y scripts que uso a diario en Ubuntu 24.04 (WSL2). Crece una semana a la vez durante el bootcamp.

## Requisitos

- tmux 3.4 o superior. Compruébalo con:

  ```bash
  bin/check-version          # tmux 3.4 >= 3.4: ok
  ```

## Scripts

| Script | Qué hace | Ejemplo |
|---|---|---|
| `bin/check-version` | Comprueba que tmux cumple la versión mínima. Sale con 0 (cumple), 1 (vieja) o 2 (no está) | `bin/check-version 3.5` |
| `bin/kit-tree` | Dibuja servidor > sesiones > ventanas > paneles. Nunca arranca un servidor | `TMUX_SOCKET=lab bin/kit-tree` |
| `bin/kit-layout` | Crea la ventana `trabajo` (editor a la izquierda, shell y logs a la derecha) y guarda o carga layouts | `bin/kit-layout new api ~/src/api` |
| `bin/kit-sessions` | Lista las sesiones (la más reciente primero, `*` en la actual) y salta entre ellas, dentro o fuera de tmux | `bin/kit-sessions jump api` |
| `bin/kit-option` | Dice qué valor tiene una opción y de qué nivel sale: panel, ventana, sesión, global o servidor | `bin/kit-option remain-on-exit api:1.2` |
| `bin/kit-keys` | Lista las teclas del kit (las que tienen nota `kit:`) como `TABLA TECLA  NOTA`. Sale con 1 si no hay servidor o la tabla no existe, 2 con uso incorrecto | `bin/kit-keys kit-resize` |
| `bin/kit-git-branch` | Imprime la rama git de un directorio (o el commit corto con HEAD suelto); nada si no es un repo. Lo usa la status line. Sale con 2 con uso incorrecto | `bin/kit-git-branch ~/src/api` |
| `bin/kit-doctor` | Diagnostica tmux y tu terminal sin cambiar nada: una línea `ok`, `aviso` o `fallo` por tema. Sale con 1 si hay algún fallo, 2 con uso incorrecto | `TMUX_SOCKET=kit bin/kit-doctor` |
| `bin/dev-up` | Crea o reutiliza la sesión de un proyecto con las ventanas `editor`, `run` y `logs` en su directorio, y se conecta (`-d`: no). Sale con 1 si el directorio no existe, 2 con uso incorrecto | `bin/dev-up ~/src/api` |
| `bin/dev-down` | Cierra la sesión de un proyecto, y solo esa (`api` nunca cierra `api-2`). Sale con 1 si no existe, 2 con uso incorrecto | `bin/dev-down api` |
| `bin/kit-projects` | Lista los proyectos (subdirectorios de `@kit-projects-dir`) y abre el que elijas con fzf, o de una lista numerada, mediante `dev-up` (`-l`: solo lista). Sale con 1 si no existe el directorio o el proyecto, 2 con uso incorrecto | `bin/kit-projects -l` |
| `bin/kit-plugins` | `list`: los plugins de `@tpm_plugins`, su tag y si están instalados. `check`: sale con 1 si alguno no está fijado a un tag. `install`: clona TPM con su tag e instala los plugins (necesita red). Sale con 1 sin servidor, 2 con uso incorrecto | `bin/kit-plugins list` |
| `bin/kit-log` | Activa o para el log de un panel (`pipe-pane`) en `~/.local/state/tmux-kit/logs/`. Sale con 1 si el panel no existe, 2 con uso incorrecto | `bin/kit-log %3` |
| `bin/kit-copy` | Copia stdin a tu portapapeles: herramienta del sistema en local, OSC 52 por SSH. Sale con 1 si falta la herramienta, 2 si recibe argumentos | `printf año \| bin/kit-copy` |

Todos respetan `TMUX_BIN` (qué binario de tmux usar), y los que hablan con un
servidor respetan `TMUX_SOCKET` (qué servidor, como `tmux -L`).

Para guardar un layout que te guste y recuperarlo después:

```bash
bin/kit-layout save api:trabajo ~/.config/tmux/layouts/api.layout
bin/kit-layout load api:trabajo ~/.config/tmux/layouts/api.layout
```

## Instalación

`tmux.conf` busca `conf.d/` y `bin/` a su lado, así que se enlaza el
directorio entero:

```bash
ln -s ~/tmux-kit ~/.config/tmux
```

Para probar un cambio sin tocar tu servidor de siempre, con ruta absoluta:

```bash
tmux -L kit -f "$PWD/tmux.conf"
```

## Estructura

| Archivo | Qué contiene |
|---|---|
| `tmux.conf` | Solo el punto de entrada: guarda `@kit-dir` y carga `conf.d/*.conf` y `local.conf` |
| `conf.d/10-options.conf` | Opciones, agrupadas por alcance: servidor, sesión, ventana |
| `conf.d/20-bindings.conf` | Prefix, recarga, splits, modo resize, navegación y copy mode |
| `conf.d/30-status.conf` | Paleta `@kit-color-*` y status line: sesión, ventanas, rama, host y hora |
| `conf.d/40-terminal.conf` | `TERM` de dentro, features de la terminal de fuera, teclas extendidas, foco y passthrough |
| `conf.d/50-hooks-popups.conf` | Hooks (mensaje al conectarse, autolog), popup de proyectos y menú del kit |
| `conf.d/60-plugins.conf` | Carga el plugin del kit, declara los plugins de terceros (fijados por tag), opciones de resurrect y continuum y TPM si está instalado |
| `plugin/tmux-kit.tmux` | Plugin del kit: cambia los marcadores `#{kit_sessions}` y `#{kit_git}` de la status line |
| `plugins/` | Fuera de git: los plugins que clona TPM |
| `docs/diagnostico.md` | Guía síntoma → causa → comando para la terminal |
| `local.conf` | Opcional, fuera de git: lo propio de cada máquina |

Los módulos cargan por orden de nombre: siempre dos cifras delante.

## Prefix

`C-a`: se pulsa sin mover la mano (con Caps Lock como Ctrl) y es el de
screen. En bash, "inicio de línea" pasa a ser `C-a` `C-a`. `prefix` `r`
recarga la config.

## Teclas

Todas las teclas del kit llevan una nota que empieza por `kit:`: `prefix` `?`
las muestra junto a las de tmux (`q` sale) y `bin/kit-keys` lista solo las
del kit.

| Teclas | Qué hacen |
|---|---|
| `prefix` `\|` / `prefix` `-` | Dividen a la derecha / debajo, en el directorio del panel actual |
| `prefix` `R` | Modo resize: `h` `j` `k` `l` mueven el borde 5 celdas, `H` `J` `K` `L` 1; `q`, `Escape` o `Enter` salen |
| `C-h` `C-j` `C-k` `C-l` | Cambian de panel sin prefix. Con un programa a pantalla completa (`less`, `watch`, un editor) la tecla le llega a él |
| `prefix` `C-l` | Limpia la pantalla de la shell (`C-l` ya cambia de panel) |
| `prefix` `P` | Popup con tus proyectos: eliges uno y `dev-up` te lleva a su sesión |
| `prefix` `K` | Menú del kit: abrir proyecto, cerrar la sesión (con confirmación), log del panel, `@kit-nav`, rama git y `kit-doctor` |

`tmux set -g @kit-nav off` hace que `C-h/j/k/l` lleguen siempre al programa;
`on` lo devuelve.

## Status line

Formats de tmux en `conf.d/30-status.conf`, más dos marcadores que rellena el
plugin del kit (`plugin/tmux-kit.tmux`).

| Zona | Qué muestra |
|---|---|
| Izquierda | La sesión; cambia de color con el prefix pulsado y añade `RESIZE` en el modo resize |
| Centro | Las ventanas como `índice:nombre`, con `ZOOM`, `SYNC` y `LOG` cuando toca; la actual, resaltada |
| Derecha | `NAV off` si `@kit-nav` está apagado, la rama git del panel (`#{kit_git}`), cuántas sesiones hay (`#{kit_sessions}`), el host y la hora |

Los colores son opciones `@kit-color-bg`, `-fg`, `-accent`, `-alert` y
`-warn`: cámbialos en `30-status.conf` o en caliente
(`tmux set -g @kit-color-accent colour39`). `tmux set -g @kit-status-git off`
deja de ejecutar `kit-git-branch` (repos enormes, discos de red).
`tmux set -g @kit-sessions-label sesiones` cambia el texto tras el número.

## Terminal

`conf.d/40-terminal.conf` fija `default-terminal tmux-256color` y le dice a
tmux que las terminales `xterm*` tienen color de 24 bits (`RGB`), undercurl
(`usstyle`) y teclas extendidas (`extkeys`). Si algo se ve o se comporta raro,
empieza por:

```bash
bin/kit-doctor
```

y sigue con [docs/diagnostico.md](docs/diagnostico.md). Con otra terminal
(alacritty, foot), añade su línea de `terminal-features` en `local.conf`.

## Proyectos

`bin/dev-up DIR` deja una sesión por proyecto, con el nombre del directorio
(`mi.app` pasa a `mi_app`: tmux no admite `.` ni `:` en nombres):

```bash
bin/dev-up ~/src/api          # la crea y se conecta; dentro de tmux, cambia a ella
bin/dev-up ~/src/api          # ya existe: solo se conecta (y recrea la ventana que cerraste)
bin/dev-up -d ~/src/web front # sin conectarse, con otro nombre
bin/dev-down front
```

Si el proyecto tiene un `.tmux-kit`, cada línea `ventana: comando` se escribe
en la shell de esa ventana **al crearla** (no al reutilizarla):

```
# .tmux-kit de ~/src/api
editor: less README.md
run: make dev
logs: tail -F log/dev.log
```

El archivo no se ejecuta con `source`: solo se leen esas líneas. Aun así,
lo que pongas ahí se ejecuta en tu shell; no uses `dev-up` con el
`.tmux-kit` de un repositorio que no hayas leído.

## Hooks, popups y menú

`conf.d/50-hooks-popups.conf`, sin plugins:

- Al conectarte, un mensaje con la sesión y sus ventanas (hook `client-attached`).
- `prefix` `P`: popup con fzf sobre los subdirectorios de `@kit-projects-dir`
  (por defecto `~/src`; cámbialo en `local.conf`). Sin fzf, lista numerada.
- `prefix` `K`: menú del kit. Las entradas dicen el estado actual
  (`Parar log`, `Encender navegación`).
- Log de un panel: `bin/kit-log` o el menú; la barra marca la ventana con
  `LOG`. Con `tmux set -g @kit-autolog on`, cada ventana y panel nuevos
  empiezan con log. Los logs van a
  `${XDG_STATE_HOME:-~/.local/state}/tmux-kit/logs/SESION-VENTANA-PANEL.log`
  y guardan todo lo que sale en pantalla: bórralos de vez en cuando.

Los hooks usan un índice fijo (`client-attached[50]`): `prefix` `r` no los
duplica. Compruébalo con `tmux show-hooks -g | grep kit`.

## Plugins

El kit funciona sin instalar nada. Los plugins de terceros son opcionales:

```bash
bin/kit-plugins check      # kit-plugins: 3 plugins fijados
bin/kit-plugins install    # clona TPM v3.1.0, resurrect y continuum en plugins/
bin/kit-plugins list
```

| Plugin | Versión | Para qué |
|---|---|---|
| TPM | `v3.1.0` | Clona y carga los demás. `prefix` `I` instala, `prefix` `U` actualiza, `prefix` `M-u` borra los que ya no están en la lista |
| tmux-resurrect | `v4.0.0` | `prefix` `C-s` guarda sesiones, ventanas, paneles y su contenido; `prefix` `C-r` los restaura. En `~/.local/share/tmux/resurrect` |
| tmux-continuum | `v3.1.0` | Guarda cada 15 minutos y restaura al arrancar el servidor. Solo guarda si es el único servidor de tmux en marcha |

La lista va en `@tpm_plugins` (`conf.d/60-plugins.conf`), no en líneas
`set -g @plugin`: TPM 3.1.0 busca esas líneas leyendo `tmux.conf` y no sigue
el `source-file -F` con glob del kit. Para añadir uno, escríbelo ahí como
`usuario/repo#tag` y ejecuta `bin/kit-plugins install`. Las rutas del kit no
pueden llevar espacios: TPM no las cita.

## Copiar

En copy mode (`mode-keys vi`), `v` selecciona, `C-v` hace un rectángulo e `y`
copia al portapapeles con `bin/kit-copy` (también al soltar el ratón). En
WSL, instala `win32yank.exe` para que la ñ llegue bien; por SSH, tu terminal
tiene que soportar OSC 52.

## Bitácora

| Semana | Qué añadí |
|---|---|
| 01 | Repositorio, `bin/check-version` y `bin/kit-tree` |
| 02 | `bin/kit-layout`: ventana de trabajo de tres paneles y layouts guardados |
| 03 | `bin/kit-sessions`: listar, saltar, crear y agrupar sesiones |
| 04 | Primer `tmux.conf` (copy mode vi, historial, OSC 52) y `bin/kit-copy` |
| 05 | Config modular en `conf.d/`, prefix `C-a`, recarga idempotente y `bin/kit-option` |
| 06 | Notas `kit:` en todas las teclas, splits en el mismo directorio, modo resize, navegación `C-h/j/k/l` y `bin/kit-keys` |
| 07 | Status line propia en `conf.d/30-status.conf` con paleta en opciones `@kit-color-*` y `bin/kit-git-branch` |
| 08 | `conf.d/40-terminal.conf` (tmux-256color, RGB, undercurl, teclas extendidas, passthrough), `bin/kit-doctor` y `docs/diagnostico.md` |
| 09 | `bin/dev-up` (sesión por proyecto, idempotente, con `.tmux-kit`) y `bin/dev-down` |
| 10 | `conf.d/50-hooks-popups.conf` (hooks sin duplicar, popup `prefix P`, menú `prefix K`, autolog), `bin/kit-projects`, `bin/kit-log` e indicador `LOG` |
| 11 | Plugin propio `plugin/tmux-kit.tmux` (marcadores `#{kit_sessions}` y `#{kit_git}`), `conf.d/60-plugins.conf` con TPM, resurrect y continuum fijados por tag y `bin/kit-plugins` |
