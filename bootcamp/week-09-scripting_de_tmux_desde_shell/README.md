# Semana 09 — Scripting de tmux desde shell

## Descripción

Todo lo que haces con el prefix es un comando que bash puede lanzar, y un script que monta tu entorno de trabajo en un segundo es la primera automatización que de verdad usarás a diario. El problema es que un script de tmux que se equivoca casi nunca da error: sale con 0 y actúa sobre otra sesión, otra ventana u otro servidor. Aprenderás a crear sin conectarte, a apuntar con ids y nombres exactos, a consultar el estado con formats, a teclear sin abrir la puerta a una inyección, a esperar con `wait-for` y a escribir scripts idempotentes. Cierras con `bin/dev-up` y `bin/dev-down` en tu `tmux-kit`.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Crear sesiones, ventanas y paneles desde un script con `new-session -d`, `-c`, `-x`/`-y` y capturar sus ids con `-P -F`
- Consultar el estado con `list-* -F` y `-f`, recorrerlo con `while read -r` y validar un target con `list-panes` en vez de `display -p`
- Enviar comandos a un panel con `send-keys -l` y `Enter` aparte, escapando con `%q` lo que venga de fuera
- Esperar a que un comando termine en un panel con `wait-for`, ponerle límite con `timeout` y recuperar su código de salida
- Escribir scripts idempotentes con `has-session -t "=nombre"` y ventanas buscadas por nombre, y explicar por qué `new-session -A` no sirve en un script
- Depurar un script que funciona en la demo y falla con el servidor ocupado

## Prerrequisitos

- [Semana 08](../week-08-terminal_color_y_depuracion/README.md) completada: `tmux-kit` con `conf.d/40-terminal.conf`, `bin/kit-doctor` y `docs/diagnostico.md`
- Laboratorio Docker construido (`docker compose build`) y una terminal **fuera de tmux** (`echo "$TMUX"` vacío); el lab 01 usa una segunda para conectarte
- `bash` con `set -euo pipefail`, `git` y `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-crear-y-consultar.md](1-teoria/01-crear-y-consultar.md) · [02-teclas-esperas-e-idempotencia.md](1-teoria/02-teclas-esperas-e-idempotencia.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-crear-sin-conectarse](2-practicas/lab-01-crear-sin-conectarse/) | 60 min |
| 2 | Lab | [lab-02-consultar-con-formatos](2-practicas/lab-02-consultar-con-formatos/) | 60 min |
| 3 | Lab | [lab-03-enviar-teclas-con-cuidado](2-practicas/lab-03-enviar-teclas-con-cuidado/) | 60 min |
| 4 | Lab | [lab-04-esperar-con-wait-for](2-practicas/lab-04-esperar-con-wait-for/) | 60 min |
| 5 | Lab | [lab-05-idempotencia](2-practicas/lab-05-idempotencia/) | 60 min |
| 6 | Lab | [lab-06-script-roto](2-practicas/lab-06-script-roto/) | 60 min |
| — | Proyecto | [tmux-kit: dev-up y dev-down](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (crear y consultar + teclas, esperas e idempotencia)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — new-session -d, -c, -x/-y y ids con -P -F; attach después
[60 min] lab-02 — list-* -F y -f, bucles read, display -p frente a list-panes
[60 min] lab-03 — send-keys -l, Enter aparte, un nombre hostil con %q, respawn-pane
[60 min] lab-04 — wait-for, timeout y el código de salida del panel
[60 min] lab-05 — Crear o reutilizar: la segunda ejecución no cambia nada
[60 min] lab-06 — Arreglar los cinco fallos de un script de un compañero
[3 h]    Proyecto: bin/dev-up y bin/dev-down idempotentes
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 09
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker y en un servidor
aislado (`TMUX_SOCKET=bc-check`). Al terminar deben pasar todos, y lanzar
`dev-up` dos veces seguidas debe dejar exactamente las mismas ventanas:

```bash
TMUX_SOCKET=kit 3-proyecto/starter/bin/dev-up -d /tmp api
TMUX_SOCKET=kit 3-proyecto/starter/bin/dev-up -d /tmp api
tmux -L kit list-windows -t "=api" -F '#{window_name}'; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 08 — Terminal, color y depuración](../week-08-terminal_color_y_depuracion/README.md) | **Semana 09 — Scripting de tmux desde shell** | Semana 10 — Hooks, popups y menús |

[← Volver al índice del bootcamp](../README.md)
