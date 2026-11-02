# Lab 01 — Moverte por el historial

⏱ Duración estimada: ~60 min

## Objetivo

Recorrer, buscar y limpiar el historial de un panel con copy mode y las teclas de vi, fijando `mode-keys` y `history-limit` en tu config.

## Contexto

- El historial de cada panel lo guarda tmux, no tu terminal: la rueda o `Shift+PgUp` de la terminal no llegan a él. Se recorre en **copy mode** (`prefix` `[`).
- `mode-keys` decide si copy mode usa teclas de vi o de emacs. Si no lo fijas, tmux lo deduce de `$EDITOR` al arrancar el servidor.
- `history-limit` se aplica al **crear** un panel; cambiarlo no amplía los que ya existen.

## Instrucciones

1. **tmux adivina.** Arranca dos servidores sin config, con editores distintos:
   ```bash
   EDITOR=nano tmux -L lab -f /dev/null new -d \; show -gwv mode-keys
   tmux -L lab kill-server
   EDITOR=nvim tmux -L lab -f /dev/null new -d \; show -gwv mode-keys
   tmux -L lab kill-server
   ```
   ```
   emacs
   vi
   ```
   La misma config, en un servidor sin `EDITOR`, te deja sin `/`, `n` ni `v`.

2. Resuelve el `TODO 1` de `starter/tmux.conf` y comprueba que ya no depende
   del entorno:
   ```bash
   EDITOR=nano tmux -L lab -f starter/tmux.conf new -d \; show -gwv mode-keys
   ```
   ```
   vi
   ```

3. **El historial se acaba.** Conéctate y llena el panel:
   ```bash
   tmux -L lab attach
   seq 1 5000
   ```
   Entra en copy mode con `prefix` `[` y pulsa `g` (principio del historial).
   La primera línea no es `1`: es un número cercano a `3000`. Arriba a la
   derecha, algo como `[1982/1982]` dice en qué línea del historial estás y
   cuántas guarda el panel: no más de 2000. Sal con `q`.

4. Resuelve el `TODO 2`, recarga la config y repite en el **mismo** panel:
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab display -p '#{history_limit}'     # 2000: el panel no cambió
   ```
   Abre una ventana nueva (`prefix` `c`), repite `seq 1 5000` y `g` en copy
   mode: ahora sí llegas a `1`.
   ```bash
   tmux -L lab display -p '#{history_limit} #{history_size}'
   ```
   ```
   50000 4982
   ```
   (`history_size` depende de la altura de tu panel: es lo que no cabe en
   pantalla.)

5. **Muévete y busca** en la ventana nueva. En copy mode:

   | Prueba | Teclas | Dónde acabas |
   |---|---|---|
   | Buscar hacia arriba | `?` `4242` `Enter` | En la línea `4242` |
   | Siguiente coincidencia | `?` `42` `Enter`, luego `n` varias veces | `4242`, `4142`... hacia arriba |
   | Volver hacia abajo | `N` | La coincidencia anterior |
   | Media página | `C-u` / `C-d` | 50% de la pantalla arriba / abajo |
   | Arriba, medio, abajo | `H` / `M` / `L` | Primera, central o última línea visible |
   | Principio y final | `g` / `G` | Línea `1` / la del prompt |

   Sal con `q`. Entra con `prefix` `PgUp`: copy mode empieza ya una página
   arriba.

6. **Limpiar el historial.** `clear` limpia la pantalla, pero no el historial:
   ```bash
   clear
   tmux -L lab display -p '#{history_size}'      # sigue en miles
   tmux -L lab clear-history
   tmux -L lab display -p '#{history_size}'
   ```
   ```
   0
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] `EDITOR=nano tmux -L lab -f starter/tmux.conf new -d \; show -gwv mode-keys` imprime `vi`
- [ ] `tmux -L lab show -gv history-limit` imprime `50000`
- [ ] Explicas por qué el panel del paso 4 seguía con `2000` tras recargar
- [ ] En una ventana nueva, tras `seq 1 5000`, `g` en copy mode llega a la línea `1`
- [ ] Encuentras `4242` con `?` en menos de cinco teclas
- [ ] Tras `clear-history`, `#{history_size}` vale `0`

## Reto extra

Haz que `prefix` `/` entre en copy mode y abra directamente la búsqueda hacia
arriba:
```tmux
bind / copy-mode \; command-prompt -T search -p "(buscar)" { send -X search-backward "%%" }
```
¿Por qué `send -X` no lleva `-t`? ¿A qué panel llega?
