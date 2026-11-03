# Lab 04 — Interpolación en la status line

⏱ Duración estimada: ~60 min

## Objetivo

Completar un plugin que cambia marcadores propios de `status-right` (`#{sysload_load}`, `#{sysload_cores}`) por un `#(script)` y por un valor fijo, como hacen tmux-cpu y tmux-battery.

## Contexto

- Tú escribes `#{cpu_percentage}` en tu barra y el plugin, al cargarse, lo cambia en la opción por algo que tmux sí entiende: casi siempre un `#(ruta/al/script)`.
- `#(...)` lo ejecuta `sh -c` cada `status-interval` segundos, y solo para dibujar la barra de un cliente. Un valor que no cambia (los núcleos) se calcula una vez, al cargar, y no cuesta nada al redibujar.
- El plugin solo puede sustituir lo que ya está en la opción: va después de `status-right` en la config.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` vacío), las
   dos desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-04-interpolacion-en-la-status
   ```
   En la **terminal A**:
   ```bash
   P="$PWD/starter/sysload/sysload.tmux"; C="$PWD/starter/tmux.conf"
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   La terminal B se conecta en el paso 3.

1. **Marcadores sin plugin.** El starter ya carga el plugin, pero el plugin
   aún no sustituye nada:
   ```bash
   tmux -L lab show -gv status-right
   tmux -L lab display -p "$(tmux -L lab show -gv status-right)"
   starter/sysload/scripts/load.sh; nproc
   ```
   Algo como (cambian la hora, la carga y los núcleos):
   ```
   carga #{sysload_load}/#{sysload_cores} | %H:%M
   carga / | 20:09
   0.65
   8
   ```
   Un `#{...}` que tmux no conoce sale vacío, sin error. En macOS, `nproc`
   no existe: usa `sysctl -n hw.ncpu`.

2. **TODO 1, 2 y 3 — sustituir.** En `starter/sysload/sysload.tmux` quita
   el `#` (y los espacios que lo siguen) de la línea `CURRENT_DIR=` (TODO 1),
   de las líneas `printf -v load` y `cores=` (TODO 2) y de las dos líneas
   `new=${new//...}` dentro del bucle (TODO 3). Carga el plugin:
   ```bash
   tmux -L lab run-shell "$P"; echo $?
   tmux -L lab show -gv status-right
   tmux -L lab display -p "$(tmux -L lab show -gv status-right)"
   ```
   Algo como (la ruta es la de tu carpeta del lab):
   ```
   0
   carga #(/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-04-interpolacion-en-la-status/starter/sysload/scripts/load.sh)/8 | %H:%M
   carga /8 | 20:09
   ```
   Los núcleos ya son un `8` fijo; la carga es un `#(...)` con la ruta
   absoluta, que el plugin calculó con `CURRENT_DIR`. `display -p` desde la
   terminal no ejecuta `#(...)` (sale vacío): esos comandos solo corren
   para la barra de un cliente conectado.

3. **Míralo en la barra.** En la **terminal B**, desde la carpeta del lab:
   ```bash
   tmux -L lab attach -t lab
   ```
   A la derecha de la barra, algo como:
   ```
   carga 0.46/8 | 20:10
   ```
   La primera vez puede salir `carga /8` un instante: tmux ejecuta el
   script en segundo plano y pinta cuando termina. El número cambia cada
   5 s (`status-interval 5` del starter). Sal con `C-b` `d` (el starter no
   cambia el prefix); B imprime `[detached (from session lab)]`.

4. **Idempotente sin hacer nada especial.** Tras la primera carga ya no
   quedan marcadores, así que cargar otra vez no cambia nada. Recargar la
   config vuelve a poner los marcadores y el plugin los sustituye de nuevo
   (terminal A):
   ```bash
   tmux -L lab run-shell "$P"; tmux -L lab show -gv status-right
   tmux -L lab source-file "$C"; tmux -L lab source-file "$C"; tmux -L lab show -gv status-right
   ```
   ```
   carga #(/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-04-interpolacion-en-la-status/starter/sysload/scripts/load.sh)/8 | %H:%M
   carga #(/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-04-interpolacion-en-la-status/starter/sysload/scripts/load.sh)/8 | %H:%M
   ```

5. **Por qué `printf %q`.** Copia el plugin a una carpeta con un espacio y
   cárgalo desde ahí sobre una barra de prueba:
   ```bash
   mkdir -p "/tmp/lab11 kit" && cp -r starter/sysload "/tmp/lab11 kit/"
   tmux -L lab set -g status-right 'carga #{sysload_load}'
   tmux -L lab run-shell '"/tmp/lab11 kit/sysload/sysload.tmux"'; echo $?
   tmux -L lab show -gv status-right
   ```
   ```
   0
   carga #(/tmp/lab11\ kit/sysload/scripts/load.sh)
   ```
   `%q` escribió `lab11\ kit`. Lo que tmux le pasa a `sh -c` con y sin esa
   barra:
   ```bash
   sh -c '/tmp/lab11\ kit/sysload/scripts/load.sh'
   sh -c '/tmp/lab11 kit/sysload/scripts/load.sh'; echo $?
   ```
   Algo como (cambia la carga):
   ```
   0.63
   sh: 1: /tmp/lab11: not found
   127
   ```
   Sin citar, la barra mostraría `carga ` vacío para siempre y ningún
   mensaje: el error de un `#(...)` no se ve en ningún sitio.

6. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -r "/tmp/lab11 kit"
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Tras cargar el plugin, `tmux -L lab show -gv status-right` contiene `#(` + la ruta de `load.sh` y el número de núcleos en lugar de los marcadores (paso 2)
- [ ] La barra de un cliente conectado muestra `carga N.NN/N` y la carga cambia cada 5 s (paso 3)
- [ ] Dos `source-file` seguidos dejan el mismo `status-right` que una sola carga (paso 4)
- [ ] Explicas por qué `display -p` desde la terminal muestra la carga vacía y la barra no (pasos 2 y 3)
- [ ] Explicas qué ve `sh -c` sin el `%q` cuando la ruta tiene un espacio (paso 5)
- [ ] `shellcheck starter/sysload/sysload.tmux` no imprime nada

## Reto extra

Añade un tercer marcador, `#{sysload_color}`, que se cambie por un format
condicional de tmux (no por un `#(...)`): `#[fg=red]` cuando la sesión
tiene más de 3 ventanas y `#[fg=green]` si no
(`#{?#{e|>:#{session_windows},3},...,...}`). ¿Por qué este marcador no
necesita `status-interval` para actualizarse?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Anatomía de un plugin](../lab-03-anatomia-de-un-plugin/README.md) | [Lab 05 — tmuxp](../lab-05-tmuxp/README.md) → |

[↑ Semana 11](../../README.md)
