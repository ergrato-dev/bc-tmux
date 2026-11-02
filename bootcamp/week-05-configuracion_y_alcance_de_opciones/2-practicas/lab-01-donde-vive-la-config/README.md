# Lab 01 — Dónde vive la config

⏱ Duración estimada: ~60 min

## Objetivo

Comprobar qué archivos de config carga tmux, en qué orden y cuándo, encontrar los errores de una config sin conectarte, e instalar la tuya en `~/.config/tmux` con un script que no pisa nada.

## Contexto

- Al arrancar el servidor, tmux carga **todos** los que existan de `/etc/tmux.conf`, `~/.tmux.conf`, `$XDG_CONFIG_HOME/tmux/tmux.conf` y `~/.config/tmux/tmux.conf`, en ese orden.
- La config se lee al **arrancar el servidor**, no al conectar un cliente.
- Para no tocar tu `$HOME` real, este lab usa un `HOME` falso en un directorio temporal y `env -i`, que arranca tmux con un entorno vacío.

## Instrucciones

1. **Las dos configs.** Prepara un `HOME` falso con una config vieja y una nueva:
   ```bash
   export H=$(mktemp -d)
   mkdir -p "$H/.config/tmux"
   echo 'set -g @origen legado; set -g @solo-legado si' > "$H/.tmux.conf"
   echo 'set -g @origen xdg' > "$H/.config/tmux/tmux.conf"
   t() { env -i PATH="$PATH" HOME="$H" TERM="$TERM" tmux -L lab "$@"; }
   t new -d \; display -p '#{config_files}' \; show -gv @origen \; show -gv @solo-legado
   ```
   ```
   /tmp/tmp.XXXX/.tmux.conf,/tmp/tmp.XXXX/.config/tmux/tmux.conf
   xdg
   si
   ```
   Cargó las dos: la de `~/.config/tmux` va después y pisa `@origen`, pero
   `@solo-legado` sigue viniendo del archivo viejo. Si migras a XDG, borra o
   renombra `~/.tmux.conf`.

2. **XDG_CONFIG_HOME y -f.** Repite con otra ubicación y con `-f`:
   ```bash
   t kill-server
   mkdir -p "$H/otra/tmux"; echo 'set -g @origen otra' > "$H/otra/tmux/tmux.conf"
   rm "$H/.tmux.conf"
   env -i PATH="$PATH" HOME="$H" XDG_CONFIG_HOME="$H/otra" tmux -L lab new -d \; display -p '#{config_files}'
   t kill-server
   t -f /dev/null new -d \; display -p '[#{config_files}]'
   t kill-server
   ```
   ```
   /tmp/tmp.XXXX/otra/tmux/tmux.conf,/tmp/tmp.XXXX/.config/tmux/tmux.conf
   [/dev/null]
   ```
   `XDG_CONFIG_HOME` **añade** una ubicación antes de `~/.config/tmux`: si
   existen las dos, se cargan las dos. Con `-f`, en cambio, solo el archivo
   que indicas: `-f /dev/null` arranca sin config.

3. **Se lee al arrancar.** Con el servidor vivo, cambia la config y abre otra
   sesión:
   ```bash
   t new -d -s uno
   echo 'set -g @origen cambiada' > "$H/.config/tmux/tmux.conf"
   t new -d -s dos \; show -gv @origen      # xdg: nadie volvió a leer el archivo
   t source-file "$H/.config/tmux/tmux.conf" \; show -gv @origen   # cambiada
   t kill-server
   ```

4. **Un error no detiene nada.** Escribe una config con dos errores:
   ```bash
   printf 'set -g base-index 1\nset -g base-indx 2\nset -g mouse encendido\nset -g pane-base-index 1\n' > "$H/rota.conf"
   t -f "$H/rota.conf" new -d; echo $?
   t show -gv base-index \; show -gwv pane-base-index
   ```
   ```
   /tmp/tmp.XXXX/rota.conf:2: invalid option: base-indx
   /tmp/tmp.XXXX/rota.conf:3: bad value: encendido
   0
   1
   1
   ```
   Avisa por stderr, pero **sale con 0** y aplica las líneas buenas, la 4
   incluida. Si arrancas tmux desde un atajo de tu terminal o un script, ese
   aviso no lo lee nadie, y lo único que notas es que "algo no funciona".

5. **Encontrarlos desde fuera.** Sobre el servidor que ya tienes:
   ```bash
   t source-file "$H/rota.conf"; echo $?
   t source-file -v "$H/rota.conf"
   t source-file -n "$H/rota.conf"; echo $?
   ```
   `source-file` imprime cada error y **sale con 1**: sirve en un script o en
   un check. `-v` muestra además cada comando con `archivo:línea`. `-n` solo
   comprueba la **sintaxis** (comillas, llaves) y sale con 0: no detecta una
   opción mal escrita.
   Este es el método para cualquier config: servidor aparte, `-f /dev/null`
   y `source-file`. Limpia: `t kill-server`.

6. **Instalar sin pisar nada.** Completa `starter/instalar.sh`: enlaza un
   directorio como `~/.config/tmux` (respetando `XDG_CONFIG_HOME`), no toca un
   destino que ya existe y avisa si hay un `~/.tmux.conf`.
   ```bash
   HOME="$H" ./starter/instalar.sh starter/mi-config
   HOME="$H" ./starter/instalar.sh starter/mi-config     # segunda vez
   touch "$H/.tmux.conf"; HOME="$H" ./starter/instalar.sh starter/mi-config
   ```
   ```
   instalado: /tmp/tmp.XXXX/.config/tmux -> /ruta/a/starter/mi-config
   ya instalado: /tmp/tmp.XXXX/.config/tmux -> /ruta/a/starter/mi-config
   ya instalado: /tmp/tmp.XXXX/.config/tmux -> /ruta/a/starter/mi-config
   aviso: /tmp/tmp.XXXX/.tmux.conf también se carga, antes que la tuya
   ```
   (Antes de este paso, borra el `.config/tmux` del paso 1:
   `rm -r "$H/.config/tmux"`.) Comprueba que tmux la usa:
   `t new -d \; show -gv @origen` imprime `mi-config`.

7. Limpia: `t kill-server; rm -rf "$H"; unset H`.

## Criterios de éxito

- [ ] Explicas por qué `@solo-legado` seguía activo en el paso 1
- [ ] Explicas por qué el paso 3 necesita `source-file` para ver el cambio
- [ ] Encuentras los dos errores de `rota.conf` con su número de línea y explicas por qué `new -d` sale con 0
- [ ] `instalar.sh` crea el enlace, es idempotente y sale con 1 si `~/.config/tmux` ya es un directorio
- [ ] `instalar.sh /tmp` sale con 2: no hay `tmux.conf`
- [ ] `shellcheck starter/instalar.sh` no muestra avisos

## Reto extra

Añade `--forzar` a `instalar.sh`: si el destino existe, lo renombra a
`tmux.bak-FECHA` antes de enlazar. ¿Por qué renombrar y no borrar?
