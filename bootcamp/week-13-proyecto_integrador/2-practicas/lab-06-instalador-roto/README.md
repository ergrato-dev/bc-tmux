# Lab 06 — Instalador roto

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los cinco fallos del `install.sh` de un compañero, que "en su máquina funciona", hasta que instale bien desde cualquier directorio, en cualquier HOME y más de una vez.

## Contexto

- `starter/install.sh` está roto a propósito. `shellcheck` no protesta y, lanzado como lo lanza su autor (desde `starter/`, en su HOME), parece funcionar: los fallos son de diseño.
- Cada paso da un síntoma, cómo observarlo y una pista. Arregla solo ese fallo, comprueba y sigue: algunos fallos tapan a otros.
- Repasa los labs 01 a 03: `ln -sfn`, la ruta física del kit, el backup y `XDG_CONFIG_HOME`.

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` vacío). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto
   I="$PWD/starter/install.sh"; K="$PWD/starter"
   new() { H=$(mktemp -d); }
   inst() { env -u XDG_CONFIG_HOME HOME="$H" "$I" "$@"; }
   new
   ```
   (sin salida)

   `new` crea un HOME de pruebas vacío en `H`; cada fallo empieza con uno
   nuevo. `inst` lanza el instalador con ese HOME. Los `/tmp/tmp.XXXX` de
   las salidas cambian en cada `new`.

1. **Fallo 1 — solo funciona desde su carpeta.** Lánzalo desde la
   carpeta del lab:
   ```bash
   inst; echo $?
   ```
   ```
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter/install.sh: line 10: cd: bin: No such file or directory
   1
   ```
   Su autor lo lanza así, y mira el resultado:
   ```bash
   (cd starter && inst); echo $?
   readlink "$H/.config/tmux"
   ls "$H/.config/tmux/"; echo $?
   env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab new -d -s lab
   tmux -L lab show -gv prefix
   tmux -L lab kill-server
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.ZIzslDl8vM/.config/tmux -> /home/ergrato/tmux-kit
   0
   /home/ergrato/tmux-kit
   ls: cannot access '/tmp/tmp.ZIzslDl8vM/.config/tmux/': No such file or directory
   2
   C-b
   ```
   Desde `starter/` "funciona", pero el enlace apunta al HOME del autor
   (eso es el fallo 2: guárdalo para luego). Ahora el fallo 1: `cd bin` es
   relativo al directorio **desde el que lanzas** el script, no al del
   script. **Pista:** cambia las tres líneas `cd bin` /
   `./check-version 3.4` / `cd ..` por una sola que use `$kit`. Repite:
   ```bash
   new; inst; echo $?
   ```
   ```
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter/install.sh: line 10: /home/ergrato/tmux-kit/bin/check-version: No such file or directory
   127
   ```
   Ya no depende del cwd, pero ahora el fallo 2 lo para todo (127: comando
   no encontrado).

2. **Fallo 2 — la ruta de su HOME.** En el paso 1 lo viste: `kit` está
   escrito a mano con la ruta de la máquina del autor. En la tuya es un
   enlace colgante: tmux no encuentra la config, no da error y arranca con
   `C-b`. **Pista:** `kit` se calcula como en el lab 02, paso 1. Repite:
   ```bash
   new; inst; echo $?
   readlink "$H/.config/tmux"
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.onqVJdB4aa/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   ```

3. **Fallo 3 — la segunda vez ensucia el kit.** Instala dos veces y mira
   dentro del kit:
   ```bash
   new; inst > /dev/null
   inst; echo $?
   ls -l "$K" | grep -- '->'
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.qQPqFZBdrB/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   lrwxrwxrwx 1 alumno alumno   88 Nov  3 23:25 starter -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   ```
   Dice que instaló, sale con 0 y dejó un `starter -> starter` dentro del
   kit (el `ls` sin el fallo no imprimiría nada). Si el kit es un repo git,
   ese enlace acaba en el próximo commit. **Pista:** lab 01, paso 5, y
   lab 02, TODO 3: `ln -sfn` y, antes, "si ya apunta a `$kit`, di que ya
   está instalado y sal con 0". Borra el enlace sobrante y repite:
   ```bash
   rm "$K/starter"
   new; inst > /dev/null
   inst; echo $?
   ls "$K"
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: ya instalado en /tmp/tmp.YVFyE7OWrx/.config/tmux
   0
   bin
   conf.d
   install.sh
   tmux.conf
   ```

4. **Fallo 4 — se come tu config.** Alguien con config propia:
   ```bash
   new
   mkdir -p "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst; echo $?
   ls -A "$H/.config"
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.buNBZ3pjJe/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   tmux
   ```
   Ni rastro de la config: `rm -rf`, sin preguntar ni avisar. **Pista:**
   lab 02, TODO 4: si existe (`-e`) o es un enlace (`-L`), se mueve a
   `tmux.bak.<fecha>`. Repite:
   ```bash
   new
   mkdir -p "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst; echo $?
   ls -A "$H/.config"
   cat "$H"/.config/tmux.bak.*/tmux.conf
   inst; echo $?
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.hcGhOZdg0M/.config/tmux ya existe, lo muevo a /tmp/tmp.hcGhOZdg0M/.config/tmux.bak.20261103-232547
   install.sh: /tmp/tmp.hcGhOZdg0M/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   tmux
   tmux.bak.20261103-232547
   set -g status-style bg=red
   tmux 3.4 >= 3.4: ok
   install.sh: ya instalado en /tmp/tmp.hcGhOZdg0M/.config/tmux
   0
   ```
   La comprobación del fallo 3 va **antes** del backup: si no, la segunda
   ejecución movería a un backup el propio enlace del kit.

5. **Fallo 5 — ignora `XDG_CONFIG_HOME`.** Alguien con su config en un
   `XDG_CONFIG_HOME` propio:
   ```bash
   new
   mkdir -p "$H/xdg/tmux"
   echo 'set -g status-style bg=red' > "$H/xdg/tmux/tmux.conf"
   env HOME="$H" XDG_CONFIG_HOME="$H/xdg" "$I"; echo $?
   env HOME="$H" XDG_CONFIG_HOME="$H/xdg" tmux -L lab new -d -s lab
   tmux -L lab display -p '#{config_files}'
   tmux -L lab show -gv status-style
   tmux -L lab kill-server
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.K2JMQgclKY/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   /tmp/tmp.K2JMQgclKY/xdg/tmux/tmux.conf,/bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter/tmux.conf
   bg=red
   ```
   tmux carga las dos (lab 01, paso 8): la vieja sigue mandando en todo lo
   que el kit no toca y no hay backup de nada. **Pista:** `target` con
   `${XDG_CONFIG_HOME:-$HOME/.config}`. Repite el bloque entero:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.qTQ7NupsdC/xdg/tmux ya existe, lo muevo a /tmp/tmp.qTQ7NupsdC/xdg/tmux.bak.20261103-232530
   install.sh: /tmp/tmp.qTQ7NupsdC/xdg/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter/tmux.conf
   bg=green,fg=black
   ```
   Un solo archivo cargado y la barra de fábrica (`bg=green,fg=black`).

6. **Prueba final.** Desde la raíz del sistema, en un HOME nuevo, y
   `shellcheck`:
   ```bash
   new; (cd / && inst); echo $?
   shellcheck starter/install.sh; echo $?
   ls "$K"
   ```
   Algo como:
   ```
   tmux 3.4 >= 3.4: ok
   install.sh: /tmp/tmp.nPBKsQLkmD/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-06-instalador-roto/starter
   0
   0
   bin
   conf.d
   install.sh
   tmux.conf
   ```
   Sal del laboratorio con `exit`: los HOME de pruebas viven en `/tmp` del
   contenedor y desaparecen con él.

## Criterios de éxito

- [ ] Lanzado desde la carpeta del lab y desde `/`, sale con 0 (pasos 1 y 6)
- [ ] `readlink` del enlace imprime la ruta de `starter` en el contenedor, no `/home/ergrato/...` (paso 2)
- [ ] La segunda ejecución imprime `ya instalado` y `ls "$K"` no muestra ningún `starter` (paso 3)
- [ ] La config previa aparece intacta en `tmux.bak.<fecha>` (paso 4)
- [ ] Con `XDG_CONFIG_HOME`, `#{config_files}` lista un solo archivo y `status-style` es `bg=green,fg=black` (paso 5)
- [ ] `shellcheck starter/install.sh` sale con 0 (paso 6)

## Reto extra

Añade `--dry-run` y `--uninstall` como en los labs 02 y 03, y escribe un
`tests/run` (lab 04) con un check por cada uno de los cinco fallos. Para
cada check, vuelve a meter su fallo en una copia del kit y comprueba que
solo cae ese.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — Auditoría del kit](../lab-05-auditoria-del-kit/README.md) | [Proyecto — tmux-kit: instalador, checks propios y entrega final](../../3-proyecto/README.md) → |

[↑ Semana 13](../../README.md)
