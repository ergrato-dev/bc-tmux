# CLAUDE.md — bc-tmux

Instrucciones de proyecto para Claude Code. Este archivo se carga automáticamente en cada sesión.

---

## Identidad del proyecto

- **Nombre:** bc-tmux
- **Tipo:** Bootcamp técnico, 100% orientado a la práctica
- **Duración:** 13 semanas × 10 horas = 130 horas totales (Zero to Advanced)
- **Herramienta central:** tmux **≥ 3.4** (Ubuntu 24.04 LTS). Features más nuevas se marcan "tmux 3.5+" con alternativa para 3.4
- **Sistema mínimo del estudiante:** Ubuntu 24.04 LTS (nativo o WSL2) o macOS con Homebrew
- **Repositorio de referencia de estructura:** ergrato-dev/bc-makefile; proyecto hilo conductor al estilo de ergrato-dev/bc-observability

## Audiencia objetivo

Personas que ya usan la terminal con soltura (nivel de bc-linux-commandline: navegación, pipes, procesos, bash básico) y nunca usaron tmux o solo lo abren para no perder una sesión SSH. No asumas conocimiento de tmux; sí asume bash, git y un editor de terminal.

## Filosofía de contenido: 100% práctica

- **Teoría mínima:** solo el contexto indispensable para no perderse en el lab. Máximo 45 min por semana.
- **Labs primero:** el estudiante aprende haciendo, no leyendo.
- **Errores intencionados:** algunos labs incluyen configuración rota (escape-time, `TERM` mal puesto, bindings que se pisan, scripts no idempotentes) para que el estudiante la depure.
- **Progresión real:** cada semana construye sobre la anterior (ver proyecto hilo conductor).
- **Sin hello world vacío:** cada ejercicio tiene un propósito concreto y un output verificable.

## Proyecto hilo conductor: `tmux-kit`

El estudiante construye a lo largo del bootcamp **su propio kit de tmux**: configuración modular, status line, bindings, scripts y un plugin. Cada `3-proyecto/starter/` parte del resultado de la semana anterior; la semana 13 entrega el kit completo. Detalle en `docs/proyecto-hilo-conductor.md`.

```
tmux-kit/
├── tmux.conf            # punto de entrada: solo source-file de conf.d/
├── conf.d/              # 10-options.conf, 20-bindings.conf, 30-status.conf ...
├── bin/                 # scripts bash (dev-up, sesiones, popups)
├── plugin/              # plugin propio (semana 11)
└── install.sh           # bootstrap (semana 13)
```

## Distribución de tiempo por semana (10h)

| Sección | Tiempo | Descripción |
|---------|--------|-------------|
| 1-teoria | 45 min | Contexto mínimo + referencia rápida (1–3 archivos) |
| Conocimiento | 15 min | 10 preguntas de la rúbrica, respondidas por escrito |
| 2-practicas | 6h | 6 labs progresivos (~60 min c/u) |
| 3-proyecto | 3h | Proyecto semanal integrador (incremento de `tmux-kit`) |

## Estructura de carpetas por semana

```
week-NN-nombre_del_tema/
├── README.md                  # Descripción, objetivos, tabla de contenidos, navegación
├── rubrica-evaluacion.md      # Conocimiento 30 / Desempeño 40 / Producto 30
├── checks.json                # Autograding (ver docs/autograding.md)
├── 0-assets/                  # Diagramas SVG, enlazados desde 1-teoria
│   └── NN-nombre.svg
├── 1-teoria/                  # Contexto mínimo, NO tutoriales largos
│   └── 01-contexto.md         # 1–3 archivos, ≤ 600 palabras de prosa c/u
├── 2-practicas/
│   ├── README.md              # Índice de labs con duración estimada
│   └── lab-NN-nombre/
│       ├── README.md          # Enunciado, instrucciones, criterios de éxito
│       ├── starter/           # tmux.conf y/o scripts con TODOs
│       └── solucion/          # Solución de referencia (pasa a repo privado)
├── 3-proyecto/
│   ├── README.md
│   ├── starter/               # tmux-kit de la semana anterior + TODOs
│   └── solucion/              # tmux-kit al terminar esta semana
├── 4-recursos/
│   ├── ebooks-free/README.md
│   ├── videografia/README.md
│   └── webgrafia/README.md
└── 5-glosario/
    └── README.md              # Término | Definición en una línea | Ejemplo
```

## Convenciones de naming

| Elemento | Convención | Ejemplo |
|----------|-----------|---------|
| Carpeta de semana | `week-NN-nombre_con_guion_bajo` | `week-05-configuracion_y_alcance_de_opciones` |
| Carpeta de lab | `lab-NN-nombre-con-guion` | `lab-02-split-y-navegacion` |
| Config de tmux | `tmux.conf` (sin punto inicial dentro del repo) | `starter/tmux.conf` |
| Fragmentos de config | `conf.d/NN-tema.conf` | `conf.d/20-bindings.conf` |
| Scripts del kit y de los labs | `bin/name-kebab` (sin extensión) o `name.sh`, **en inglés** | `bin/dev-up`, `bin/kit-copy`, `starter/resolve.sh` |
| Opciones de usuario tmux | `@kit-name-kebab`, en inglés | `@kit-status-git` |
| Nombres de sesión en ejemplos | minúsculas, sin espacios | `api`, `notas` |

## Estándares de tmux en el repo

```tmux
# Siempre -g explícito para opciones globales; nunca depender del alcance por defecto
set -g  prefix C-a
unbind  C-b
bind    C-a send-prefix

# setw solo cuando la opción es de ventana; set -p para opciones de panel
setw -g mode-keys vi

# Rutas de config siempre relativas a XDG: ~/.config/tmux/tmux.conf
bind r source-file ~/.config/tmux/tmux.conf \; display "config recargada"

# Comprobación de versión con if-shell -b solo cuando haga falta una feature 3.5+
```

- Config del estudiante en `~/.config/tmux/tmux.conf` (XDG), nunca `~/.tmux.conf` salvo para explicar el legado.
- Prefix por defecto `C-b` hasta la semana 05; desde ahí cada estudiante elige y se documenta.
- Nunca `set -g default-terminal xterm-256color` dentro de tmux: siempre `tmux-256color` + `terminal-features`.
- Scripts bash: `#!/usr/bin/env bash` + `set -euo pipefail`, citar siempre `"$var"`, `shellcheck` limpio.
- Todo script que crea sesiones es **idempotente** (`has-session` antes de `new-session`).
- Todo script de `bin/` habla con tmux mediante `tmx() { "${TMUX_BIN:-tmux}" ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }`: sin variables usa el servidor de siempre; el autograding exporta `TMUX_SOCKET=bc-check`.
- Para apuntar a una sesión desde un script se usan ids (`$0`, `@1`, `%2`) o `nombre:`; `-t "=nombre"` no sirve con comandos que esperan un panel (`display-message` devuelve campos vacíos).
- Sin `=`, `-t nombre` coincide por prefijo (`-t api` encuentra `api-vieja`): en scripts, los comandos de sesión (`has-session`, `kill-session`, `switch-client`, `attach`) llevan `-t "=$nombre"`.
- `display-message -p -t X` **no falla** si `X` no existe: sale con 0 y usa otro objeto. Para validar un target se usa `list-panes -t X` (sí falla).
- Nunca `send-keys` con texto sin citar que venga de una variable externa (inyección de comandos).

## Estándares de idioma

- **Prosa, enunciados, comentarios:** español, siempre **tuteo** (tú, tienes, puedes, haz). **Nunca voseo** (vos, tenés, podés, hacé, mirá).
- **Nomenclatura técnica en inglés:** nombres de scripts y archivos de código, variables, funciones, opciones `@kit-*`. Siguen en español: carpetas del curso (`week-*`, `lab-*`), archivos `.md`, el tooling del repo (`scripts/verificar-*.sh`) y nombres de sesión de ejemplo.
- **Comentarios en español, solo donde hagan falta:** documentan qué hace, para qué y qué impacto tiene (qué se rompe sin esa línea). Nunca repiten el código, otro comentario ni el README.
- **Mensajes de `display`/`echo` para el usuario:** español
- **Nunca mezclar idiomas en la misma línea de prosa**

## Estructura de un lab (README.md de lab)

1. **Título y duración estimada**
2. **Objetivo** — una sola oración con el verbo en infinitivo
3. **Contexto** — máx. 3 párrafos o bullets; no repetir lo que ya está en 1-teoria
4. **Instrucciones** — pasos numerados, con comandos exactos y teclas exactas (`prefix` + `%`)
5. **Criterios de éxito** — outputs verificables (`tmux show -gv prefix` imprime `C-a`)
6. **Reto extra** (opcional)

Los labs se hacen con un servidor aparte para no romper la sesión del estudiante:
`tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab`. Al terminar: `tmux -L lab kill-server`.

## Estándar paso a paso (labs y proyectos): no asumir nada

El estudiante nunca usó tmux. Cada ejemplo es completo y se puede seguir sin adivinar:

1. **Paso 0**: `cd` a la carpeta del lab (ruta desde la raíz del repo), en una terminal **fuera de tmux** (`echo "$TMUX"` vacío), y qué servidor (`-L lab`) se usa.
2. **Output tras cada bloque**, incluido `; echo $?` cuando importa el código de salida. Sin salida: `(sin salida)`. Si varía (pid, fechas, uid): "algo como" + qué cambia. Se pega de una ejecución real con tmux 3.4, nunca de memoria.
3. **Terminal explícita**: "terminal A (conectada)" / "terminal B (fuera de tmux)". Todo `attach` dice en qué terminal va y cómo salir (`prefix` `d` → `[detached (from session X)]`). Se avisa cuando `kill-server` expulsa a un cliente (`[server exited]`).
4. **Prefix real**: si el servidor del lab arranca con `-f /dev/null` o con un starter sin `set -g prefix`, se escribe `C-b` y se dice por qué; si el starter fija uno, se nombra. `prefix` a secas solo cuando el servidor carga la config del estudiante.
5. **Teclas exactas y salida de cada modo**: `prefix` `→`, no "ve al panel". Se avisa de prompts rellenos (`prefix` `,`/`$`: `C-u` borra), confirmaciones (`prefix` `&`, `x`: responde `y`) y cómo salir (`q`/`Esc` en `w`, `s`, `D`, `#`, menús, copy mode, `top`).
6. **Un subpaso por TODO**: qué hacer, pista de sintaxis mínima (flags, `-F` y variables de formato exactos), el comando que prueba solo ese TODO y su output. Prohibido "Completa `starter/x.sh`" a secas. Si el starter tiene un `echo "sin implementar"`, se dice que se borra.
7. **Todo criterio de éxito sale de un paso** que lo produce. Toda herramienta extra se instala explícitamente (`sudo apt install shellcheck` / `brew install shellcheck`).
8. **Orden y seguridad**: las precondiciones (`rm`, `kill-server`, reiniciar tras editar) van antes del comando que las necesita. Nada toca el `$HOME`/XDG reales (`env -u XDG_CONFIG_HOME HOME=...`). Rutas absolutas (`S="$PWD/starter/x.sh"`) cuando el cliente cambia de directorio.
9. **Proyectos**: sección `## Paso a paso` que recorre los TODOs en orden, cada uno con su comprobación y output. Se trabaja sobre `3-proyecto/starter/` (es lo que corrige el autograding). Termina con `cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh NN` y su output.
10. **Agnóstico de editor**: nada depende de vim/Neovim/otro editor. Las teclas de copy mode se listan (`v`, `y`, `C-v`), no "como en vim"; los ejemplos usan programas de cualquier sistema (`less`, `top`, `printf`).

## Estructura del README.md de semana

1. Título y número de semana
2. Descripción (2-3 oraciones)
3. Objetivos de aprendizaje (lista con verbos de acción)
4. Prerrequisitos
5. Tabla de contenidos con tiempos
6. Distribución del tiempo
7. Cómo verificar que completaste la semana (`./scripts/verificar-semana.sh NN`)
8. `## 🔗 Navegación` (anterior / actual / siguiente + volver al índice)

## Rúbrica de evaluación

Tres evidencias, **mínimo 70% en cada una** (no en el promedio):
- 🧠 Conocimiento 30%: 10 preguntas conceptuales (3 pts c/u) que piden explicar el porqué, no recordar teclas
- 💪 Desempeño 40%: los 6 labs, con criterios de éxito verificables
- 📦 Producto 30%: proyecto semanal — 60 pts de autograding (`checks.json`) + 40 pts de calidad (config modular, comentarios del porqué, scripts idempotentes y limpios con shellcheck)

Bandas: Sobresaliente 90–100, Notable 80–89, Aprobado 70–79.

## Plan de 13 semanas

Índice con estado: `bootcamp/README.md` (✅ = semana al estándar actual).

| Semana | Carpeta | Tema | Proyecto semanal (`tmux-kit`) |
|--------|---------|------|-----------------|
| **Fase 1 — Fundamentos** ||||
| 01 | `week-01-primeros_pasos_y_modelo_cliente_servidor` | Multiplexor, instalación y versión, servidor/cliente, sesión → ventana → panel, prefix, detach/attach | `tmux-kit` con `bin/check-version` y `bin/kit-tree` |
| 02 | `week-02-ventanas_y_paneles` | split, navegación, resize, zoom, layouts, `break-pane`/`join-pane`/`swap-pane`, `synchronize-panes` | Layout de trabajo de 3 paneles reproducible |
| 03 | `week-03-sesiones_targets_y_sockets` | Varias sesiones, `choose-tree`, `switch-client`, targets `sesion:ventana.panel`, grupos de sesiones, `-L`/`-S` | Script para listar y saltar entre sesiones |
| 04 | `week-04-copy_mode_buffers_y_portapapeles` | copy-mode vi, búsqueda, buffers, `set-clipboard`, OSC 52, portapapeles WSL/Wayland/X11/macOS, `capture-pane` | Copiar al portapapeles en local y por SSH |
| **Fase 2 — Configuración** ||||
| 05 | `week-05-configuracion_y_alcance_de_opciones` | `tmux.conf` XDG, alcances server/session/window/pane, herencia, `show-options`, `source-file`, config modular | `tmux.conf` + `conf.d/` con recarga en caliente |
| 06 | `week-06-key_bindings_tablas_y_navegacion` | `bind`/`unbind`, `-r`, `-n`, tablas propias, `copy-mode-vi`, `{}`, `if -F`, navegación sin prefix que respeta programas a pantalla completa | Modo resize propio + navegación `C-h/j/k/l` agnóstica del editor |
| 07 | `week-07-formats_y_status_line` | `#{}`, condicionales, comparaciones, modificadores, `#()`, estilos, status de varias líneas | Status line propia sin plugins |
| 08 | `week-08-terminal_color_y_depuracion` | `TERM`, `tmux-256color`, terminfo, `terminal-features`, `extended-keys`, passthrough, `tmux -vvv`, `show-messages` | Config que pasa la batería de color/teclas + guía de diagnóstico |
| **Fase 3 — Automatización** ||||
| 09 | `week-09-scripting_de_tmux_desde_shell` | `new-session -d`, `has-session`, `send-keys`, `list-* -F`, `display -p`, `wait-for`, idempotencia | `bin/dev-up` idempotente |
| 10 | `week-10-hooks_popups_y_menus` | `set-hook`, `display-popup`, `display-menu`, `command-prompt`, `run-shell`, `pipe-pane`, opciones `@`, entorno, fzf | Popup selector de proyectos + menú + hooks |
| 11 | `week-11-plugins_y_ecosistema` | TPM, resurrect + continuum, escribir un plugin, tmuxp (`uv tool`), sesh, cuándo no instalar plugins | Plugin propio + resurrect configurado |
| **Fase 4 — Avanzado y producción** ||||
| 12 | `week-12-remoto_colaboracion_y_control_mode` | SSH, tmux anidado, socket compartido, `server-access`, `attach -r`, seguridad del socket, mosh, `-CC` | Pair programming con invitado de solo lectura + toggle de anidado |
| 13 | `week-13-proyecto_integrador` | Integración de todo | `tmux-kit` final con `install.sh` y checks propios |

Versiones del stack: `docs/stack-versions.md`. No usar otras. Python solo en la semana 11 y siempre con **uv** (`uv tool install`, `uv run`); nunca pip ni `requirements.txt`. Node.js no se usa; si alguna vez hiciera falta, siempre con **pnpm**, nunca npm.

## Autograding con tmux

Cada check corre contra un servidor **aislado** (`-L bc-check`) que nunca toca la sesión del estudiante. `verificar-semana.sh` mata ese servidor antes de cada check y al salir (`trap`). Contrato completo en `docs/autograding.md`.

```bash
{tmux} -f {proyecto}/tmux.conf new-session -d \; show -gv prefix
```

## Comandos útiles durante el desarrollo del bootcamp

```bash
./scripts/verificar-enlaces.sh                     # estructura, enlaces, starters
./scripts/verificar-semana.sh NN                   # autograding de una semana
ENTREGA=solucion ./scripts/verificar-semana.sh NN  # valida la solución de referencia

# Probar una config sin tocar tu sesión
tmux -L prueba -f ruta/tmux.conf
tmux -L prueba kill-server

# Solo parsear una config (no ejecuta nada)
tmux -L parse -f /dev/null new -d \; source-file -n ruta/tmux.conf; tmux -L parse kill-server

# Qué opciones y teclas quedaron definidas
tmux show -g ; tmux list-keys
```

## Contenido esperado por sección

### 0-assets/
Diagramas en **SVG escrito a mano**, un archivo por diagrama, nombrado `NN-nombre-descriptivo.svg` en orden de lectura. **Sin cupo por semana: los que pida el contenido, ni uno más ni uno menos.** Un diagrama entra cuando muestra algo que el texto no puede (una jerarquía, una secuencia, un flujo con ramas, una topología cliente/servidor); sobra si es una lista o una tabla con cajas alrededor o repite el bloque de código de al lado. **Nada de Mermaid ni arte ASCII.** Para crear uno: `/gen-svg`.

- **Todo SVG se enlaza desde el archivo de `1-teoria/` donde aparece el concepto**, con `../0-assets/NN-nombre.svg`. El texto alternativo describe lo que muestra. `verificar-enlaces.sh` falla con SVG huérfanos o con `.md` dentro de `0-assets/`.
- `viewBox` obligatorio, sin `width`/`height` fijos en la raíz.
- `role="img"` y `<title>` descriptivo como primer hijo.
- `<rect>` de fondo `#0d1117` que cubra el `viewBox`.
- Sin degradados, sin `foreignObject`, sin fuentes externas. Texto ≥ 12 px.
- Prosa: `font-family="Inter, system-ui, -apple-system, sans-serif"`. Código y teclas: `ui-monospace, SFMono-Regular, Menlo, monospace`.

Paleta (GitHub dark + verde tmux del header `assets/bootcamp-header.svg`):

| Rol | Hex |
|-----|-----|
| Lienzo | `#0d1117` |
| Superficie (cajas) | `#161b22` |
| Borde | `#30363d` |
| Texto principal | `#f0f6fc` |
| Texto secundario | `#8b949e` |
| Acento tmux (elemento principal, servidor, panel activo) | `#3fb950` |
| Azul (clientes, flujo) | `#58a6ff` / `#79c0ff` |
| Naranja (teclas, prefix) | `#f78166` |
| Amarillo (aviso) | `#e3b341` |
| Rojo (error, peligro) | `#f85149` |
| Morado (secundario, metadatos) | `#d2a8ff` |

### 4-recursos/
- `ebooks-free/`: `| Título | Formato | Descripción | Enlace |`, mínimo 2.
- `videografia/`: `| Título | Canal | Duración | Enlace |`, mínimo 3; en español si existe con calidad.
- `webgrafia/`: `| Recurso | Descripción |`, 3–5, priorizando `man tmux`, la wiki oficial (github.com/tmux/tmux/wiki) y el FAQ.

Solo enlaces comprobados al escribir la semana; nada inventado.

### 5-glosario/
`| Término | Definición en una línea | Ejemplo |`, entre 8 y 15 términos nuevos de esa semana.

## Notas para Claude al generar contenido

- Las soluciones se moverán al repo privado `ergrato-dev/bc-tmux-instructor` (misma ruta relativa); hasta entonces viven aquí.
- Cada semana nueva lleva `checks.json` escrito antes que el contenido y pasa `./scripts/verificar-enlaces.sh`.
- Probar toda solución con tmux 3.4 y un servidor aislado; nunca ejecutar `kill-server` sin `-L`.
- Al generar teoría, máximo 600 palabras. Preferir ejemplos concretos de config sobre explicaciones abstractas. Todo ejemplo de config se puede pegar y funciona en 3.4.
- Atajos siempre escritos como `prefix` + tecla (`prefix` `%`), nunca asumir `C-b` desde la semana 05.
- No generar contenido de semanas futuras si no se pidió explícitamente.
- Revisar voseo antes de cerrar una semana: `grep -rnwE 'vos|tenés|podés|hacé|querés|sabés|usá|mirá|probá|escribí' bootcamp` debe salir vacío.
- Tono: directo, sin relleno, orientado al profesional.
