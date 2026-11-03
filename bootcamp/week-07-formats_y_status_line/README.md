# Semana 07 — Formats y status line

## Descripción

La barra deja de ser verde con la hora y pasa a contarte lo que importa: si el prefix está pulsado, si estás en el modo resize, qué ventana tiene zoom, en qué rama trabaja el panel. Aprenderás cómo expande tmux un format, a probarlo con `display -p` antes de usarlo y a construir la status line con estilos y comandos sin instalar ningún plugin. Cierras con `conf.d/30-status.conf` en tu `tmux-kit`, con una paleta que se cambia en un solo sitio.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Leer el estado de tmux con `#{...}`, `display -p` y `list-* -F`, y explicar por qué un nombre mal escrito no da error
- Escribir indicadores que solo aparecen cuando toca con `#{?...}`, `==`, `m:`, `&&`/`||` y `e|...|`, escapando comas con `#,`
- Transformar valores con modificadores: recortar, rellenar, sustituir, fechas, `q:` y `E:`
- Pintar la barra con `#[...]` y las opciones `*-style`, y dibujar la lista de ventanas con `window-status-*format` y `W:`
- Mostrar la salida de un script propio con `#(...)` y decidir su `status-interval`
- Depurar una status line rota: escapes, longitudes que cortan y estilos sin cerrar

## Prerrequisitos

- [Semana 06](../week-06-key_bindings_tablas_y_navegacion/README.md) completada: `tmux-kit` con prefix propio, tabla `kit-resize`, `@kit-nav` y `bin/kit-keys`
- Laboratorio Docker construido (`docker compose build`) y dos terminales fuera de tmux: una para los comandos y otra para mirar la barra
- `git` y `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-formats.md](1-teoria/01-formats.md) · [02-status-line.md](1-teoria/02-status-line.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-formats-y-display](2-practicas/lab-01-formats-y-display/) | 60 min |
| 2 | Lab | [lab-02-condicionales-y-comparaciones](2-practicas/lab-02-condicionales-y-comparaciones/) | 60 min |
| 3 | Lab | [lab-03-modificadores](2-practicas/lab-03-modificadores/) | 60 min |
| 4 | Lab | [lab-04-estilos-y-ventanas](2-practicas/lab-04-estilos-y-ventanas/) | 60 min |
| 5 | Lab | [lab-05-comandos-y-varias-lineas](2-practicas/lab-05-comandos-y-varias-lineas/) | 60 min |
| 6 | Lab | [lab-06-status-rota](2-practicas/lab-06-status-rota/) | 60 min |
| — | Proyecto | [tmux-kit: status line propia sin plugins](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (formats + status line)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — #{...}, display -p, list-windows -F y formats que salen vacíos
[60 min] lab-02 — #{?...}, ==, m:, e|>=|, #, e indicadores de prefix y zoom
[60 min] lab-03 — Recortar, rellenar, sustituir, fechas, q:, E: y aritmética
[60 min] lab-04 — *-style, #[...], window-status-*format y el bucle W:
[60 min] lab-05 — Rama git con #(...) y un script propio, status-interval y status 2
[60 min] lab-06 — Depurar una status line con cinco errores
[3 h]    Proyecto: paleta, 30-status.conf con prefix, RESIZE, ZOOM, SYNC, NAV y rama git
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 07
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y tu barra debe leerse como formats expandidos:

```bash
tmux -L kit -f "$PWD/3-proyecto/starter/tmux.conf" new -d
tmux -L kit display -p '#{E:status-left}'; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 06 — Key bindings, tablas y navegación](../week-06-key_bindings_tablas_y_navegacion/README.md) | **Semana 07 — Formats y status line** | Semana 08 — Terminal, color y depuración |

[← Volver al índice del bootcamp](../README.md)
