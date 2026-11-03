# Labs — Semana 10: Hooks, popups y menús

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-hooks](lab-01-hooks/) | `set-hook` con índice fijo, `-u`, `show-hooks`, y los formats que ve cada hook (`#{pane_id}`, no `#{hook_pane}`) | ~60 min |
| 2 | [lab-02-popups](lab-02-popups/) | `display-popup` con `-E`/`-EE`, tamaño, título, `-d` y `-e`, y por qué su comando no es un format | ~60 min |
| 3 | [lab-03-menus-y-prompts](lab-03-menus-y-prompts/) | Un menú propio, `command-prompt` con `%%`/`%1` y `confirm-before`, y una plantilla que un nombre hostil no rompe | ~60 min |
| 4 | [lab-04-run-shell-y-pipe-pane](lab-04-run-shell-y-pipe-pane/) | `run-shell` con y sin `-b`, adónde va su salida, y un interruptor de log con `pipe-pane -o` y la ruta bien citada | ~60 min |
| 5 | [lab-05-fzf-en-un-popup](lab-05-fzf-en-un-popup/) | Un selector de sesiones con fzf en un popup que vuelve a tmux por id y funciona sin fzf | ~60 min |
| 6 | [lab-06-hooks-rotos](lab-06-hooks-rotos/) | Arreglar los cinco fallos de una config de un compañero (rota a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Dos terminales fuera de tmux.** Popups, menús y prompts solo aparecen
   en un cliente conectado:
   - **Terminal A**: escribes los comandos. `echo "$TMUX"` no imprime nada
     en ella.
   - **Terminal B**: conectada al servidor del lab (`attach`), donde ves y
     respondes popups y menús.

   En el laboratorio Docker, desde la raíz del repositorio:
   ```bash
   docker compose up -d lab        # una sola vez
   docker compose exec lab bash    # en cada terminal
   ```
   Al terminar la semana: `docker compose down`.
2. **La carpeta del lab.** En las dos terminales, desde la raíz del
   repositorio, `cd` a la carpeta del lab (el paso 0 de cada lab da la
   ruta). Todos los comandos se escriben desde ahí.
3. **Un servidor aparte con la config del lab** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   ```
   ```
   (sin salida)
   ```
   `-L lab` no toca tu tmux de siempre; `-f` carga el starter en vez de tu
   `~/.config/tmux/tmux.conf`. Tras editar el starter, recarga con
   `tmux -L lab source-file "$PWD/starter/tmux.conf"`.
4. **Conectarte y salir** (terminal B):
   ```bash
   tmux -L lab attach -t lab
   ```
   **El prefix es `C-b`**: ningún starter lo cambia. Sales con `C-b` `d`, y
   B imprime `[detached (from session lab)]`.
5. **Scripts y temporales** (labs 02, 04 y 05, terminal A):
   ```bash
   mkdir -p /tmp/lab10; export TMUX_SOCKET=lab
   ```
   ```
   (sin salida)
   ```
   Los scripts hablan con tmux mediante `tmx()`, que añade
   `-L "$TMUX_SOCKET"` si la variable existe. Dentro de un popup o de
   `run-shell` no hace falta: `$TMUX` ya apunta al servidor del lab. Lo
   temporal va a `/tmp/lab10`; nada toca tu `$HOME`.
6. **Lo que lanzas desde A espera a B.** `display-popup`, `display-menu`,
   `command-prompt` y `confirm-before` no devuelven el prompt de A hasta
   que el popup, el menú o el prompt se cierran en B. Cierres: menú con `q`
   o `Escape`; popup sin `-E` con `Escape`; prompt con `Escape`.
7. **Al terminar cada lab** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab10
   ```
   Si B seguía conectada, imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Popups, menús y prompts](../1-teoria/02-popups-menus-y-prompts.md) | [Lab 01 — Hooks](lab-01-hooks/README.md) → |

[↑ Semana 10](../README.md)
