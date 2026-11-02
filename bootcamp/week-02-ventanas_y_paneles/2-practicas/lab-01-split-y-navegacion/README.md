# Lab 01 — Partir y moverte entre paneles

⏱ Duración estimada: ~60 min

## Objetivo

Partir una ventana en paneles, moverte entre ellos sin ratón, abrir cada panel en el directorio correcto y ponerles título.

## Contexto

- `prefix` `%` parte **a lo ancho** (un panel al lado del otro) y `prefix` `"` parte **a lo alto** (uno encima del otro). Por debajo los dos son `split-window`, con `-h` o sin él.
- Un panel creado con el teclado empieza en el directorio donde se creó la **sesión**, no en el del panel que partes. Para heredar el directorio actual hay que pedirlo: `-c '#{pane_current_path}'`.
- `split-window -P -F '#{pane_id}'` imprime el id del panel que acaba de crear. Es la forma segura de seguir trabajando con él desde un script.

## Instrucciones

1. Abre una sesión: `tmux -L lab new -s paneles`.

2. Parte la ventana con `prefix` `%` y después con `prefix` `"`. Quedan tres
   paneles: uno a la izquierda y dos apilados a la derecha. Muévete:

   | Teclas | Qué hace |
   |---|---|
   | `prefix` flechas | Al panel de esa dirección (se puede repetir sin volver a pulsar el prefix durante medio segundo) |
   | `prefix` `o` | Al siguiente panel |
   | `prefix` `;` | Al último panel en el que estuviste |
   | `prefix` `q` | Muestra un número grande en cada panel; pulsa ese número para ir a él |

3. **El directorio.** En el panel activo haz `cd /tmp` y parte con `prefix` `%`.
   En el panel nuevo ejecuta `pwd`: no es `/tmp`, es el directorio donde
   creaste la sesión. Ahora ábrelo bien desde el prompt (`prefix` `:`):
   ```
   split-window -h -c "#{pane_current_path}"
   ```
   Este sí empieza en `/tmp`. En la semana 06 ligarás `%` y `"` a esta versión.

4. Cierra los paneles sobrantes con `prefix` `x` (confirma con `y`) o con
   `exit`, hasta quedarte con tres.

5. **Títulos.** Cada panel tiene un título (`#{pane_title}`), que por defecto
   es el nombre de la máquina. Ponle uno y haz que se vea en el borde:
   ```bash
   tmux -L lab select-pane -t paneles:0.0 -T editor
   tmux -L lab set -w -t paneles:0 pane-border-status top
   ```
   El borde superior de cada panel muestra ahora su número y su título.
   Titula los otros dos como `shell` y `logs`.

6. Completa `starter/tres.sh`: crea en segundo plano la sesión `tres` con tres
   paneles titulados `editor`, `shell` y `logs`, todos en el directorio que
   recibe como argumento, y termina listándolos. Usa los ids que devuelve
   `-P -F '#{pane_id}'`, nunca índices.
   ```bash
   tmux -L lab kill-server
   ./starter/tres.sh /tmp
   ```
   ```
   %0 editor /tmp
   %1 shell /tmp
   %2 logs /tmp
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Te mueves entre tres paneles con flechas, `o`, `;` y `q`
- [ ] Puedes mostrar que un `split-window` sin `-c` no hereda el directorio y uno con `-c '#{pane_current_path}'` sí
- [ ] Los títulos se ven en el borde con `pane-border-status top`
- [ ] `./starter/tres.sh /tmp` en un servidor vacío imprime las tres líneas del paso 6

## Reto extra

Cambia el texto del borde con
`set -w pane-border-format ' #{pane_index}: #{pane_title} (#{pane_current_command}) '`.
¿Qué pasa con el borde cuando ejecutas `top` en un panel?
