# Lab 01 — Moverte por el historial

⏱ Duración estimada: ~60 min

## Objetivo

Recorrer, buscar y limpiar el historial de un panel con copy mode, fijando `mode-keys` y `history-limit` en tu config.

## Contexto

- El historial de cada panel lo guarda tmux, no tu terminal: la rueda o `Shift+PgUp` de la terminal no llegan a él. Se recorre en **copy mode** (`prefix` `[`).
- `mode-keys` decide qué teclas usa copy mode: `vi` (`/`, `n`, `v`...) o `emacs` (`C-s`, `C-r`, `C-Space`...). Si no lo fijas, tmux lo deduce del entorno al arrancar el servidor.
- `history-limit` se aplica al **crear** un panel; cambiarlo no amplía los que ya existen.

## Instrucciones

0. Abre **dos terminales fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía). La **terminal A** se conectará al servidor del lab; la **terminal
   B** se queda fuera para lanzar comandos. En las dos, desde la raíz del
   repositorio (en el laboratorio, `docker compose exec lab bash` en cada
   una):
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-01-moverte-por-el-historial
   ```
   Todo va contra un servidor aparte (`-L lab`): tu tmux de siempre no se toca.

1. **tmux adivina.** En la terminal B, arranca dos servidores sin config con
   editores distintos:
   ```bash
   env -u VISUAL EDITOR=nano tmux -L lab -f /dev/null new -d \; show -gwv mode-keys
   tmux -L lab kill-server
   env -u VISUAL EDITOR=vi tmux -L lab -f /dev/null new -d \; show -gwv mode-keys
   tmux -L lab kill-server
   env -u VISUAL -u EDITOR tmux -L lab -f /dev/null new -d \; show -gwv mode-keys
   tmux -L lab kill-server
   ```
   ```
   emacs
   vi
   emacs
   ```
   La regla: al arrancar, tmux mira `$VISUAL` y, si está vacía, `$EDITOR`. Si
   el valor contiene `vi`, usa `vi`; si no, `emacs`. No hace falta que el
   editor esté instalado: solo cuenta el texto. `env -u VISUAL` la quita
   para la prueba, porque si la tienes definida gana a `EDITOR`. La misma
   config, en otra máquina con otro entorno, te deja sin `/`, `n` ni `v`.

2. **TODO 1** de `starter/tmux.conf`: fija las teclas vi. Pista:
   `setw -g mode-keys vi` (es opción de ventana: `setw`, y `-g` para todas).
   Comprueba en la terminal B que ya no depende del entorno:
   ```bash
   env -u VISUAL EDITOR=nano tmux -L lab -f starter/tmux.conf new -d \; show -gwv mode-keys
   ```
   ```
   vi
   ```
   Deja este servidor arrancado: el `TODO 2` todavía no está resuelto, a
   propósito.

3. **El historial se acaba.** En la terminal A, conéctate al servidor del
   paso 2 y llena el panel:
   ```bash
   tmux -L lab attach
   ```
   El prefix de este servidor es `C-b`: el starter no define otro. Ya dentro:
   ```bash
   seq 1 5000
   ```
   Pulsa `C-b` `[`: arriba a la derecha aparece algo como `[0/1981]` (líneas
   que has subido / líneas que guarda el panel). Pulsa `g` (principio del
   historial): la primera línea no es `1`, sino un número cercano a `3000`, y
   el indicador dice algo como `[1981/1981]`. Nunca pasa de 2000, el valor
   por defecto. Sal de copy mode con `q`.

4. **TODO 2**: historial de 50000 líneas. Pista: `set -g history-limit 50000`.
   En la terminal B, recarga y compara la opción con lo que tiene el panel:
   ```bash
   tmux -L lab source-file starter/tmux.conf; echo $?
   tmux -L lab show -gv history-limit
   tmux -L lab display -p '#{history_limit}'
   ```
   ```
   0
   50000
   2000
   ```
   La opción vale 50000, pero el panel que ya existía conserva 2000. En la
   terminal A, abre una ventana nueva con `C-b` `c` y repite `seq 1 5000`. En
   la terminal B:
   ```bash
   tmux -L lab display -p '#{history_limit} #{history_size}'
   ```
   ```
   50000 4981
   ```
   (Algo como `4981`: `history_size` son las líneas que no caben en pantalla
   y depende de la altura de tu terminal y de tu prompt.) En la terminal A,
   `C-b` `[` y `g`: la primera línea es el prompt donde escribiste `seq`, y
   justo debajo está `1`. Sal con `q`.

5. **Muévete y busca** en esa ventana nueva. En la terminal A, entra con
   `C-b` `[` y prueba (después de cada fila, la terminal B te dice en qué
   línea está el cursor: `tmux -L lab display -p '#{copy_cursor_line}'`):

   | Prueba | Teclas | Dónde acabas |
   |---|---|---|
   | Buscar hacia arriba | `?` `999` `Enter` | En `4999`; arriba a la derecha, `(5 results)` |
   | Siguiente coincidencia | `n` y otra vez `n` | `3999`, luego `2999` |
   | Coincidencia anterior | `N` | `3999` otra vez |
   | Buscar un número concreto | `?` `4242` `Enter` | En `4242` |
   | Media página | `C-u` / `C-d` | Media pantalla arriba / abajo |
   | Arriba, medio, abajo | `H` / `M` / `L` | Primera, central o última línea visible |
   | Principio y final | `g` / `G` | El prompt del `seq` / la última línea |

   Solo hay cinco líneas que contienen `999` (`999`, `1999` ... `4999`), por
   eso la secuencia es exacta. Sal con `q`. Ahora entra con `C-b` `PgUp`
   (en un portátil Mac, `Fn+↑`): copy mode empieza ya una página arriba. Sal
   con `q`.

6. **Limpiar el historial.** En la terminal A:
   ```bash
   seq 1 5000; clear -x
   ```
   En la terminal B:
   ```bash
   tmux -L lab display -p '#{history_size}'
   tmux -L lab clear-history
   tmux -L lab display -p '#{history_size}'
   ```
   ```
   5002
   0
   ```
   (El primer número, algo como `5002`.) `clear -x` limpia solo la pantalla.
   Repite en la terminal A con `seq 1 5000; clear` (sin `-x`) y vuelve a
   mirar `#{history_size}` en la B: `0`. Dentro de tmux, `TERM` es
   `tmux-256color`, cuyo terminfo tiene la capacidad `E3` ("borra el
   scrollback"), y `clear` la usa. `C-l` en bash o zsh limpia sin borrarlo
   (en macOS, si `clear -x` no existe, usa `C-l`).

7. Limpia, en la terminal B:
   ```bash
   tmux -L lab kill-server
   ```
   La terminal A muestra `[server exited]` y vuelve a tu shell.

## Criterios de éxito

- [ ] Paso 1: explicas por qué `EDITOR=nano` da `emacs` y `EDITOR=vi` da `vi`, y por qué `VISUAL` gana
- [ ] Paso 2: `env -u VISUAL EDITOR=nano tmux -L lab -f starter/tmux.conf new -d \; show -gwv mode-keys` imprime `vi`
- [ ] Paso 4: `tmux -L lab show -gv history-limit` imprime `50000` y explicas por qué el primer panel seguía en `2000`
- [ ] Paso 4: en la ventana nueva, `g` en copy mode llega a la línea de encima de `1`
- [ ] Paso 5: `?` `999` `Enter`, `n`, `n`, `N` te llevan a `4999`, `3999`, `2999`, `3999`
- [ ] Paso 6: tras `clear -x`, el historial sigue; tras `clear-history` (o `clear`), `#{history_size}` vale `0`

## Reto extra

Haz que `prefix` `/` entre en copy mode y abra directamente la búsqueda hacia
arriba. Añade al starter:
```tmux
bind / copy-mode \; command-prompt -T search -p "(buscar)" { send -X search-backward "%%" }
```
Recarga, pulsa `C-b` `/`, escribe `4242` y `Enter`. ¿Por qué `send -X` no
lleva `-t`? ¿A qué panel llega?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Seleccionar y copiar](../lab-02-seleccionar-y-copiar/README.md) → |

[↑ Semana 04](../../README.md)
