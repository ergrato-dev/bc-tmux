# Glosario — Semana 10

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **hook** | Comando que tmux ejecuta solo cuando ocurre un evento o termina un comando | `set-hook -g client-attached 'display "hola"'` |
| **índice fijo** | Entrada concreta de la lista de un hook; recargar la sustituye en vez de añadir otra | `set-hook -g 'after-new-window[10]' 'cmd'` |
| **`set-hook -a`** | Añade una entrada al final de la lista: recargar la config la duplica | `set-hook -ga after-new-window 'cmd'` |
| **`after-<comando>`** | Hook que corre justo después de ese comando, sobre el objeto que creó | `after-split-window` · `#{pane_id}` es el panel nuevo |
| **`#{hook_session_name}`** | Format con la sesión del evento en `session-created` | `set -gF @last "#{hook_session_name}"` |
| **popup** | Terminal flotante sobre el cliente con un comando dentro; no es un panel | `display-popup -E -w 80% -h 80% top` |
| **`-E` / `-EE`** | Cierra el popup al terminar su comando / solo si sale con 0 | `display-popup -EE ./bin/script` |
| **menú** | Lista de entradas `nombre tecla comando` que tmux dibuja sobre el cliente | `display-menu 'Nueva' n new-window` |
| **separador** | Entrada vacía de un menú, que dibuja una línea | `display-menu 'A' a cmd '' 'B' b cmd` |
| **`%%`** | Hueco de la plantilla de `command-prompt` donde va lo que escribiste | `command-prompt { rename-window "%%" }` |
| **inyección por prompt** | Lo escrito en un prompt se ejecuta como comando porque la plantilla era texto, no llaves | `command-prompt "rename-window '%%'"` |
| **`confirm-before`** | Pide `y` antes de ejecutar un comando | `confirm-before -p 'cerrar? (y/n)' kill-session` |
| **`run-shell`** | Ejecuta una shell desde el servidor; sin `-b` bloquea al cliente hasta que termina | `run-shell -b 'sleep 3'` |
| **view-mode** | Modo en que tmux muestra la salida de `run-shell` sobre el panel; `q` lo cierra | `run-shell 'exit 3'` |
| **`pipe-pane -o`** | Abre un pipe con la salida del panel o lo cierra si ya había uno | `pipe-pane -o 'cat >> /tmp/x.log'` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 11 — Plugins y ecosistema](../../week-11-plugins_y_ecosistema/README.md) → |

[↑ Semana 10](../README.md)
