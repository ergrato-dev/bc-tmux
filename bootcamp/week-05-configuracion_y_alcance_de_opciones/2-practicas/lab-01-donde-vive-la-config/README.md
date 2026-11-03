# Lab 01 — Dónde vive la config

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar qué archivos de config carga tmux, en qué orden y cuándo, encontrar los errores de una config sin conectarte, e instalar la tuya en `~/.config/tmux` con un script que no pisa nada.

## Contexto

- Al arrancar el servidor, tmux carga **todos** los que existan de `/etc/tmux.conf`, `~/.tmux.conf`, `$XDG_CONFIG_HOME/tmux/tmux.conf` y `~/.config/tmux/tmux.conf`, en ese orden.
- La config se lee al **arrancar el servidor**, no al conectar un cliente.
- Para no tocar tu `$HOME` real, este lab usa un `HOME` falso en un directorio temporal y `env -i`, que arranca tmux con un entorno vacío (sin tu `XDG_CONFIG_HOME`).

## Instrucciones

0. **Dónde.** Una terminal **fuera de tmux** (`echo "$TMUX"` no imprime
   nada). Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-01-donde-vive-la-config
   ```
   Todo el lab va en **esta misma terminal**, contra el servidor `-L lab`.

1. **Las dos configs.** Prepara un `HOME` falso con una config vieja y una
   nueva, y una función `t` que arranca tmux con ese `HOME`:
   ```bash
   export H=$(mktemp -d)
   mkdir -p "$H/.config/tmux"
   echo 'set -g @origin legado; set -g @legacy-only si' > "$H/.tmux.conf"
   echo 'set -g @origin xdg' > "$H/.config/tmux/tmux.conf"
   t() { env -i PATH="$PATH" HOME="$H" TERM="$TERM" tmux -L lab "$@"; }
   t new -d \; display -p '#{config_files}' \; show -gv @origin \; show -gv @legacy-only
   ```
   Algo como (cambia el nombre del directorio temporal):
   ```
   /tmp/tmp.YjbkDVD4sV/.tmux.conf,/tmp/tmp.YjbkDVD4sV/.config/tmux/tmux.conf
   xdg
   si
   ```
   Cargó las dos: la de `~/.config/tmux` va después y pisa `@origin`, pero
   `@legacy-only` sigue viniendo del archivo viejo. Si migras a XDG, borra o
   renombra `~/.tmux.conf`.

   `H` y `t` solo existen en esta terminal. Si la cierras, apunta antes el
   directorio (`echo "$H"`) y, en la nueva, vuelve a definirlos con esa ruta:
   ```bash
   export H=/tmp/tmp.YjbkDVD4sV      # la que imprimió echo "$H"
   t() { env -i PATH="$PATH" HOME="$H" TERM="$TERM" tmux -L lab "$@"; }
   ```

2. **XDG_CONFIG_HOME y -f.** Cierra el servidor, añade una tercera ubicación
   y quita la config vieja:
   ```bash
   t kill-server
   mkdir -p "$H/otra/tmux"; echo 'set -g @origin otra' > "$H/otra/tmux/tmux.conf"
   rm "$H/.tmux.conf"
   env -i PATH="$PATH" HOME="$H" TERM="$TERM" XDG_CONFIG_HOME="$H/otra" tmux -L lab new -d \; display -p '#{config_files}' \; show -gv @origin
   t kill-server
   t -f /dev/null new -d \; display -p '[#{config_files}]'
   t kill-server
   ```
   Algo como:
   ```
   /tmp/tmp.YjbkDVD4sV/otra/tmux/tmux.conf,/tmp/tmp.YjbkDVD4sV/.config/tmux/tmux.conf
   xdg
   [/dev/null]
   ```
   `XDG_CONFIG_HOME` **añade** una ubicación antes de `~/.config/tmux`: si
   existen las dos, se cargan las dos, y gana la última (`xdg`). Con `-f`,
   en cambio, solo el archivo que indicas: `-f /dev/null` arranca sin config.

3. **Se lee al arrancar.** Con el servidor vivo, cambia la config y abre otra
   sesión:
   ```bash
   t new -d -s uno
   echo 'set -g @origin cambiada' > "$H/.config/tmux/tmux.conf"
   t new -d -s dos \; show -gv @origin
   t source-file "$H/.config/tmux/tmux.conf" \; show -gv @origin
   t kill-server
   ```
   ```
   xdg
   cambiada
   ```
   La sesión `dos` nace en un servidor que ya estaba arrancado: nadie volvió
   a leer el archivo hasta el `source-file`.

4. **Un error no detiene nada.** Escribe una config con dos errores (líneas 2
   y 3) y arranca con ella:
   ```bash
   printf 'set -g base-index 1\nset -g base-indx 2\nset -g mouse encendido\nset -g pane-base-index 1\n' > "$H/rota.conf"
   t -f "$H/rota.conf" new -d; echo $?
   t show -gv base-index \; show -gwv pane-base-index
   ```
   ```
   0
   1
   1
   ```
   Ni un aviso en la terminal, **sale con 0** y aplica las líneas buenas, la 4
   incluida. Los errores se guardan en el servidor y se entregan **una sola
   vez**: al primer cliente que se conecte (el panel los muestra en modo
   vista; se sale con `q`) o a la primera orden `source-file`. Pídelos sin
   conectarte, con un `source-file` que no carga nada:
   ```bash
   t source-file /dev/null; echo $?
   ```
   Algo como:
   ```
   /tmp/tmp.YjbkDVD4sV/rota.conf:2: invalid option: base-indx
   /tmp/tmp.YjbkDVD4sV/rota.conf:3: bad value: encendido
   0
   ```
   Si arrancas tmux desde un atajo de tu terminal o un script con `new -d`,
   nadie lee esos avisos y lo único que notas es que "algo no funciona".

5. **Encontrarlos desde fuera.** Sobre el servidor que ya tienes, las tres
   formas de `source-file`:
   ```bash
   t source-file "$H/rota.conf"; echo $?
   ```
   ```
   invalid option: base-indx
   bad value: encendido
   1
   ```
   Desde la línea de comandos, `source-file` imprime cada error (sin número
   de línea) y **sale con 1**: sirve en un script o en un check.
   ```bash
   t source-file -v "$H/rota.conf"; echo $?
   ```
   Algo como:
   ```
   invalid option: base-indx
   bad value: encendido
   /tmp/tmp.YjbkDVD4sV/rota.conf:1: set-option -g base-index 1
   /tmp/tmp.YjbkDVD4sV/rota.conf:2: set-option -g base-indx 2
   /tmp/tmp.YjbkDVD4sV/rota.conf:3: set-option -g mouse encendido
   /tmp/tmp.YjbkDVD4sV/rota.conf:4: set-option -g pane-base-index 1
   1
   ```
   `-v` añade cada comando con `archivo:línea`: así sabes qué línea es la
   del error.
   ```bash
   t source-file -n "$H/rota.conf"; echo $?
   printf 'if 1 {\nset -g @x 1\n' > "$H/llave.conf"
   t source-file -n "$H/llave.conf"; echo $?
   ```
   Algo como:
   ```
   0
   /tmp/tmp.YjbkDVD4sV/llave.conf:3: syntax error
   1
   ```
   `-n` solo comprueba la **sintaxis** (una llave sin cerrar) y no ejecuta
   nada: no detecta una opción mal escrita. El método para cualquier config:
   servidor aparte, `-f /dev/null` y `source-file`. Cierra el servidor:
   ```bash
   t kill-server
   ```
   ```
   (sin salida)
   ```

6. **Instalar sin pisar nada.** `starter/install.sh DIR` enlaza `DIR` como
   `~/.config/tmux` (respetando `XDG_CONFIG_HOME`). Ábrelo con tu editor:
   arriba ya calcula `destino`; al final hay un `echo "sin implementar"` y
   un `exit 1` que **borras** al terminar el TODO 4. Para probarlo, siempre
   con el `HOME` falso y sin tu `XDG_CONFIG_HOME`:
   ```bash
   env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh starter/my-config; echo $?
   ```
   Algo como, mientras no hayas hecho nada:
   ```
   install.sh: sin implementar (starter/my-config -> /tmp/tmp.YjbkDVD4sV/.config/tmux)
   1
   ```
   Antes de empezar, si no lo tienes: `sudo apt install shellcheck` (macOS:
   `brew install shellcheck`). El laboratorio Docker ya lo trae.

   1. **TODO 1: el directorio.** Si `"$1/tmux.conf"` no existe
      (`[[ ! -f ... ]]`), imprime por stderr `install.sh: DIR no tiene
      tmux.conf` y `exit 2`. Después guarda la ruta absoluta:
      `dir=$(cd "$1" && pwd)`. Un enlace guarda la ruta tal cual: relativa,
      se resolvería desde `~/.config/`, no desde aquí.
      ```bash
      env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh /tmp; echo $?
      ```
      ```
      install.sh: /tmp no tiene tmux.conf
      2
      ```
   2. **TODO 2: el destino ya existe.** Si `$destino` es un enlace
      (`-L`) y `"$(readlink "$destino")"` es igual a `$dir`, imprime
      `ya instalado: DESTINO -> DIR` y **no salgas**: el aviso del TODO 4
      tiene que verse también. Si existe y es otra cosa
      (`[[ -e "$destino" || -L "$destino" ]]`), imprime por stderr
      `install.sh: ya existe DESTINO: muévelo tú antes` y `exit 1`, sin
      tocarlo. Una estructura `if ... elif ... else` encaja: el `else` es el
      TODO 3. Pruébalo ahora, que `$H/.config/tmux` sigue siendo el
      **directorio** del paso 1:
      ```bash
      env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh starter/my-config; echo $?
      ```
      Algo como:
      ```
      install.sh: ya existe /tmp/tmp.YjbkDVD4sV/.config/tmux: muévelo tú antes
      1
      ```
   3. **TODO 3: enlazar.** En el `else`: `mkdir -p "$(dirname "$destino")"`,
      `ln -s "$dir" "$destino"` e imprime `instalado: DESTINO -> DIR`. Para
      probarlo, primero quita el directorio del paso 1 (es del `HOME` falso):
      ```bash
      rm -r "$H/.config/tmux"
      env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh starter/my-config; echo $?
      env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh starter/my-config; echo $?
      ```
      Algo como (la segunda ruta es la de tu repositorio):
      ```
      instalado: /tmp/tmp.YjbkDVD4sV/.config/tmux -> /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-01-donde-vive-la-config/starter/my-config
      0
      ya instalado: /tmp/tmp.YjbkDVD4sV/.config/tmux -> /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-01-donde-vive-la-config/starter/my-config
      0
      ```
      La segunda vez no hace nada: es **idempotente**.
   4. **TODO 4: el aviso.** Fuera del `if`, al final: si existe
      `"$HOME/.tmux.conf"`, imprime por stderr `aviso: HOME/.tmux.conf
      también se carga, antes que la tuya`. Borra el `echo "sin
      implementar"` y el `exit 1`.
      ```bash
      touch "$H/.tmux.conf"
      env -u XDG_CONFIG_HOME HOME="$H" ./starter/install.sh starter/my-config; echo $?
      ```
      Algo como:
      ```
      ya instalado: /tmp/tmp.YjbkDVD4sV/.config/tmux -> /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-01-donde-vive-la-config/starter/my-config
      aviso: /tmp/tmp.YjbkDVD4sV/.tmux.conf también se carga, antes que la tuya
      0
      ```
   5. **tmux la usa y el script está limpio.**
      ```bash
      t new -d \; show -gv @origin
      t kill-server
      shellcheck starter/install.sh; echo $?
      ```
      ```
      my-config
      0
      ```

7. **Limpia.** Borra el `HOME` falso (nada de tu `$HOME` real se tocó):
   ```bash
   rm -rf "$H"; unset H
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `@legacy-only` seguía activo en el paso 1
- [ ] Explicas por qué el paso 3 necesita `source-file` para ver el cambio
- [ ] En el paso 4 recuperas los dos errores de `rota.conf` con su número de línea y explicas por qué `new -d` sale con 0
- [ ] `install.sh /tmp` sale con 2 (paso 6.1) y, si `~/.config/tmux` ya es un directorio, sale con 1 sin tocarlo (paso 6.2)
- [ ] `install.sh` crea el enlace y la segunda vez dice `ya instalado` (paso 6.3)
- [ ] Con un `~/.tmux.conf` presente, avisa por stderr (paso 6.4)
- [ ] `shellcheck starter/install.sh` sale con 0 sin avisos (paso 6.5)

## Reto extra

Añade `--forzar` a `install.sh`: si el destino existe, lo renombra a
`tmux.bak-FECHA` antes de enlazar. ¿Por qué renombrar y no borrar?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Un prefix propio](../lab-02-prefix-propio/README.md) → |

[↑ Semana 05](../../README.md)
