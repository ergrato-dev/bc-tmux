# Semana 10 — Hooks, popups y menús

## Descripción

Hasta ahora tmux solo hacía algo cuando tú se lo pedías. Esta semana reacciona solo con hooks, te pregunta con popups, menús y prompts, y lanza shells con `run-shell` y `pipe-pane`. Cada pieza tiene una trampa silenciosa: hooks que se duplican al recargar o se disparan a sí mismos, popups que no se cierran, prompts que ejecutan lo que escribes y `run-shell` que congela el teclado. Cierras con un popup selector de proyectos con fzf, el menú del kit y un interruptor de log por panel en tu `tmux-kit`.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Definir hooks con índice fijo que no se duplican al recargar, borrarlos con `-u` y leerlos con `show-hooks`
- Elegir el format correcto dentro de un hook (`#{pane_id}` en `after-split-window`, `#{hook_session_name}` en `session-created`) y explicar por qué un `tmux` lanzado con `run-shell` vuelve a dispararlo
- Abrir comandos y scripts en popups con `-E`/`-EE`, tamaño, título, `-d` y `-e`, y obtener el contexto desde dentro porque 3.4 no expande su comando
- Construir menús con `display-menu`, prompts con `command-prompt` y confirmaciones con `confirm-before`, con plantillas entre llaves que un nombre hostil no rompe
- Lanzar shells con `run-shell` sin bloquear al cliente y alternar el log de un panel con `pipe-pane -o` y una ruta citada a prueba de `#`, `'` y `$(...)`
- Montar un selector con fzf en un popup que vuelve a tmux por id y funciona sin fzf

## Prerrequisitos

- [Semana 09](../week-09-scripting_de_tmux_desde_shell/README.md) completada: `tmux-kit` con `bin/dev-up` y `bin/dev-down` idempotentes
- Laboratorio Docker construido (`docker compose build`) y **dos terminales fuera de tmux** (`echo "$TMUX"` vacío): una lanza comandos y la otra, conectada, muestra popups y menús
- `fzf` instalado (≥ 0.44, ver `docs/setup-entorno.md`; el laboratorio ya lo trae) y `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-hooks-y-run-shell.md](1-teoria/01-hooks-y-run-shell.md) · [02-popups-menus-y-prompts.md](1-teoria/02-popups-menus-y-prompts.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-hooks](2-practicas/lab-01-hooks/) | 60 min |
| 2 | Lab | [lab-02-popups](2-practicas/lab-02-popups/) | 60 min |
| 3 | Lab | [lab-03-menus-y-prompts](2-practicas/lab-03-menus-y-prompts/) | 60 min |
| 4 | Lab | [lab-04-run-shell-y-pipe-pane](2-practicas/lab-04-run-shell-y-pipe-pane/) | 60 min |
| 5 | Lab | [lab-05-fzf-en-un-popup](2-practicas/lab-05-fzf-en-un-popup/) | 60 min |
| 6 | Lab | [lab-06-hooks-rotos](2-practicas/lab-06-hooks-rotos/) | 60 min |
| — | Proyecto | [tmux-kit: popup de proyectos, menú y log de paneles](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (hooks y run-shell + popups, menús y prompts)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — set-hook con índice fijo, -u, show-hooks y los formats de cada hook
[60 min] lab-02 — display-popup con -E/-EE, tamaño, título, -d, -e y un script dentro
[60 min] lab-03 — display-menu, command-prompt con %% y confirm-before; un nombre hostil
[60 min] lab-04 — run-shell con y sin -b, y un interruptor de log con pipe-pane -o
[60 min] lab-05 — Selector de sesiones con fzf en un popup, por id y sin fzf
[60 min] lab-06 — Arreglar los cinco fallos de la config de un compañero
[3 h]    Proyecto: bin/kit-log, bin/kit-projects y conf.d/50-hooks-popups.conf
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 10
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker y en un servidor
aislado (`TMUX_SOCKET=bc-check`). Al terminar deben pasar todos, y recargar la
config dos veces debe dejar cada hook del kit una sola vez (desde la carpeta
de la semana):

```bash
tmux -L kit -f "$PWD/3-proyecto/starter/tmux.conf" new -d \; source-file "$PWD/3-proyecto/starter/tmux.conf"
tmux -L kit show-hooks -g | grep '\['; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 09 — Scripting de tmux desde shell](../week-09-scripting_de_tmux_desde_shell/README.md) | **Semana 10 — Hooks, popups y menús** | Semana 11 — Plugins y ecosistema |

[← Volver al índice del bootcamp](../README.md)
