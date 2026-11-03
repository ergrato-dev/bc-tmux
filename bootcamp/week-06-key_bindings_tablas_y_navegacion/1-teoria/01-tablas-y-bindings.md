# Contexto — Tablas de teclas y bindings

## ¿Por qué importa esto?

Cada tecla que pulsas pasa primero por tmux: o la usa él, o se la entrega al programa del panel. Esta semana decides qué teclas quieres, cuáles sobran y cuáles les quitas a los programas. Un `bind` mal puesto no da error: pisa en silencio otra tecla, roba una que tu shell necesitaba o se repite cuando no querías. Saber en qué tabla se busca cada tecla te permite depurarlo.

## Tablas de teclas

Cada cliente tiene una tabla activa, `#{client_key_table}`, y tmux busca la tecla solo en ella:

| Tabla | Cuándo está activa | Se llena con |
|---|---|---|
| `root` | Siempre, por defecto | `bind -n` |
| `prefix` | Para la tecla que sigue al prefix | `bind` |
| `copy-mode-vi` | En copy mode con `mode-keys vi` | `bind -T copy-mode-vi` |
| una tuya (`resize`) | Tras `switch-client -T resize`, para una tecla | `bind -T resize` |

![Recorrido de una tecla: el cliente parte de root; el prefix lo lleva a prefix, prefix R a la tabla resize; h ejecuta su comando y vuelve a entrar en resize; Escape o una tecla que la tabla no tiene lo devuelven a root, y si root tampoco la tiene llega al programa del panel](../0-assets/01-recorrido-de-una-tecla.svg)

Después de esa tecla el cliente vuelve a `root`. Para quedarte en una tabla propia, el binding vuelve a entrar: `{ resize-pane -L 5; switch-client -T resize }`. Una tecla que la tabla no tiene te devuelve a `root` y se busca allí; si tampoco está, llega al programa del panel.

## Referencia rápida

| Comando | Qué hace |
|---|---|
| `bind x cmd` | Lo mismo que `bind -T prefix x cmd` |
| `bind -n x cmd` | `-T root`: sin prefix. `x` ya no llega a ningún programa |
| `bind -r x cmd` | Repetible: durante `repeat-time` (500 ms) pulsas `x` otra vez sin prefix |
| `bind -N "nota" x cmd` | Documenta la tecla: la muestran `list-keys -N` y `prefix` `?` |
| `unbind x` · `unbind -n x` | Quita `x` de `prefix` · de `root` |
| `unbind -a -T resize` | Vacía la tabla entera |
| `list-keys -T prefix x` | Qué hace `x`, tal como lo guardó tmux |
| `list-keys -N` | Solo las teclas con nota |
| `{ cmd1; cmd2 }` | Varios comandos en un binding, sin escapar `\;` |

Tres reglas que no avisan:

- Un `bind` posterior sobre la misma tecla pisa al anterior, **nota incluida**. Con `conf.d/`, gana el último módulo cargado.
- `unbind x` sin `-n` ni `-T` busca solo en `prefix`: no quita un `bind -n x`.
- `-r` sirve para teclas de movimiento. Con `bind -r n next-window`, si escribes `n` en la shell justo después de `prefix` `n`, cambias otra vez de ventana en lugar de escribir la letra.

## Ejemplo mínimo funcional

```bash
cat > /tmp/demo.conf <<'EOF'
# demo.conf: una tabla propia para redimensionar
set -g status-right "tabla: #{client_key_table} "
bind -N "demo: modo resize" R switch-client -T resize
bind -T resize h { resize-pane -L 5; switch-client -T resize }
bind -T resize l { resize-pane -R 5; switch-client -T resize }
bind -T resize Escape switch-client -T root
EOF
tmux -L demo -f /tmp/demo.conf new -s demo \; split-window -h
```

Dentro (con esta config el prefix es `C-b`): `prefix` `R`, luego `h` cuatro veces y `Escape`. Desde otra terminal:

```bash
tmux -L demo list-keys -T resize
tmux -L demo list-keys -N | grep demo
tmux -L demo kill-server
```

## Qué observar

- Tras `prefix` `R` la barra dice `tabla: resize`, y cada `h` mueve el borde a la izquierda sin repetir el prefix.
- `Escape`, o cualquier tecla que `resize` no tiene, devuelve la barra a `tabla: root`.
- `list-keys -T resize` muestra el bloque `{ }` como `resize-pane -L 5 \; switch-client -T resize`.
- `prefix` `?` muestra `demo: modo resize` junto a las notas de serie.

---
Listo. Ve al [lab-01](../2-practicas/lab-01-bind-unbind-y-list-keys/README.md) y ponlo en práctica.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Semana 06 — Key bindings, tablas y navegación](../README.md) | [Teoría — Contexto — Teclas que deciden: navegación entre paneles y programas](02-teclas-que-deciden.md) → |

[↑ Semana 06](../README.md)
