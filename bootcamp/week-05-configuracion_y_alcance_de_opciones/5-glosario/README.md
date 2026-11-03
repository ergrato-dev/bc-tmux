# Glosario — Semana 05

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **XDG** | Convención que guarda la config en `~/.config/` en lugar de un archivo oculto en `~` | `~/.config/tmux/tmux.conf` |
| **config_files** | Formato con los archivos de config que cargó el servidor al arrancar | `display -p '#{config_files}'` |
| **source-file** | Ejecuta un archivo de config sobre el estado actual del servidor | `source-file -F "#{@kit-dir}/tmux.conf"` |
| **recarga idempotente** | Recargar la config una vez o diez deja el mismo estado | `set -gu` antes de `set -ga` |
| **send-prefix** | Envía el prefix al programa del panel en lugar de usarlo | `bind C-a send-prefix` |
| **prefix2** | Segundo prefix opcional, útil durante una transición | `set -g prefix2 C-b` |
| **opción de servidor** | Un único valor para todo el servidor, sin herencia | `set -s escape-time 10` |
| **opción de sesión** | Vale para una sesión; si no tiene valor, hereda el global | `set -g base-index 1` |
| **opción de ventana** | Vale para una ventana y sus paneles; hereda el global de ventana | `setw -g mode-keys vi` |
| **opción de panel** | Una opción de ventana fijada solo en un panel | `set -p -t api:1.2 remain-on-exit on` |
| **herencia** | Sin valor propio, un nivel usa el del nivel superior | `show -A` marca lo heredado con `*` |
| **opción de usuario** | Opción que empieza por `@`: no hace nada, guarda datos | `set -gF @kit-dir "#{d:current_file}"` |
| **current_file** | Formato con el archivo de config que se está leyendo; solo existe mientras se lee | `#{d:current_file}` |
| **escape-time** | Cuánto espera tmux tras un `Esc` por si empieza una secuencia de teclas | `set -s escape-time 10` |
| **%if** | Condicional que se evalúa al leer la config, sin lanzar una shell | `%if "#{>=:#{version},3.5}"` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 06 — Key bindings, tablas y navegación](../../week-06-key_bindings_tablas_y_navegacion/README.md) → |

[↑ Semana 05](../README.md)
