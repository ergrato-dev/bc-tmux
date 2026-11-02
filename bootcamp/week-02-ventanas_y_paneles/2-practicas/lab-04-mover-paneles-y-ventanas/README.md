# Lab 04 — Mover paneles y ventanas

⏱ Duración estimada: ~60 min

## Objetivo

Sacar un panel a su propia ventana, meterlo en otra, e intercambiar paneles y ventanas sin cerrar ningún programa.

## Contexto

- Un panel no está atado a su ventana: puedes **sacarlo** (`break-pane`) a una ventana nueva o **unirlo** (`join-pane`) a otra ventana. El programa sigue corriendo durante el viaje.
- `swap-pane` intercambia dos paneles de sitio; `rotate-window` los gira todos. `swap-window` y `move-window` hacen lo mismo con ventanas.
- `join-pane -s ORIGEN -t DESTINO`: `-s` (source) es lo que mueves, `-t` (target) es dónde lo pones.

## Instrucciones

1. Prepara dos ventanas con un programa en cada una:
   ```bash
   tmux -L lab new -s mover -n codigo \; send-keys 'top' Enter \; new-window -n logs \; send-keys 'n=0; while sleep 1; do n=$((n+1)); echo "paso $n"; done' Enter
   ```

2. **Unir.** Mete el panel de `logs` en la ventana `codigo`, a la derecha:
   ```bash
   tmux -L lab join-pane -h -s mover:logs -t mover:codigo
   ```
   La ventana `logs` desaparece (se quedó sin paneles) y `codigo` tiene ahora
   `top` y el contador, que **no se reinició**: sigue en el número donde iba.

3. **Sacar.** Ve al panel del contador y pulsa `prefix` `!`. El panel se va a una
   ventana nueva para él solo. Renómbrala a `logs` con `prefix` `,`.

4. **Marcar y unir con el teclado.** En `logs`, pulsa `prefix` `m`: el panel
   queda **marcado** (borde resaltado). Ve a `codigo` y ejecuta en el prompt
   (`prefix` `:`) `join-pane -h`. Sin `-s`, `join-pane` usa el panel marcado.

5. **Intercambiar.** Con dos paneles en `codigo`:

   | Teclas | Qué hace |
   |---|---|
   | `prefix` `{` / `prefix` `}` | Intercambia el panel activo con el anterior / el siguiente |
   | `prefix` `Ctrl`+`o` | Gira todos los paneles una posición |
   | `prefix` `.` | Mueve la ventana a otro índice (te pide el destino) |
   | `prefix` `<` | Menú de la ventana: intercambiar a izquierda o derecha, renombrar, matar |

   Fíjate en que los **ids** (`#{pane_id}`) viajan con cada panel y los
   **índices** se recalculan según la posición:
   ```bash
   tmux -L lab list-panes -t mover:codigo -F '#{pane_index} #{pane_id} #{pane_current_command}'
   ```

6. Completa `starter/reorganizar.sh`: une el panel de la ventana `logs` a la
   derecha de `codigo`, imprime cuántos paneles tiene `codigo`, y después lo
   devuelve a una ventana propia llamada `logs`. Usa el id del panel, que es
   lo único que no cambia durante el viaje.
   ```bash
   tmux -L lab kill-server
   tmux -L lab new -d -s mover -n codigo \; new-window -d -n logs
   ./starter/reorganizar.sh
   ```
   ```
   codigo tiene 2 paneles
   ventanas: codigo logs
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] El contador sobrevive a `join-pane` y a `break-pane` sin reiniciarse
- [ ] Usaste `prefix` `m` para marcar un panel y unirlo con `join-pane` sin `-s`
- [ ] Explicas por qué el id de un panel no cambia al moverlo y su índice sí
- [ ] `./starter/reorganizar.sh` imprime las dos líneas del paso 6

## Reto extra

`break-pane -d -n nombre` saca el panel sin cambiar tu foco. ¿Para qué te
serviría en un script que reorganiza la ventana de otra persona en pair
programming?
