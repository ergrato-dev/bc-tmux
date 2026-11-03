# Lab 01 — Enlaces y XDG

⏱ Duración estimada: ~60 min

## Objetivo

Instalar un kit enlazando su directorio en `~/.config/tmux` dentro de un HOME de pruebas y comprobar qué archivos de config carga tmux de verdad.

## Contexto

- Instalar el kit es **un enlace simbólico**: `~/.config/tmux -> /ruta/al/kit`. Editas en el repo y tmux lo ve; desinstalar es borrar el enlace.
- tmux busca su config en `~/.tmux.conf`, `$XDG_CONFIG_HOME/tmux/tmux.conf` y `~/.config/tmux/tmux.conf`, y **carga todos los que existen**. `#{config_files}` dice cuáles cargó.
- Todo el lab trabaja en un HOME temporal: tu `~/.config` real no se toca.

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo, abre una shell
   en el laboratorio:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` no imprime nada). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg
   H=$(mktemp -d); K="$PWD/starter"
   tmh() { env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab "$@"; }
   echo "$H"
   ```
   Algo como (cambia el nombre):
   ```
   /tmp/tmp.r8TCLrnEgM
   ```
   `H` es el HOME de pruebas y `K` el kit que vas a instalar (la carpeta
   `starter/`). `tmh` lanza tmux en el servidor `-L lab` con ese HOME y sin
   `XDG_CONFIG_HOME`: así tmux no puede encontrar tu config real. Si cierras
   la shell, repite este paso.

1. **Sin config.** El HOME de pruebas está vacío:
   ```bash
   tmh new -d -s lab
   tmh display -p '[#{config_files}]'
   tmh show -gv prefix
   tmh kill-server
   ```
   ```
   []
   C-b
   ```
   Ningún archivo cargado y el prefix de fábrica.

2. **TODO 1 — el prefix del kit.** En `starter/conf.d/10-options.conf`,
   las tres líneas del TODO: `set -g prefix C-a`, `unbind C-b` y
   `bind C-a send-prefix`. Prueba el kit **sin instalarlo**, con `-f`:
   ```bash
   tmux -L lab -f "$K/tmux.conf" new -d -s lab \; show -gv prefix
   tmux -L lab kill-server
   ```
   ```
   C-a
   ```
   Si ves `C-b`, el TODO no está bien. El prefix `C-a` es la marca que
   usarás en el resto del lab para saber si tmux cargó el kit.

3. **El enlace.** Instala el kit en el HOME de pruebas:
   ```bash
   mkdir -p "$H/.config"
   ln -s "$K" "$H/.config/tmux"
   ls -l "$H/.config"
   readlink "$H/.config/tmux"
   ```
   Algo como (cambian la fecha y la ruta del HOME):
   ```
   total 4
   lrwxrwxrwx 1 alumno alumno 86 Nov  3 23:13 tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   ```
   La `l` inicial es "enlace". `readlink` imprime a dónde apunta, sin
   seguirlo.

4. **tmux arranca con el kit, sin `-f`.**
   ```bash
   tmh new -d -s lab
   tmh display -p '#{config_files}'
   tmh show -gv @kit-dir
   tmh show -gv prefix
   tmh kill-server
   ```
   ```
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter/tmux.conf
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   C-a
   ```
   tmux encontró `~/.config/tmux/tmux.conf`, pero `#{config_files}`
   muestra la ruta **real**: resuelve el enlace. Por eso
   `#{d:current_file}` (y `@kit-dir`) apunta al repo y el
   `source-file` de `conf.d/` sigue funcionando.

5. **`ln -s` dos veces.** Un instalador se ejecuta más de una vez. Repite el
   mismo `ln -s`:
   ```bash
   ln -s "$K" "$H/.config/tmux"; echo $?
   ls -l "$K"
   ```
   Algo como (cambian las fechas):
   ```
   0
   total 12
   drwxr-xr-x 2 alumno alumno 4096 Nov  3 23:13 conf.d
   lrwxrwxrwx 1 alumno alumno   86 Nov  3 23:13 starter -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   -rw-r--r-- 1 alumno alumno  395 Nov  3 23:13 tmux.conf
   ```
   Sale con 0 y no avisa. Como `~/.config/tmux` ya es (un enlace a) un
   directorio, `ln` creó el enlace **dentro**: ahora hay un
   `starter -> starter` en tu kit. Bórralo y repite con `-sfn`: `-f`
   reemplaza el destino y `-n` lo trata como archivo aunque apunte a un
   directorio:
   ```bash
   rm "$K/starter"
   ln -sfn "$K" "$H/.config/tmux"; echo $?
   ls "$K"
   ```
   ```
   0
   conf.d
   tmux.conf
   ```

6. **`-n` no salva un directorio real.** Simula a alguien que ya tenía su
   propia config:
   ```bash
   rm "$H/.config/tmux"
   mkdir "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   ln -sfn "$K" "$H/.config/tmux"; echo $?
   ls -l "$H/.config/tmux"
   ```
   Algo como:
   ```
   0
   total 8
   lrwxrwxrwx 1 alumno alumno 86 Nov  3 23:13 starter -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   -rw-r--r-- 1 alumno alumno 27 Nov  3 23:13 tmux.conf
   ```
   `-n` solo sirve con enlaces: sobre un directorio de verdad, el enlace
   vuelve a quedar dentro. ¿Qué carga tmux?
   ```bash
   tmh new -d -s lab
   tmh display -p '#{config_files}'
   tmh show -gv prefix
   tmh kill-server
   ```
   Algo como:
   ```
   /tmp/tmp.r8TCLrnEgM/.config/tmux/tmux.conf
   C-b
   ```
   La config vieja, no el kit, y el instalador "funcionó". Con config real
   hay que **apartarla antes** (backup, lab 02). Aquí es de pruebas: bórrala
   y enlaza bien:
   ```bash
   rm -rf "$H/.config/tmux"
   ln -sfn "$K" "$H/.config/tmux"
   readlink "$H/.config/tmux"
   ```
   ```
   /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter
   ```

7. **El `~/.tmux.conf` heredado.** Muchos usuarios tienen uno de antes:
   ```bash
   echo 'set -g prefix C-x' > "$H/.tmux.conf"
   tmh new -d -s lab
   tmh display -p '#{config_files}'
   tmh show -gv prefix
   tmh kill-server
   rm "$H/.tmux.conf"
   ```
   Algo como:
   ```
   /tmp/tmp.r8TCLrnEgM/.tmux.conf,/bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter/tmux.conf
   C-a
   ```
   tmux cargó **los dos**: primero `~/.tmux.conf` y luego el kit, que gana
   porque fija el prefix después. Cualquier opción que el kit no toque se
   queda como la dejó el archivo viejo: un instalador debe avisar si existe.

8. **`XDG_CONFIG_HOME`.** Quien lo define espera su config en
   `$XDG_CONFIG_HOME/tmux`. Aquí no se usa `tmh`, porque hay que pasar la
   variable:
   ```bash
   mkdir -p "$H/xdg/tmux"
   echo 'set -g status-style bg=red' > "$H/xdg/tmux/tmux.conf"
   env HOME="$H" XDG_CONFIG_HOME="$H/xdg" tmux -L lab new -d -s lab
   tmux -L lab display -p '#{config_files}'
   tmux -L lab show -gv status-style
   tmux -L lab kill-server
   ```
   Algo como:
   ```
   /tmp/tmp.r8TCLrnEgM/xdg/tmux/tmux.conf,/bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-01-enlaces-y-xdg/starter/tmux.conf
   bg=red
   ```
   Otra vez dos configs mezcladas. Un instalador que enlaza siempre en
   `~/.config/tmux` deja viva la de `XDG_CONFIG_HOME`: el destino correcto
   es `${XDG_CONFIG_HOME:-$HOME/.config}/tmux`.

9. **Limpia.**
   ```bash
   rm -rf "$H"
   ls "$K"
   ```
   ```
   conf.d
   tmux.conf
   ```
   Borrar el HOME borra el enlace, no el kit. Si `ls` muestra un
   `starter` de más (paso 5), bórralo con `rm "$K/starter"`. Sal del
   laboratorio con `exit`.

## Criterios de éxito

- [ ] `tmux -L lab -f "$K/tmux.conf" new -d -s lab \; show -gv prefix` imprime `C-a` (paso 2)
- [ ] Con el enlace y sin `-f`, `#{config_files}` muestra la ruta real `.../starter/tmux.conf` y el prefix es `C-a` (paso 4)
- [ ] Sabes explicar el `starter -> starter` que crea el segundo `ln -s` y por qué `ln -sfn` no lo crea (paso 5)
- [ ] Sobre un directorio real, `ln -sfn` deja el enlace dentro y tmux sigue con `C-b` (paso 6)
- [ ] Con `~/.tmux.conf` o con `XDG_CONFIG_HOME`, `#{config_files}` lista dos archivos (pasos 7 y 8)
- [ ] `ls "$K"` termina con solo `conf.d` y `tmux.conf` (paso 9)

## Reto extra

Con `XDG_CONFIG_HOME="$H/xdg"` y el kit enlazado en `$H/xdg/tmux` **y**
en `$H/.config/tmux`, ¿lo carga dos veces? Compruébalo con
`#{config_files}` y piensa qué pasaría con una opción que añade a una
lista (`set -ga`) en vez de fijarla.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Instalador idempotente](../lab-02-instalador-idempotente/README.md) → |

[↑ Semana 13](../../README.md)
