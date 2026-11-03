# Lab 02 — Instalador idempotente

⏱ Duración estimada: ~60 min

## Objetivo

Escribir un `install.sh` que enlaza el kit en `${XDG_CONFIG_HOME:-$HOME/.config}/tmux`, aparta la config que ya había y no cambia nada si lo lanzas dos veces.

## Contexto

- `starter/` es un kit mínimo (`tmux.conf`, `conf.d/` con prefix `C-a`) más `install.sh` con cinco TODOs. El script se instala a sí mismo: enlaza su propio directorio.
- Idempotente: la segunda ejecución detecta que ya está hecho y sale con 0. Ni un backup de más ni un enlace dentro del kit (lab 01, paso 5).
- `--dry-run` enseña lo que haría sin tocar nada: se ensaya antes de lanzarlo sobre un HOME de verdad.

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` vacío). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente
   H=$(mktemp -d); I="$PWD/starter/install.sh"
   inst() { env -u XDG_CONFIG_HOME HOME="$H" "$I" "$@"; }
   ```
   (sin salida)

   `inst` lanza el instalador con el HOME de pruebas `H` y sin
   `XDG_CONFIG_HOME`. En todo el lab, `/tmp/tmp.joiQmepwpx` es un ejemplo:
   tu `H` tiene otro nombre.

1. **TODO 1 — la ruta del kit.** Primero mira el fallo. Lanza el starter
   desde otro directorio:
   ```bash
   (cd /tmp && inst); echo $?
   readlink "$H/.config/tmux"
   ls "$H/.config/tmux/"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> .
   0
   .
   tmux
   ```
   Un enlace relativo se resuelve desde **su** directorio: `tmux -> .`
   apunta a `.config`, no al kit, y `ls` se ve a sí mismo. En
   `starter/install.sh`, cambia `kit=.` por
   `kit=$(cd "$(dirname "$0")" && pwd -P)`: entra en el directorio del
   script en una subshell e imprime su ruta física. Borra el enlace roto y
   repite:
   ```bash
   rm -rf "$H/.config"
   (cd /tmp && inst); echo $?
   ls "$H/.config/tmux/"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   conf.d
   install.sh
   tmux.conf
   ```

2. **TODO 2 — `XDG_CONFIG_HOME`.** Con la variable definida, el starter
   instala en el sitio equivocado:
   ```bash
   mkdir -p "$H/xdg"
   env HOME="$H" XDG_CONFIG_HOME="$H/xdg" "$I"
   ls "$H/xdg"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   ```
   `$H/xdg` sigue vacío. Cambia `target` por
   `"${XDG_CONFIG_HOME:-$HOME/.config}/tmux"` (`:-` usa `$HOME/.config` si
   la variable no existe o está vacía) y repite:
   ```bash
   env HOME="$H" XDG_CONFIG_HOME="$H/xdg" "$I"
   ls "$H/xdg"
   rm -rf "$H/xdg"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/xdg/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   tmux
   ```

3. **TODO 3 — ya instalado.** Hoy la segunda ejecución vuelve a enlazar
   (`ln -sfn` lo hace sin daño, pero no lo sabes):
   ```bash
   inst; echo $?
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   ```
   Escribe el `if` del TODO 3: `[[ -L "$target" && "$(readlink "$target")" == "$kit" ]]`,
   y dentro el `echo` y `exit 0`. Dos veces:
   ```bash
   inst; echo $?
   inst; echo $?
   ```
   Algo como:
   ```
   install.sh: ya instalado en /tmp/tmp.joiQmepwpx/.config/tmux
   0
   install.sh: ya instalado en /tmp/tmp.joiQmepwpx/.config/tmux
   0
   ```
   `readlink` sin `-f` imprime el destino tal cual se creó: como el enlace
   se hizo con `$kit` (ruta física), la comparación es exacta.

4. **TODO 4 — backup.** Simula a alguien con su propia config:
   ```bash
   rm "$H/.config/tmux"
   mkdir "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst; echo $?
   ls -l "$H/.config/tmux"
   ```
   Algo como (cambian las fechas):
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   total 8
   lrwxrwxrwx 1 alumno alumno 95 Nov  3 23:15 starter -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   -rw-r--r-- 1 alumno alumno 27 Nov  3 23:15 tmux.conf
   ```
   Dice que instaló y lo dejó **dentro** de la config vieja (lab 01,
   paso 6). Escribe el TODO 4: `if [[ -e "$target" || -L "$target" ]]`,
   `backup=...` con la fecha, el `echo` y `run mv "$target" "$backup"`.
   Rehaz la config de pruebas y repite:
   ```bash
   rm -rf "$H/.config/tmux"
   mkdir "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst; echo $?
   ls "$H/.config"
   cat "$H"/.config/tmux.bak.*/tmux.conf
   ```
   Algo como (cambia la fecha del backup):
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux ya existe, lo muevo a /tmp/tmp.joiQmepwpx/.config/tmux.bak.20261103-231542
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   tmux
   tmux.bak.20261103-231542
   set -g status-style bg=red
   ```
   La config vieja está intacta en el backup. Un enlace a otro sitio
   también se aparta (no apunta a este kit, así que el TODO 3 no lo
   salta):
   ```bash
   ln -sfn /tmp "$H/.config/tmux"
   sleep 1
   inst
   ls "$H/.config"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux ya existe, lo muevo a /tmp/tmp.joiQmepwpx/.config/tmux.bak.20261103-231543
   install.sh: /tmp/tmp.joiQmepwpx/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   tmux
   tmux.bak.20261103-231542
   tmux.bak.20261103-231543
   ```
   El `sleep 1` evita dos backups con el mismo segundo: el nombre lleva
   hora, minuto y segundo.

5. **TODO 5 — `--dry-run`.** Empieza en un HOME vacío y prueba la opción
   con el starter tal cual:
   ```bash
   rm -rf "$H"; H=$(mktemp -d)
   inst --dry-run; echo $?
   ls -A "$H"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.ZcXemArYwh/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   .config
   ```
   El ensayo instaló de verdad. Cambia el cuerpo de `run()` por
   `if (( dry_run )); then echo "haría: $*"; else "$@"; fi` y borra las
   dos líneas de arriba del todo (el aviso y el
   `# shellcheck disable=SC2034`): ya se usa `dry_run`. Vacía el HOME y
   repite, ahora también con una config real:
   ```bash
   rm -rf "$H"; H=$(mktemp -d)
   inst --dry-run; echo $?
   ls -A "$H"
   mkdir -p "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst --dry-run; echo $?
   ls "$H/.config"
   ```
   Algo como:
   ```
   haría: mkdir -p /tmp/tmp.HMRzKKvsPh/.config
   haría: ln -sfn /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter /tmp/tmp.HMRzKKvsPh/.config/tmux
   install.sh: /tmp/tmp.HMRzKKvsPh/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   install.sh: /tmp/tmp.HMRzKKvsPh/.config/tmux ya existe, lo muevo a /tmp/tmp.HMRzKKvsPh/.config/tmux.bak.20261103-231554
   haría: mv /tmp/tmp.HMRzKKvsPh/.config/tmux /tmp/tmp.HMRzKKvsPh/.config/tmux.bak.20261103-231554
   haría: mkdir -p /tmp/tmp.HMRzKKvsPh/.config
   haría: ln -sfn /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter /tmp/tmp.HMRzKKvsPh/.config/tmux
   install.sh: /tmp/tmp.HMRzKKvsPh/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-02-instalador-idempotente/starter
   0
   tmux
   ```
   El primer `ls -A` no imprime nada y el segundo solo ve la config
   original: el ensayo no tocó el disco. Las órdenes que cambian algo pasan
   todas por `run`; los `echo` informan igual en los dos modos.

6. **Opción desconocida, shellcheck y tmux.** Instala de verdad en el HOME
   de pruebas y arranca tmux sin `-f`:
   ```bash
   inst --forzar; echo $?
   shellcheck starter/install.sh; echo $?
   rm -rf "$H"; H=$(mktemp -d)
   inst > /dev/null
   env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab new -d -s lab
   tmux -L lab show -gv prefix
   tmux -L lab kill-server
   ```
   ```
   install.sh: opción desconocida: --forzar
   2
   0
   C-a
   ```
   El 2 distingue "me usaste mal" de "fallé" (1). tmux encontró el kit a
   través del enlace: prefix `C-a`.

7. **Limpia.**
   ```bash
   rm -rf "$H"
   ```
   (sin salida)

   Sal del laboratorio con `exit`. El `install.sh` terminado es la base del
   lab 03.

## Criterios de éxito

- [ ] Lanzado desde `/tmp`, `readlink "$H/.config/tmux"` imprime la ruta absoluta de `starter` (paso 1)
- [ ] Con `XDG_CONFIG_HOME="$H/xdg"`, el enlace queda en `$H/xdg/tmux` (paso 2)
- [ ] Dos ejecuciones seguidas imprimen `install.sh: ya instalado en ...` y salen con 0 (paso 3)
- [ ] La config real pasa a `tmux.bak.<fecha>` con su contenido intacto; un enlace ajeno también (paso 4)
- [ ] `--dry-run` imprime líneas `haría:` y `ls -A "$H"` sale vacío (paso 5)
- [ ] `--forzar` sale con 2, `shellcheck` con 0 y tmux arranca con prefix `C-a` (paso 6)

## Reto extra

Añade un aviso: si existe `$HOME/.tmux.conf`, imprime en stderr que tmux
lo cargará además del kit (lab 01, paso 7). Pruébalo creando
`"$H/.tmux.conf"` antes de `inst`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Enlaces y XDG](../lab-01-enlaces-y-xdg/README.md) | [Lab 03 — Desinstalar y restaurar](../lab-03-desinstalar-y-restaurar/README.md) → |

[↑ Semana 13](../../README.md)
