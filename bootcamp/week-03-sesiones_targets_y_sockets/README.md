# Semana 03 — Sesiones, targets y sockets

## Descripción

Trabajarás con varias sesiones a la vez y aprenderás a apuntar a cualquier objeto de tmux sin equivocarte: cómo resuelve tmux un target, por qué `-t api` puede acabar en `api-vieja` y cuándo usar `switch-client` en vez de `attach`. Cierras con los sockets y la variable `$TMUX`, que dicen a un script en qué servidor está.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Crear, renombrar, recorrer y cerrar varias sesiones con `choose-tree` y `switch-client`
- Escribir targets `sesión:ventana.panel` con nombres, índices, ids y tokens especiales
- Explicar cómo resuelve tmux un nombre de sesión y evitar el prefijo con `=`
- Validar un target antes de usarlo, sabiendo que `display-message` no falla
- Agrupar sesiones que comparten ventanas con su propia ventana actual
- Elegir el socket con `-L`, `-S` o `TMUX_TMPDIR`, leer `$TMUX` y recuperar un socket borrado
- Añadir a tu `tmux-kit` el script `sesiones` para listar, saltar, crear y agrupar sesiones

## Prerrequisitos

- [Semana 02](../week-02-ventanas_y_paneles/README.md) completada: paneles, layouts e ids, y `tmux-kit` con `kit-layout`
- Laboratorio Docker construido (`docker compose build`) y dos terminales para los labs 03 y 04
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-sesiones-y-grupos.md](1-teoria/01-sesiones-y-grupos.md) · [02-targets-y-sockets.md](1-teoria/02-targets-y-sockets.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-varias-sesiones](2-practicas/lab-01-varias-sesiones/) | 60 min |
| 2 | Lab | [lab-02-targets](2-practicas/lab-02-targets/) | 60 min |
| 3 | Lab | [lab-03-moverte-entre-sesiones](2-practicas/lab-03-moverte-entre-sesiones/) | 60 min |
| 4 | Lab | [lab-04-grupos-de-sesiones](2-practicas/lab-04-grupos-de-sesiones/) | 60 min |
| 5 | Lab | [lab-05-sockets-y-la-variable-tmux](2-practicas/lab-05-sockets-y-la-variable-tmux/) | 60 min |
| 6 | Lab | [lab-06-sesion-rota](2-practicas/lab-06-sesion-rota/) | 60 min |
| — | Proyecto | [tmux-kit: sesiones](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (sesiones y grupos + targets y sockets)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Varias sesiones, choose-tree y limpiar las que sobran
[60 min] lab-02 — Targets, el prefijo traicionero y resolver.sh
[60 min] lab-03 — prefix ( ) L, filtros, detach-on-destroy y switch-client
[60 min] lab-04 — Dos clientes frente a un grupo de sesiones
[60 min] lab-05 — -L, -S, TMUX_TMPDIR, $TMUX y el socket borrado
[60 min] lab-06 — Depurar un script que abre la sesión equivocada
[3 h]    Proyecto: sesiones para listar, saltar, crear y agrupar
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 03
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los 20 requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y esto debe funcionar en tu equipo, fuera y dentro de tmux:

```bash
TMUX_SOCKET=kit 3-proyecto/starter/bin/sesiones nueva prueba /tmp
TMUX_SOCKET=kit 3-proyecto/starter/bin/sesiones
tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 02 — Ventanas y paneles](../week-02-ventanas_y_paneles/README.md) | **Semana 03 — Sesiones, targets y sockets** | Semana 04 — Copy mode, buffers y portapapeles |

[← Volver al índice del bootcamp](../README.md)
