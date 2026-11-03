# Glosario — Semana 12

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **`new -A`** | Se conecta a la sesión si existe y la crea si no: el mismo comando sirve para entrar y para volver | `ssh -t build-01 tmux new -A -s main` |
| **mosh** | Sustituto de ssh por UDP que sobrevive a cambios de IP y a la suspensión; no sustituye a tmux | `mosh build-01 -- tmux new -A -s main` |
| **tmux anidado** | Un tmux dentro de un panel de otro, casi siempre por SSH: toda tecla pasa primero por el de fuera | `tmux -L fuera` > `ssh` > `tmux` |
| **`send-prefix`** | Escribe el prefix en el panel en vez de interpretarlo, para que le llegue al tmux de dentro | `bind C-a send-prefix` |
| **`key-table`** | Opción de sesión con la tabla en la que empieza cada tecla; `off` en el toggle de anidado | `set key-table off` |
| **`set -u`** | Borra el valor propio de la sesión y vuelve a heredar el global | `set -u prefix` |
| **`-S`** | Ruta completa del socket del servidor, necesaria para compartirlo con otro usuario | `tmux -S /tmp/kit-pair-alumno/pair new -d -s pair` |
| **`server-access`** | Lista de usuarios que el servidor deja conectarse, con escritura (W) o solo lectura (R) | `server-access -a -r invitado` |
| **cliente de solo lectura** | Cliente que ve la sesión pero no puede ejecutar comandos ni escribir: `client is read-only` | `#{client_readonly}` → `1` |
| **`attach -r`** | Solo lectura que elige quien se conecta; con (W) la puede deshacer, así que no protege | `tmux -S S attach -r -t pair` |
| **grupo de sesiones** | Sesiones que comparten ventanas, cada una con su ventana actual | `new -d -t pair -s lucia` |
| **control mode** | Modo `-C` en el que tmux habla un protocolo de texto en vez de dibujar la pantalla | `tmux -C attach -t =cm` |
| **`%begin`/`%end`** | Marcan la respuesta a un comando en control mode; `%error` si falla | `%begin 1793743330 274 1` |
| **notificación** | Línea `%` que tmux emite sola en control mode cuando algo cambia | `%window-add @1` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | [Semana 13 — Proyecto integrador](../../week-13-proyecto_integrador/README.md) → |

[↑ Semana 12](../README.md)
