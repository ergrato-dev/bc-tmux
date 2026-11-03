# Glosario — Semana 09

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **sesión desconectada** | Sesión creada sin cliente, para que un script siga sin necesitar terminal | `new-session -d -s api` |
| **`-P -F`** | Imprime el objeto recién creado con el format que pidas, para guardarlo en una variable | `new-window -P -F '#{pane_id}'` |
| **id de panel** | Identificador `%N` que no cambia aunque muevas, renombres o renumeres la ventana | `send-keys -t %3 Enter` |
| **target exacto** | `=` delante del nombre: casa solo con esa sesión, no con las que empiezan igual | `has-session -t "=api"` |
| **filtro `-f`** | Format que vale 1 o 0 y decide qué líneas imprime un `list-*` | `list-windows -f '#{==:#{window_name},logs}'` |
| **cadena de comandos** | Varios comandos separados por `\;` en una sola invocación de tmux | `new-session -d \; new-window -n run` |
| **`send-keys -l`** | Envía el texto literal: ningún argumento se interpreta como nombre de tecla | `send-keys -t %1 -l -- "$line"` |
| **inyección por send-keys** | Texto externo que la shell del panel ejecuta porque nadie lo escapó | `f='a;touch PWNED'` |
| **`%q`** | Formato de `printf` que escapa un valor para que la shell lo lea como una sola palabra | `printf -v line 'tail -- %q' "$f"` |
| **`respawn-pane -k`** | Mata lo que corre en un panel y arranca un proceso nuevo en el mismo `%id` | `respawn-pane -k -t %1` |
| **`remain-on-exit`** | Deja el panel abierto y muerto cuando su proceso termina, con su código en `#{pane_dead_status}` | `set -g remain-on-exit on` |
| **`wait-for`** | Bloquea hasta que otro comando envía la señal del mismo canal con `-S`; la señal temprana queda guardada | `wait-for hecho` · `wait-for -S hecho` |
| **`timeout`** | Programa que corta un comando tras N segundos y sale con 124 | `timeout 30 tmux wait-for hecho` |
| **idempotencia** | Propiedad de un script que deja lo mismo tras una ejecución que tras diez | `has-session -t "=api" \|\| new-session -d -s api` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 10 — Hooks, popups y menús](../../week-10-hooks_popups_y_menus/README.md) → |

[↑ Semana 09](../README.md)
