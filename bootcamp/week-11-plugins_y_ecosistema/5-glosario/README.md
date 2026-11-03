# Glosario — Semana 11

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **plugin** | Repositorio con un ejecutable `*.tmux` que configura tmux llamando a `tmux set` y `tmux bind` | `run-shell ~/src/zoom-flag/zoom-flag.tmux` |
| **TPM** | Tmux Plugin Manager: clona los plugins declarados y ejecuta su `*.tmux` al cargar la config | `run-shell '~/.config/tmux/plugins/tpm/tpm'` |
| **`@plugin`** | Línea que TPM busca en el texto de tus archivos; para tmux, una opción que solo guarda la última | `set -g @plugin 'tmux-plugins/tmux-resurrect#v4.0.0'` |
| **`@tpm_plugins`** | Lista de plugins separada por espacios que TPM lee del servidor, no de los archivos | `set -g @tpm_plugins 'tmux-plugins/tpm#v3.1.0'` |
| **fijar por tag** | Añadir `#tag` al plugin para que todas las máquinas clonen la misma versión | `usuario/repo#v3.1.0` |
| **`TMUX_PLUGIN_MANAGER_PATH`** | Variable del entorno global de tmux con la carpeta donde TPM instala (con barra final) | `setenv -g TMUX_PLUGIN_MANAGER_PATH ~/kit/plugins/` |
| **`show -gqv`** | Lee el valor de una opción global; vacío y sin error si no existe | `tmux show -gqv @kit-sessions-label` |
| **valor por defecto** | Valor que el plugin pone a su opción solo si el usuario no la fijó antes de cargarlo | `[ -n "$(tmux show -gqv @x)" ] \|\| tmux set -g @x on` |
| **marcador** | Texto propio en un format (`#{nombre}`) que el plugin sustituye al cargarse | `#{kit_sessions}` → `#{server_sessions} ses` |
| **interpolación** | Sustituir un marcador de `status-right` por un `#(script)` o un format real | `#{cpu_percentage}` → `#(.../cpu.sh)` |
| **tmux-resurrect** | Plugin que guarda sesiones, ventanas, paneles y directorios en un archivo y las recrea | `prefix` `C-s` guarda, `prefix` `C-r` restaura |
| **tmux-continuum** | Plugin que llama a resurrect cada N minutos desde la status line y restaura al arrancar | `set -g @continuum-restore on` |
| **tmuxp** | Gestor en Python que crea sesiones desde un YAML y congela una sesión viva en uno | `tmuxp load -d api.yaml` |
| **sesh** | Gestor de sesiones en Go que, con fzf, abre sesiones y directorios por nombre | `sesh connect ~/src/api` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 12 — Remoto, colaboración y control mode](../../week-12-remoto_colaboracion_y_control_mode/README.md) → |

[↑ Semana 11](../README.md)
