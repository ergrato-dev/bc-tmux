# Contexto — Status line

## ¿Por qué importa esto?

La barra es el único sitio donde tmux te enseña su estado sin que preguntes: prefix pulsado, modo resize, zoom, paneles sincronizados, la rama del proyecto. Con formats y estilos la construyes tú, sin plugins, y sabes lo que cuesta cada pieza: un `#{}` es gratis, un `#()` lanza un proceso cada pocos segundos.

## Cómo se compone la barra

`status-format[0]` (déjalo como viene) junta tres zonas. Cada una tiene su opción de contenido y su opción de estilo:

![Composición de la barra: status-left a la izquierda, la lista de ventanas en el centro y status-right a la derecha; cada ventana se dibuja con window-status-format, la actual con window-status-current-format, separadas por window-status-separator; debajo, las opciones de estilo que pintan cada zona](../0-assets/02-composicion-de-la-barra.svg)

`status-left-length` y `status-right-length` cortan su zona (10 y 40 caracteres de serie): una sesión con nombre largo desaparece a medias sin avisar.

## Referencia rápida

| Pieza | Qué hace |
|---|---|
| `#[fg=red,bg=#161b22,bold]` | Cambia el estilo desde ese punto |
| `#[default]` | Vuelve al estilo de la zona |
| `status-style` | Fondo y texto de toda la barra |
| `window-status-style` · `window-status-current-style` | Ventanas · ventana actual |
| `message-style` | Mensajes de `display` y el prompt de `:` |
| `pane-active-border-style` | Borde del panel activo |
| `window-status-separator` | Texto entre ventanas (un espacio de serie) |
| `#(comando)` | Primera línea de la salida, en segundo plano |
| `status-interval 5` | Redibuja y relanza los `#()` cada 5 segundos (15 de serie) |
| `%H:%M` | Hora con strftime; `%%` es un `%` literal |
| `status 2` + `status-format[1]` | Una segunda línea de barra |

Reglas que no avisan:

- Las opciones `*-style` aceptan formats y se evalúan al dibujar: con `status-style 'bg=#{@c-bg}'`, cambiar `@c-bg` cambia la barra. Un color inválido dentro de `@c-bg` no da error en el `set`; solo se nota en la barra.
- Dentro de un `#{?...}`, la coma de un estilo también corta la rama: `#{?client_prefix,#[fg=red#,bold]P,}`.
- `#()` nunca bloquea: la barra muestra la última salida hasta que termina la siguiente, así que un comando lento enseña datos viejos. `display -p` no lo ejecuta nunca: para comprobarlo hay que mirar la barra.
- Los `#{}` de dentro de `#()` se expanden antes de llamar a la shell. Cítalos con `q:`: `#(git -C #{q:pane_current_path} branch --show-current)`.
- `client_prefix` vale 1 en cualquier tabla distinta de `root`, también en una propia como `kit-resize`.

## Ejemplo mínimo funcional

```bash
cat > /tmp/demo.conf <<'EOF'
set -g @c-bg     '#161b22'
set -g @c-accent '#3fb950'
set -g @c-alert  '#f85149'
set -g status-interval 5
set -g status-style 'bg=#{@c-bg},fg=#8b949e'
set -g status-left-length 30
set -g status-left '#[fg=#{@c-bg},bg=#{?client_prefix,#{@c-alert},#{@c-accent}}] #{=20:session_name} #[default] '
set -g window-status-format ' #{window_index}:#{window_name}#{?window_zoomed_flag, ZOOM,} '
set -g window-status-current-format ' #{window_index}:#{window_name}#{?window_zoomed_flag, ZOOM,} '
set -g window-status-current-style 'fg=#f0f6fc,bold'
set -g window-status-separator ''
set -g status-right '#{?client_prefix,#[fg=#{@c-alert}#,bold]PREFIX#[default] ,}seg #(date +%%S) %H:%M '
EOF
tmux -L demo -f /tmp/demo.conf new -s demo \; split-window -h
```

Desde otra terminal, con la barra a la vista:

```bash
tmux -L demo set -g @c-accent '#d2a8ff'
tmux -L demo display -p '#{E:status-left}'
tmux -L demo kill-server   # antes, quita el zoom si lo dejaste: tmux 3.4 puede fallar al salir
```

## Qué observar

- `seg` avanza a saltos de unos 5 segundos aunque `%H:%M` se redibuje antes: es `status-interval`.
- Al pulsar `prefix` (`C-b` con esta config) la sesión se pone roja y aparece `PREFIX` en negrita; sin `#,` aparecería `bold]PREFIX` como texto.
- `prefix` `z` añade ` ZOOM` a la ventana actual.
- Cambiar `@c-accent` repinta la sesión sin tocar `status-left`.
- `display -p '#{E:status-left}'` imprime los `#[...]` como texto: así lees lo que la barra va a dibujar.

---
Listo. Ve al [lab-04](../2-practicas/lab-04-estilos-y-ventanas/README.md) y ponlo en práctica.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Formats](01-formats.md) | [Índice de labs](../2-practicas/README.md) → |

[↑ Semana 07](../README.md)
