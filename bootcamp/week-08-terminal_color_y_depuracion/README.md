# Semana 08 — Terminal, color y depuración

## Descripción

Los colores lavados, el subrayado ondulado que sale recto, el `Esc` lento o la `C-Enter` que no llega tienen casi siempre la misma raíz: tmux no sabe qué puede hacer tu terminal, o les miente a los programas sobre qué terminal tienen delante. Aprenderás a separar el `TERM` de fuera del de dentro, a leer terminfo y a completarlo con `terminal-features`, y a diagnosticar con `-vvv`, `show-messages -T` y un servidor limpio antes de tocar nada. Cierras con `conf.d/40-terminal.conf`, `bin/kit-doctor` y una guía de diagnóstico en tu `tmux-kit`.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Distinguir el `TERM` de fuera (`#{client_termname}`) del de dentro (`default-terminal`) y explicar por qué el de dentro es `tmux-256color`
- Leer una entrada terminfo con `infocmp -x` y compilar una propia con `tic` en un directorio aislado
- Activar color de 24 bits, estilos de subrayado y teclas extendidas con `terminal-features`, sin duplicar entradas al recargar, y comprobarlo en `#{client_termfeatures}`
- Configurar `extended-keys`, `escape-time`, `focus-events` y `allow-passthrough` sabiendo qué arregla y qué riesgo trae cada una
- Aislar si un fallo es de tu config o de tu terminal con `-f /dev/null`, `show-messages -T` y los logs de `-vvv`
- Escribir un diagnóstico sin efectos secundarios que no arranca servidores

## Prerrequisitos

- [Semana 07](../week-07-formats_y_status_line/README.md) completada: `tmux-kit` con `conf.d/30-status.conf` y `bin/kit-git-branch`
- Laboratorio Docker construido (`docker compose build`) y dos terminales fuera de tmux: esta semana la segunda es tu terminal de verdad, porque los colores y las teclas los pone tu emulador
- `git` y `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-terminal-y-color.md](1-teoria/01-terminal-y-color.md) · [02-depuracion.md](1-teoria/02-depuracion.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-dos-term](2-practicas/lab-01-dos-term/) | 60 min |
| 2 | Lab | [lab-02-terminfo](2-practicas/lab-02-terminfo/) | 60 min |
| 3 | Lab | [lab-03-color-de-24-bits](2-practicas/lab-03-color-de-24-bits/) | 60 min |
| 4 | Lab | [lab-04-teclas-extendidas](2-practicas/lab-04-teclas-extendidas/) | 60 min |
| 5 | Lab | [lab-05-passthrough-y-estilos](2-practicas/lab-05-passthrough-y-estilos/) | 60 min |
| 6 | Lab | [lab-06-depurar-una-terminal-rota](2-practicas/lab-06-depurar-una-terminal-rota/) | 60 min |
| — | Proyecto | [tmux-kit: terminal, kit-doctor y guía de diagnóstico](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (terminal y color + depuración)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — TERM de fuera y de dentro, client_termname, default-terminal
[60 min] lab-02 — infocmp, tput y una entrada propia con RGB compilada con tic
[60 min] lab-03 — Feature RGB en pantalla y en los bytes (38;2 frente a 38;5)
[60 min] lab-04 — C-Enter distinta de Enter: extended-keys y extkeys
[60 min] lab-05 — allow-passthrough, \ePtmux; y subrayado ondulado con usstyle
[60 min] lab-06 — Depurar una config con cinco fallos con -vvv y -f /dev/null
[3 h]    Proyecto: 40-terminal.conf, bin/kit-doctor y docs/diagnostico.md
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 08
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y `kit-doctor` no debe dar ningún `fallo` con tu config:

```bash
tmux -L kit -f "$PWD/3-proyecto/starter/tmux.conf" new -d
TMUX_SOCKET=kit 3-proyecto/starter/bin/kit-doctor; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 07 — Formats y status line](../week-07-formats_y_status_line/README.md) | **Semana 08 — Terminal, color y depuración** | [Semana 09 — Scripting de tmux desde shell →](../week-09-scripting_de_tmux_desde_shell/README.md) |

[← Volver al índice del bootcamp](../README.md)
