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

`tmux set -g @kit-nav off` hace que `C-h/j/k/l` lleguen siempre al programa;
`on` lo devuelve.

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
