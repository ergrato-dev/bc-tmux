# Labs — Semana 09: Scripting de tmux desde shell

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-crear-sin-conectarse](lab-01-crear-sin-conectarse/) | `new-session -d`, `-c`, `-x`/`-y` y `-P -F` para crear una sesión entera desde un script y apuntar a sus paneles por id | ~60 min |
| 2 | [lab-02-consultar-con-formatos](lab-02-consultar-con-formatos/) | `list-* -F` y `-f`, bucles `while IFS= read -r` y por qué `display -p` no valida un target y `list-panes` sí | ~60 min |
| 3 | [lab-03-enviar-teclas-con-cuidado](lab-03-enviar-teclas-con-cuidado/) | `send-keys -l`, el `Enter` aparte, un nombre de archivo hostil escapado con `%q`, paneles ocupados y `respawn-pane` | ~60 min |
| 4 | [lab-04-esperar-con-wait-for](lab-04-esperar-con-wait-for/) | Esperar a que un comando termine en un panel con `wait-for` y `timeout`, y recuperar su código de salida | ~60 min |
| 5 | [lab-05-idempotencia](lab-05-idempotencia/) | Crear o reutilizar sesión y ventanas por nombre exacto: la segunda ejecución no cambia nada | ~60 min |
| 6 | [lab-06-script-roto](lab-06-script-roto/) | Arreglar los cinco fallos de un script de un compañero (roto a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Una terminal fuera de tmux.** Todos los comandos van en la
   **terminal A**: `echo "$TMUX"` no imprime nada en ella. Solo el lab 01
   usa una **terminal B** para conectarte. En el laboratorio Docker, desde la
   raíz del repositorio:
   ```bash
   docker compose up -d lab        # una sola vez
   docker compose exec lab bash    # en cada terminal que necesites
   ```
   Al terminar la semana: `docker compose down`.
2. **La carpeta del lab.** Desde la raíz del repositorio, `cd` a la carpeta
   del lab (el paso 0 de cada lab da la ruta). Todos los comandos se
   escriben desde ahí.
3. **Un servidor aparte, sin tu config.** Los scripts hablan con tmux
   mediante `tmx()`, que añade `-L "$TMUX_SOCKET"` si la variable existe.
   Arranca el servidor del lab vacío y sin config, y apunta los scripts a él:
   ```bash
   mkdir -p /tmp/lab09
   tmux -L lab -f /dev/null start-server \; set -s exit-empty off
   export TMUX_SOCKET=lab
   ```
   ```
   (sin salida)
   ```
   `-f /dev/null` solo actúa al arrancar el servidor: si el primer
   `new-session` lo lanzara un script, el servidor leería tu
   `~/.config/tmux/tmux.conf` y los índices o el prefix podrían no
   coincidir con los del lab. `exit-empty off` mantiene vivo un servidor sin
   sesiones; sin ella, `start-server` sale en el acto.
4. **El prefix es `C-b`**: el servidor arranca sin config.
5. **Lo temporal va a `/tmp/lab09`.** Nada toca tu `$HOME`.
6. **Al terminar cada lab** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   Si la B seguía conectada, imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Teclas, esperas e idempotencia](../1-teoria/02-teclas-esperas-e-idempotencia.md) | [Lab 01 — Crear sin conectarse](lab-01-crear-sin-conectarse/README.md) → |

[↑ Semana 09](../README.md)
