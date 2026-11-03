# Contexto — Ventanas y paneles

## ¿Por qué importa esto?

Una ventana es una pantalla; un panel, un trozo de ella con su propio programa. Con dos o tres paneles bien puestos ves el editor, los tests y los logs a la vez sin cambiar de pestaña. Pero el valor real está en hacerlo **reproducible**: si sabes qué comando hay detrás de cada atajo y cómo apuntar a cada panel, tu entorno de trabajo se monta solo. Esta semana aprendes las piezas; el proyecto las convierte en un script.

## Referencia rápida

| Atajo | Comando | Qué hace |
|---|---|---|
| `prefix` `%` | `split-window -h` | Parte a lo ancho: un panel al lado del otro |
| `prefix` `"` | `split-window` | Parte a lo alto: uno encima del otro |
| `prefix` flechas | `select-pane -L/-R/-U/-D` | Panel en esa dirección (repetible) |
| `prefix` `;` | `last-pane` | Último panel visitado |
| `prefix` `q` | `display-panes` | Números en pantalla; pulsa uno para ir |
| `prefix` `Ctrl`+flecha | `resize-pane -L/-R/-U/-D` | Mueve el borde 1 celda (repetible) |
| `prefix` `Alt`+flecha | `resize-pane ... 5` | Mueve el borde 5 celdas |
| `prefix` `z` | `resize-pane -Z` | Zoom: el panel ocupa toda la ventana |
| `prefix` `x` | `kill-pane` | Cierra el panel (pide confirmación) |
| `prefix` `c` / `&` | `new-window` / `kill-window` | Crea / cierra una ventana |

Las teclas **repetibles** aceptan pulsaciones seguidas sin volver a pulsar el prefix durante medio segundo (`repeat-time`).

## Lo que los atajos no te dicen

**Un panel nuevo no hereda el directorio del panel que partes.** Con el teclado empieza donde se creó la sesión; desde la línea de comandos, en el directorio de la shell que ejecuta `tmux`. Para elegirlo: `split-window -c '#{pane_current_path}'` (el del panel actual) o `-c /ruta`.

**Medidas exactas.** `resize-pane -x 30` deja el panel en 30 columnas; `-x 30%`, en el 30 % de la ventana. Igual con `-y` para el alto. `split-window -l 30%` crea el panel ya con ese tamaño.

**Ids, no índices.** Los índices de panel (`api:0.1`) se renumeran al crear, cerrar o mover paneles. El id (`%7`) no cambia mientras el panel exista. Cada comando que crea un panel puede devolverte su id:

```bash
editor=$(tmux new-session -d -P -F '#{pane_id}' -s api)
shell=$(tmux split-window -d -h -P -F '#{pane_id}' -t "$editor")
tmux select-pane -t "$shell" -T shell
```

`-d` evita que el panel nuevo se vuelva el activo: así el foco no cambia mientras el script trabaja.

**Siempre `-t` en un script.** Sin `-t`, un comando lanzado desde dentro de tmux actúa sobre **la sesión desde la que se ejecuta** (la de `$TMUX`) y su panel activo; desde fuera, sobre la sesión usada más recientemente. Ninguno de los dos es, normalmente, el que quieres.

**Títulos.** `select-pane -T nombre` pone el título de un panel (`#{pane_title}`). Con `set -w pane-border-status top` se ve en el borde.

## Ejemplo mínimo

```bash
tmux -L demo new-session -d -s demo -x 120 -y 30
tmux -L demo split-window -h -l 40% -t demo -c /tmp
tmux -L demo split-window -v -t demo:0.1
tmux -L demo list-panes -t demo -F '#{pane_index} #{pane_id} #{pane_width}x#{pane_height} #{pane_current_path}'
tmux -L demo resize-pane -Z -t demo:0.0
tmux -L demo display-message -p -t demo '#{window_zoomed_flag}'
tmux -L demo kill-server
```

## Qué observar cuando lo ejecutes

- El panel 1 mide unas 48 columnas (el 40 % de 120) y empieza en `/tmp`; el 2, creado sin `-c`, en el directorio desde el que ejecutaste el comando.
- Los índices son 0, 1 y 2 en orden de posición; los ids, en orden de creación.
- `window_zoomed_flag` imprime `1`: el panel 0 está ampliado y los otros dos siguen vivos, ocultos.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Semana 02 — Ventanas y paneles](../README.md) | [Teoría — Contexto — Layouts y reorganización](02-layouts-y-reorganizacion.md) → |

[↑ Semana 02](../README.md)
