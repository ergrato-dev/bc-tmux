# Semana 04 — Copy mode, buffers y portapapeles

## Descripción

Aprenderás a recorrer y copiar el historial de cualquier panel con copy mode, a manejar los buffers de tmux y a volcar un panel con `capture-pane`. Cierras con el paso que más falla en la práctica: llevar lo copiado al portapapeles de tu sistema, en local con la herramienta de cada plataforma y por SSH con OSC 52.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Recorrer y buscar en el historial con copy mode y teclas de vi, fijando `mode-keys` y `history-limit`
- Seleccionar por caracteres, líneas y rectángulos y copiar con `copy-pipe`, con el teclado y con el ratón
- Crear, pegar, guardar y cargar buffers, con y sin nombre, y explicar `buffer-limit` y el *bracketed paste*
- Volcar el historial de otro panel con `capture-pane`, eligiendo rango, uniendo líneas y validando el target
- Conectar `copy-command` a `pbcopy`, `win32yank.exe`/`clip.exe`, `wl-copy` o `xclip` según la plataforma
- Explicar y depurar OSC 52: `set-clipboard`, la capacidad `Ms`, `load-buffer -w` y por qué atraviesa SSH
- Añadir a tu `tmux-kit` su primer `tmux.conf` y `bin/kit-copiar`, que copia bien en local y por SSH

## Prerrequisitos

- [Semana 03](../week-03-sesiones_targets_y_sockets/README.md) completada: sesiones, targets y sockets, y `tmux-kit` con `sesiones`
- Laboratorio Docker construido (`docker compose build`) y dos terminales para el lab 06
- Una terminal con soporte de OSC 52 para el lab 06: Windows Terminal, iTerm2, kitty, WezTerm, Alacritty o foot
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-copy-mode-y-buffers.md](1-teoria/01-copy-mode-y-buffers.md) · [02-portapapeles-y-osc52.md](1-teoria/02-portapapeles-y-osc52.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-moverte-por-el-historial](2-practicas/lab-01-moverte-por-el-historial/) | 60 min |
| 2 | Lab | [lab-02-seleccionar-y-copiar](2-practicas/lab-02-seleccionar-y-copiar/) | 60 min |
| 3 | Lab | [lab-03-buffers](2-practicas/lab-03-buffers/) | 60 min |
| 4 | Lab | [lab-04-capture-pane](2-practicas/lab-04-capture-pane/) | 60 min |
| 5 | Lab | [lab-05-portapapeles-del-sistema](2-practicas/lab-05-portapapeles-del-sistema/) | 60 min |
| 6 | Lab | [lab-06-portapapeles-roto](2-practicas/lab-06-portapapeles-roto/) | 60 min |
| — | Proyecto | [tmux-kit: copiar en local y por SSH](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (copy mode y buffers + portapapeles y OSC 52)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — mode-keys, history-limit, búsqueda y clear-history
[60 min] lab-02 — Space/V/rectángulo, bindings de vim, copy-command y ratón
[60 min] lab-03 — Pila de buffers, buffer-limit, bracketed paste y guardar-buffers.sh
[60 min] lab-04 — capture-pane con -S/-E/-J/-e y capturar.sh
[60 min] lab-05 — pbcopy, win32yank.exe, xclip y copiar.sh conectado a tmux
[60 min] lab-06 — Depurar una config que copia con OSC 52
[3 h]    Proyecto: tmux.conf + kit-copiar, en local y por SSH
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 04
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los 19 requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y en tu máquina esto debe acabar en tu portapapeles:

```bash
printf 'año' | 3-proyecto/starter/bin/kit-copiar     # Ctrl+V pega "año"
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 03 — Sesiones, targets y sockets](../week-03-sesiones_targets_y_sockets/README.md) | **Semana 04 — Copy mode, buffers y portapapeles** | Semana 05 — Configuración y alcance de opciones |

[← Volver al índice del bootcamp](../README.md)
