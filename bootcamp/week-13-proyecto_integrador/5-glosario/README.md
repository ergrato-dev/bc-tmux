# Glosario — Semana 13

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **enlace simbólico** | Archivo que apunta a otra ruta; instalar el kit es crear uno en `~/.config/tmux` | `ln -sfn ~/tmux-kit ~/.config/tmux` |
| **`ln -sfn`** | Crea o sustituye un enlace sin entrar en el directorio al que apunta el enlace existente | `ln -sfn "$KIT" "$DEST"` |
| **`readlink`** | Imprime adónde apunta un enlace, sin seguirlo más allá | `readlink ~/.config/tmux` |
| **`pwd -P`** | Directorio actual con los enlaces resueltos; portable a macOS, a diferencia de `readlink -f` | `KIT=$(cd "$(dirname "$0")" && pwd -P)` |
| **`XDG_CONFIG_HOME`** | Variable con el directorio de configuración del usuario; si no existe, `~/.config` | `${XDG_CONFIG_HOME:-$HOME/.config}/tmux` |
| **`config_files`** | Formato con los archivos de config que tmux cargó al arrancar, separados por comas | `display -p '#{config_files}'` |
| **backup con fecha** | Copia apartada de la config previa cuyo nombre ordena por antigüedad y nunca se pisa | `tmux.bak.20261103-231312` |
| **idempotente** | Ejecutarlo dos veces deja el mismo resultado que una, y la segunda no cambia nada | `./install.sh; ./install.sh` |
| **`--dry-run`** | Modo ensayo: imprime las acciones que haría sin ejecutar ninguna | `./install.sh --dry-run` |
| **código de salida** | Número con el que acaba un programa: 0 bien, 1 fallo, 2 uso incorrecto | `./install.sh --nope; echo $?` → `2` |
| **check propio** | Comprobación del kit que lanzas tú, sobre un servidor y un HOME aislados | `tests/run` |
| **prueba de mutación** | Romper el código a propósito para comprobar que el check falla | prefix `C-b` en una copia → ❌ |
| **`trap ... EXIT`** | Código que bash ejecuta al salir el script, por la razón que sea | `trap 'tmux -L "$S" kill-server' EXIT` |
| **`show-messages`** | Registro de mensajes y errores del servidor tmux, consultable desde un cliente | `prefix` `~` |

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Recursos — web](../4-recursos/webgrafia/README.md) | — |

[↑ Semana 13](../README.md)
