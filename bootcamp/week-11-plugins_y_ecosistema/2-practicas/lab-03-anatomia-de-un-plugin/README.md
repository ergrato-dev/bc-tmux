# Lab 03 — Anatomía de un plugin

⏱ Duración estimada: ~60 min

## Objetivo

Escribir un plugin mínimo sin TPM (un `*.tmux` con opciones con valor por defecto, una tecla y un segmento de status line) que se pueda cargar dos veces sin duplicar nada.

## Contexto

- Un plugin es un script ejecutable que termina en `.tmux`. `run-shell` (o TPM, que hace lo mismo) lo ejecuta dentro del servidor, y el script le habla a tmux con `tmux set`, `tmux bind-key`, `tmux show`.
- Sus opciones las fija el usuario **antes** de cargarlo (`set -g @zoom-flag-key z`); el plugin solo pone el valor por defecto si siguen vacías.
- Recargar la config vuelve a ejecutar el plugin. Lo que haga con `set -ga` o `set-hook -ga` se acumula; tiene que comprobar antes de añadir.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux** (`echo "$TMUX"` vacío), desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-03-anatomia-de-un-plugin
   P="$PWD/starter/zoom-flag/zoom-flag.tmux"; C="$PWD/starter/tmux.conf"
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   `P` y `C` son rutas absolutas: `run-shell` se ejecuta en el directorio
   del servidor, no en el tuyo. Abre `starter/zoom-flag/zoom-flag.tmux` en
   tu editor; el plugin es todo ese archivo.

1. **Ejecútalo a mano, dos veces.** Así lo carga TPM: `run-shell` sobre
   el `*.tmux`:
   ```bash
   tmux -L lab run-shell "$P"; echo $?
   tmux -L lab run-shell "$P"
   tmux -L lab show -gv status-right
   tmux -L lab show -gv @zoom-flag-text; echo $?
   ```
   ```
   0
   %H:%M#{?window_zoomed_flag,[#{@zoom-flag-text}] ,}#{?window_zoomed_flag,[#{@zoom-flag-text}] ,}
   invalid option: @zoom-flag-text
   1
   ```
   Dos cargas, dos segmentos: lo arregla el TODO 3. La opción no existe
   todavía: `show` sin `-q` falla con 1, y en un script con `set -e` ese 1
   cortaría el plugin.

2. **TODO 1 — valores por defecto.** En `set_default`, cambia el `:` por:
   ```bash
   [[ -n "$(tmx show -gqv "$1")" ]] || tmx set -g "$1" "$2"
   ```
   Recarga la config (vuelve a poner `status-right '%H:%M'`) y carga el
   plugin. Después fija tú el texto y vuelve a cargarlo:
   ```bash
   tmux -L lab source-file "$C"; tmux -L lab run-shell "$P"; echo $?
   tmux -L lab show -g | grep '^@zoom'
   tmux -L lab set -g @zoom-flag-text LUPA; tmux -L lab run-shell "$P"; tmux -L lab show -gv @zoom-flag-text
   tmux -L lab set -gu @zoom-flag-text
   ```
   ```
   0
   @zoom-flag-key Z
   @zoom-flag-text ZOOM
   LUPA
   ```
   El plugin no pisó `LUPA`: el usuario manda. `set -gu` la borra para
   volver al valor por defecto en la siguiente carga.

3. **TODO 2 — la tecla.** Debajo del comentario del TODO 2 escribe:
   ```bash
   key=$(tmx show -gqv @zoom-flag-key)
   tmx bind-key "$key" resize-pane -Z
   ```
   ```bash
   tmux -L lab list-keys -T prefix Z; echo $?
   tmux -L lab run-shell "$P"; echo $?
   tmux -L lab list-keys -T prefix Z
   ```
   ```
   unknown key: Z
   1
   0
   bind-key -T prefix Z resize-pane -Z
   ```
   `bind-key` es idempotente por naturaleza: la misma tecla se sustituye.

4. **TODO 3 — el segmento, una sola vez.** Cambia la última línea
   (`tmx set -ga status-right "$segment"`) por:
   ```bash
   right=$(tmx show -gqv status-right)
   [[ "$right" == *"$segment"* ]] || tmx set -g status-right "$segment$right"
   ```
   ```bash
   tmux -L lab source-file "$C"; tmux -L lab run-shell "$P"; tmux -L lab run-shell "$P"
   tmux -L lab show -gv status-right
   ```
   ```
   #{?window_zoomed_flag,[#{@zoom-flag-text}] ,}%H:%M
   ```
   Un solo segmento tras dos cargas, y ahora delante de la hora.

5. **El segmento funciona.** `display -p` expande un format como lo haría
   la barra; necesitas dos paneles para hacer zoom:
   ```bash
   tmux -L lab split-window -d -t lab:
   tmux -L lab display -p -t lab: "$(tmux -L lab show -gv status-right)"
   tmux -L lab resize-pane -Z -t lab:
   tmux -L lab display -p -t lab: "$(tmux -L lab show -gv status-right)"
   tmux -L lab set -g @zoom-flag-text LUPA
   tmux -L lab display -p -t lab: "$(tmux -L lab show -gv status-right)"
   ```
   Algo como (cambia la hora):
   ```
   20:08
   [ZOOM] 20:08
   [LUPA] 20:08
   ```
   El texto cambió sin volver a cargar el plugin: el segmento guarda
   `#{@zoom-flag-text}`, no su valor.

6. **TODO 4 — cárgalo desde la config.** En `starter/tmux.conf` quita el
   `#   ` de la línea `run-shell`. Reinicia el servidor y recarga dos veces:
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   tmux -L lab source-file "$C"; tmux -L lab source-file "$C"; echo $?
   tmux -L lab show -gv status-right
   tmux -L lab list-keys -T prefix Z
   ```
   ```
   0
   0
   #{?window_zoomed_flag,[#{@zoom-flag-text}] ,}%H:%M
   bind-key -T prefix Z resize-pane -Z
   ```
   Cada recarga vuelve a poner `status-right '%H:%M'` y el plugin le añade
   el segmento: nunca dos.

7. **La opción del usuario, antes del plugin.** Añade
   `set -g @zoom-flag-key z` **encima** del `run-shell` y arranca de cero
   (una recarga dejaría también la `Z` vieja):
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab
   tmux -L lab list-keys -T prefix z
   ```
   ```
   bind-key -T prefix z resize-pane -Z
   ```
   Si quieres verlo en pantalla: en la terminal B, desde la carpeta del lab,
   `tmux -L lab attach -t lab`, divide con `C-b` `%` (el starter no cambia
   el prefix) y pulsa `C-b` `z`: la barra muestra `[ZOOM]`. Sales con
   `C-b` `d` → `[detached (from session lab)]`.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Con `@zoom-flag-text LUPA` puesto antes, cargar el plugin no lo cambia (paso 2)
- [ ] `tmux -L lab list-keys -T prefix Z` muestra `resize-pane -Z` (paso 3)
- [ ] Tras dos `source-file`, `show -gv status-right` contiene el segmento una sola vez (paso 6)
- [ ] `display -p` del `status-right` muestra `[ZOOM]` solo con el panel en zoom (paso 5)
- [ ] Explicas por qué el segmento lleva `#{@zoom-flag-text}` y no el valor de la opción (paso 5)
- [ ] `shellcheck starter/zoom-flag/zoom-flag.tmux` no imprime nada (instálalo con `sudo apt install shellcheck` o `brew install shellcheck`)

## Reto extra

Haz el plugin compatible con TPM: copia `starter/zoom-flag` a un repositorio
git propio, decláralo como `set -g @plugin 'tu-usuario/zoom-flag'` en la
config del lab 01 e instálalo. ¿Qué archivo ejecuta TPM y por qué el nombre
de la carpeta da igual? Añade también una opción `@zoom-flag-style` (por
ejemplo `fg=yellow`) que se aplique con `#[...]` dentro del segmento.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — resurrect y continuum](../lab-02-resurrect-y-continuum/README.md) | [Lab 04 — Interpolación en la status line](../lab-04-interpolacion-en-la-status/README.md) → |

[↑ Semana 11](../../README.md)
