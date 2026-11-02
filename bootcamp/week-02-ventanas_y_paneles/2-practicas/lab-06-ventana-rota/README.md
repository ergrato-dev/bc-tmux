# Lab 06 — La ventana rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de un script que monta una ventana de monitorización, usando ids de panel y comprobando el resultado con `list-panes`.

## Contexto

Un compañero escribió `starter/montar.sh` para tener una ventana `monitor` con
tres paneles: `cpu` a la izquierda ocupando media pantalla, y `disco` y `red`
apilados a la derecha. Él lo ejecuta desde una terminal suelta y "le
funciona". Tú lo ejecutas, como casi todo, **desde dentro de tmux**, y pasan
cosas raras. El script tiene **cuatro errores reales**: los cuatro aparecen
por no decirle a tmux sobre qué objeto actuar.

## Instrucciones

1. Abre la sesión desde la que vas a trabajar y quédate dentro:
   ```bash
   tmux -L lab new -s otra
   ```
   Todos los pasos siguientes se ejecutan **en ese panel**.

2. Ejecuta el script y lee el error:
   ```bash
   ./starter/montar.sh
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   ```
   Ya lo viste en la semana 01 (lab 05). **Error 1.** Corrígelo.

3. Ejecútalo otra vez. Dice `ventana monitor lista`, pero tu propia pantalla
   acaba de partirse en tres. Desde otra terminal, mira dónde está cada panel:
   ```bash
   tmux -L lab list-panes -a -F '#{session_name} #{pane_id} #{pane_title}'
   ```
   ```
   monitor %1 bc-tmux-lab
   otra %0 cpu
   otra %2 disco
   otra %3 red
   ```
   Sin `-t`, un comando lanzado desde dentro de tmux actúa sobre **el panel
   desde el que se lanzó** (el de `$TMUX_PANE`), no sobre la sesión que el
   script acaba de crear. Pasa con `split-window` (**error 2**) y con
   `select-pane -T` (**error 3**: tu panel de `otra` se llama ahora `cpu`).
   `bc-tmux-lab` es el título por defecto: el nombre de la máquina.

4. Arregla los dos con ids: guarda el que devuelve cada comando con
   `-P -F '#{pane_id}'` y úsalo en cada `-t`. Antes de repetir, limpia:
   `tmux -L lab kill-session -t monitor` y cierra los paneles sobrantes de
   `otra` con `prefix` `x`.

5. Con los paneles en su sitio, mira los anchos:
   ```bash
   tmux -L lab list-panes -t monitor -F '#{pane_title} #{pane_left} #{pane_width}'
   ```
   `cpu` ocupa casi toda la ventana y `disco` y `red` se quedan en una
   columna. La opción `main-pane-width` se lee **al aplicar** el layout:
   ponerla después de `select-layout` no cambia nada hasta el siguiente
   `select-layout`, y el valor por defecto (80 columnas) se come la ventana.
   **Error 4.**

6. Cuando lo tengas, desde el panel de `otra`:
   ```bash
   tmux -L lab kill-session -t monitor
   ./starter/montar.sh
   tmux -L lab list-panes -a -F '#{session_name} #{pane_title} #{pane_left} #{pane_top}'
   ```
   ```
   monitor cpu 0 0
   monitor disco 40 0
   monitor red 40 12
   otra bc-tmux-lab 0 0
   ```
   (Las columnas dependen del tamaño de tu terminal.) `cpu` empieza en la
   columna 0 con la mitad del ancho, `disco` está sobre `red`, y `otra` sigue
   con **un** panel y su título original.

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Los cuatro errores identificados, con una línea por cada uno explicando el síntoma y la causa
- [ ] El script corre desde dentro de tmux sin errores y no toca la sesión `otra`
- [ ] `list-panes` muestra `cpu` a la izquierda y `disco` sobre `red` a la derecha, con los títulos correctos
- [ ] Ningún `-t` del script usa un índice de panel

## Reto extra

Ejecuta el script **original** desde una terminal fuera de tmux (con el
error 1 corregido). ¿Dónde acaban ahora los paneles? Sin `$TMUX_PANE`, tmux
elige la sesión usada más recientemente: por eso al compañero "le funciona".
