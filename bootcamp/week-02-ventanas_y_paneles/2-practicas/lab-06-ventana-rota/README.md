# Lab 06 — La ventana rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de un script que monta una ventana de monitorización, usando ids de panel y comprobando el resultado con `list-panes`.

## Contexto

Un compañero escribió `starter/assemble.sh` para tener una ventana `monitor` con
tres paneles: `cpu` a la izquierda ocupando media pantalla, y `disco` y `red`
apilados a la derecha. Él lo ejecuta desde una terminal suelta y "le
funciona". Tú lo ejecutas, como casi todo, **desde dentro de tmux**, y pasan
cosas raras. El script tiene **cuatro errores reales**: los cuatro aparecen
por no decirle a tmux sobre qué objeto actuar.

## Instrucciones

- **Terminal A**: conectada a la sesión `otra`; ahí ejecutas el script, **dentro de tmux**.
- **Terminal B**: otra pestaña, fuera de tmux, para las comprobaciones.

0. En **las dos** terminales, fuera de tmux (`echo "$TMUX"` imprime una línea
   vacía), entra en la carpeta del lab desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-06-ventana-rota
   ```
   ```
   (sin salida)
   ```
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`: el prefix es
   **`C-b`**.

1. En la **terminal A**, abre la sesión desde la que vas a trabajar:
   ```bash
   tmux -L lab -f /dev/null new -s otra
   ```
   El panel nuevo empieza en la carpeta del lab. Ya estás dentro de tmux:
   ```bash
   echo "$TMUX_PANE"
   ```
   ```
   %0
   ```

2. **Error 1.** En la terminal A, ejecuta el script:
   ```bash
   ./starter/assemble.sh; echo $?
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   1
   ```
   Ya lo viste en la semana 01 (lab 05): sin `-d`, `new-session` intenta
   conectar tu cliente a la sesión nueva, y dentro de tmux se niega. Abre
   `starter/assemble.sh` en tu editor y añade `-d` a `new-session`. Encima de la
   línea, escribe un comentario con el síntoma y la causa:
   `# Error 1: ... — ...`. Harás lo mismo con cada error.

3. **Errores 2 y 3.** Ejecútalo otra vez en la terminal A:
   ```bash
   ./starter/assemble.sh
   ```
   ```
   ventana monitor lista
   ```
   Dice que está lista, pero **tu propia pantalla** se acaba de partir en
   tres. En la terminal B, mira dónde acabó cada panel:
   ```bash
   tmux -L lab list-panes -a -F '#{session_name} #{pane_id} #{pane_title}'
   ```
   Algo como (`bc-tmux-lab` es el título por defecto, el nombre de tu máquina):
   ```
   monitor %1 bc-tmux-lab
   otra %0 cpu
   otra %2 disco
   otra %3 red
   ```
   Sin `-t`, un comando lanzado desde dentro de tmux actúa sobre **la sesión
   en la que estás** (tmux la deduce de `$TMUX` y `$TMUX_PANE`) y, dentro de
   ella, sobre su **panel activo**: no sobre la sesión que el script acaba de
   crear. Pasa con `split-window` (**error 2**: los paneles nuevos están en
   `otra`) y con `select-pane -T` (**error 3**: tu panel `%0` se llama ahora
   `cpu`).

   Vuelve a empezar desde limpio. En la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```
   La terminal A sale de tmux con `[server exited]`. Vuelve a abrir la sesión
   allí con el mismo comando del paso 1 (`tmux -L lab -f /dev/null new -s otra`).

4. **Arregla los errores 2 y 3 con ids.** Guarda el id que devuelve cada
   comando que crea un panel y úsalo en cada `-t`. Esqueleto:
   ```bash
   cpu=$(tmx new-session -d -P -F '#{pane_id}' -s monitor -n monitor)
   tmx select-pane -t "$cpu" -T cpu

   disk=$(tmx split-window -h -P -F '#{pane_id}' -t "$cpu")
   tmx select-pane -t "$disk" -T disco
   ```
   Completa tú `net` (parte `$disk` con `-v`). No toques aún las dos líneas
   del layout. En la terminal A:
   ```bash
   ./starter/assemble.sh
   ```
   ```
   ventana monitor lista
   ```
   Tu pantalla ya no se parte. En la terminal B:
   ```bash
   tmux -L lab list-panes -a -F '#{session_name} #{pane_id} #{pane_title}'
   ```
   Algo como (el título de `otra` es el nombre de tu máquina):
   ```
   monitor %1 cpu
   monitor %2 disco
   monitor %3 red
   otra %0 bc-tmux-lab
   ```

5. **Error 4.** Mira los anchos en la terminal B:
   ```bash
   tmux -L lab list-panes -t monitor -F '#{pane_title} #{pane_left} #{pane_width}'
   ```
   ```
   cpu 0 78
   disco 79 1
   red 79 1
   ```
   La sesión `monitor` se creó con `-d`, así que mide 80x24 (`default-size`)
   sea cual sea tu terminal. `cpu` ocupa casi toda la ventana y `disco` y
   `red` se quedan en una columna: `main-pane-width` se lee **al aplicar** el
   layout, y el script la pone **después** del `select-layout`. Cuando se
   aplicó, valía 80 columnas (el valor por defecto) y se comió la ventana.
   Intercambia las dos líneas: primero `tmx set -w ... main-pane-width 50%`,
   después `tmx select-layout ... main-vertical`.

6. **Comprueba el arreglo.** La sesión `monitor` del intento anterior sigue
   viva y el script falla si ya existe (`duplicate session: monitor`).
   En la terminal B:
   ```bash
   tmux -L lab kill-session -t monitor
   ```
   ```
   (sin salida)
   ```
   En la terminal A:
   ```bash
   ./starter/assemble.sh
   ```
   ```
   ventana monitor lista
   ```
   En la terminal B:
   ```bash
   tmux -L lab list-panes -a -F '#{session_name} #{pane_title} #{pane_left} #{pane_top}'
   ```
   Algo como:
   ```
   monitor cpu 0 0
   monitor disco 40 0
   monitor red 40 12
   otra bc-tmux-lab 0 0
   ```
   `cpu` empieza en la columna 0 con la mitad del ancho (39 columnas y el
   borde), `disco` está sobre `red`, y `otra` sigue con **un** panel y su
   título original.

7. Limpia. En la terminal A, `C-b` `d`:
   ```
   [detached (from session otra)]
   ```
   En la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `starter/assemble.sh` tiene un comentario `# Error N:` encima de cada uno de los cuatro arreglos, con el síntoma y la causa (pasos 2-5)
- [ ] El script corre desde dentro de tmux sin errores y no toca la sesión `otra` (paso 4)
- [ ] `list-panes` muestra `cpu` a la izquierda y `disco` sobre `red` a la derecha, con los títulos correctos (paso 6)
- [ ] Ningún `-t` del script usa un índice de panel

## Reto extra

Ejecuta el script **original** (con solo el error 1 corregido) desde la
terminal B, fuera de tmux, con la sesión `otra` viva. ¿Dónde acaban ahora los
paneles? Sin `$TMUX`, tmux elige la sesión usada más recientemente, que es
`monitor`, la que el script acaba de crear: por eso al compañero "le funciona".
