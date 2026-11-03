# Webgrafía — Semana 06

| Recurso | Descripción |
|---------|-------------|
| [tmux(1) — página de manual](https://man.openbsd.org/tmux.1) | Para esta semana: KEY BINDINGS (tablas `root`, `prefix`, `copy-mode-vi`), `bind-key` con `-n`, `-r`, `-N` y `-T`, `unbind-key`, `list-keys`, `switch-client -T`, `if-shell -F` y, en FORMATS, `alternate_on`, `client_key_table` y `selection_present` |
| [tmux wiki — Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started) | Secciones Key bindings (tablas de teclas, `list-keys`, `bind-key`) y Copy mode key bindings |
| [tmux wiki — Modifier Keys](https://github.com/tmux/tmux/wiki/Modifier-Keys) | Cómo llegan Ctrl, Alt y Shift a tmux, y `extended-keys`: por qué una combinación que asignas no siempre llega |
| [tmux wiki — FAQ](https://github.com/tmux/tmux/wiki/FAQ) | "Why is C-b the prefix key? How do I change it?" y "How do I make modified function and arrow keys (like C-Up, M-PageUp) work inside tmux?" |
| [mislav — tmux pane switching sin plugin (gist)](https://gist.github.com/mislav/5189704) | La versión clásica de `bind -n C-h` con `run-shell` y un script que mira el proceso del panel; en los comentarios, variantes con `pane_current_command` y `ps`. Útil para ver por qué esta semana se usa `if -F '#{alternate_on}'` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — videos](../videografia/README.md) | [Glosario](../../5-glosario/README.md) → |

[↑ Semana 06](../../README.md)
