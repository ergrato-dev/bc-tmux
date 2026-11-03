# Glosario — Semana 02

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **split** | Partir un panel en dos, a lo ancho (`-h`) o a lo alto | `split-window -h -c '#{pane_current_path}'` |
| **celda** | Unidad de tamaño de tmux: una columna de ancho o una fila de alto | `resize-pane -x 30` |
| **zoom** | Ampliar un panel a toda la ventana sin cerrar los demás | `prefix` `z` |
| **layout** | Forma en que se reparten los paneles de una ventana | `select-layout tiled` |
| **panel principal** | El primer panel de la ventana, el grande en los layouts `main-*` | `set -w main-pane-width 60%` |
| **cadena de layout** | Texto con la suma de control, el tamaño y la posición de cada panel | `#{window_layout}` |
| **título de panel** | Nombre de un panel, visible en el borde con `pane-border-status` | `select-pane -T logs` |
| **break-pane** | Sacar un panel a una ventana nueva sin cerrar su programa | `prefix` `!` |
| **join-pane** | Meter un panel en otra ventana | `join-pane -h -s %2 -t codigo` |
| **panel marcado** | Panel señalado para que `join-pane` o `swap-pane` lo usen sin `-s` | `prefix` `m` |
| **swap-pane** | Intercambiar dos paneles de sitio | `prefix` `{` |
| **synchronize-panes** | Opción de ventana que envía lo que tecleas a todos sus paneles | `setw synchronize-panes on` |
| **teclas repetibles** | Ligaduras que aceptan pulsaciones seguidas sin repetir el prefix | `prefix` `Ctrl`+flecha |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 03 — Sesiones, targets y sockets](../../week-03-sesiones_targets_y_sockets/README.md) → |

[↑ Semana 02](../README.md)
