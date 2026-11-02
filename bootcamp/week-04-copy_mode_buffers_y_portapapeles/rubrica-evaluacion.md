# Rúbrica de Evaluación — Semana 04

> Copy mode, buffers y portapapeles. Se evalúan tres evidencias por separado,
> y hace falta **70% en cada una**. Copiar rápido en local no compensa un
> `kit-copiar` que por SSH deja el texto en la máquina equivocada.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `tmux.conf` y `kit-copiar`: 60 pts de autograding + 40 pts de calidad |

**Mínimo 70% en cada evidencia.** No en el promedio.

| Calificación | Rango |
|---|:--:|
| Sobresaliente | 90-100% |
| Notable | 80-89% |
| Aprobado | 70-79% |
| No aprobado | < 70% |

---

## 🧠 Conocimiento (30%)

Diez preguntas, 3 puntos cada una. Se pide explicar por qué, no recordar teclas.

| # | Pregunta |
|:--:|---|
| 1 | Dentro de tmux, la rueda del ratón y `Shift+PgUp` de tu terminal no te llevan a lo que salió hace un rato. ¿Dónde está ese historial y por qué tu terminal no puede mostrarlo? |
| 2 | Tu `tmux.conf` no menciona `mode-keys`. En tu máquina copy mode usa teclas de vi; en un servidor, las de emacs. ¿Por qué, y qué línea lo evita? |
| 3 | Subes `history-limit` a 50000, recargas la config, y en el panel en el que estabas `g` sigue sin llegar al principio de un log largo. ¿Por qué? ¿Qué haces para tener el historial nuevo? |
| 4 | Copias con `y` en copy mode. `prefix` `]` pega bien, pero `Ctrl+V` en el navegador no. ¿Qué paso falta y cuáles son los dos caminos para darlo? |
| 5 | Por SSH, tu `copy-command` es `xclip -selection clipboard` y hay un servidor X en la máquina remota. Copias sin errores y no puedes pegar. ¿Dónde acabó el texto? ¿Por qué OSC 52 sí funciona por SSH? |
| 6 | `set-clipboard` puede ser `off`, `external` u `on`. Usas nvim por SSH dentro de tmux y quieres que su `"+y` llegue a tu portátil. ¿Cuál eliges y por qué no basta el valor por defecto? |
| 7 | `set -sF copy-command "#{d:current_file}/bin/kit-copiar"` funciona desde `~/.config/tmux` y no hace nada si arrancas con `tmux -f tmux.conf`. ¿Qué vale la opción en cada caso y desde qué directorio se ejecuta el comando? |
| 8 | Un script lanzado con `run-shell` hace `printf '\033]52;c;...\a' >/dev/tty` y falla con `No such device or address`. ¿Por qué, y qué debe hacer en su lugar cuando corre dentro de tmux? |
| 9 | `osc52.sh` copia bien `hola` y no copia una línea de log de 200 caracteres. El script hace `printf '\033]52;c;%s\a' "$(base64)"`. ¿Qué falla y cómo lo arreglas de forma que también funcione en macOS? |
| 10 | Pegas un bloque de tres comandos en bash con `paste-buffer` y se ejecutan al instante; con `prefix` `]`, esperan a tu `Enter`. ¿Qué hace distinto `prefix` `]` y por qué importa? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Lo guarda tmux, por panel, en el servidor. La terminal solo recibe lo
que tmux dibuja en cada momento, en la pantalla alternativa, que no tiene
scrollback; y aunque lo tuviera, mezclaría todos los paneles y la barra de
estado. Se recorre en copy mode.

**2.** Si `mode-keys` no está fijada, tmux la deduce al arrancar el servidor:
`vi` si `$VISUAL` o `$EDITOR` contienen "vi", `emacs` si no. En tu máquina
`EDITOR=nvim`; en el servidor no hay `EDITOR`. `setw -g mode-keys vi` lo fija.

**3.** `history-limit` se lee al crear el panel: los que ya existen conservan
su límite (`#{history_limit}` lo muestra). Hay que abrir un panel o una
ventana nueva para tener 50000.

**4.** El texto está en un buffer de tmux, que solo existe en el servidor.
Falta llevarlo al portapapeles del sistema: con `copy-pipe` hacia una
herramienta (`copy-command` con `pbcopy`, `wl-copy`...) o con OSC 52, que
pide a la terminal que lo copie (`set-clipboard` y la capacidad `Ms`).

**5.** En el portapapeles X de la máquina remota, que nadie ve desde tu
portátil. OSC 52 es una secuencia de escape que viaja por el mismo canal que
el texto de la sesión: llega a tu terminal local por la conexión SSH, y es
tu terminal la que copia en tu portapapeles.

**6.** `on`. Con `external` (por defecto) tmux envía OSC 52 cuando copias en
copy mode, pero descarta el OSC 52 que envían los programas del panel, como
nvim. Con `on`, lo acepta y lo reenvía a la terminal exterior.

**7.** `current_file` es la ruta tal como se cargó el archivo. Desde
`~/.config/tmux` vale `/home/tú/.config/tmux/bin/kit-copiar`; con
`-f tmux.conf`, `./bin/kit-copiar`. El servidor ejecuta `copy-command` desde
tu `$HOME`, donde esa ruta relativa no existe. Solución: cargar la config con
ruta absoluta (`-f "$PWD/tmux.conf"`).

**8.** `run-shell` (igual que `copy-pipe`) ejecuta el comando sin terminal
de control: no hay `/dev/tty`. Dentro de tmux (`$TMUX` no vacío) el script
debe usar `tmux load-buffer -w -`: tmux guarda el texto y envía él el OSC 52
a la terminal exterior, si `set-clipboard` y `Ms` lo permiten.

**9.** `base64` parte la salida cada 76 caracteres. Con 200 caracteres la
secuencia lleva saltos de línea y la terminal la descarta o la trunca.
`base64 | tr -d '\n'` funciona en Linux y macOS; `base64 -w0` solo en GNU.

**10.** `prefix` `]` es `paste-buffer -p`: envuelve el texto en *bracketed
paste*, y la shell lo recibe como texto pegado, sin ejecutar cada línea al
llegar el salto. Te protege de ejecutar algo que no querías, como un `rm` en
una línea intermedia.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Moverte por el historial](2-practicas/lab-01-moverte-por-el-historial/README.md) | `mode-keys` fijado aunque `EDITOR=nano`; `history-limit` explicado en panel viejo y nuevo; búsqueda y `clear-history` | 10 |
| [02 — Seleccionar y copiar](2-practicas/lab-02-seleccionar-y-copiar/README.md) | Columna copiada en rectángulo; `v`, `C-v` e `y` como vim; `y`, `Enter` y el ratón copian a `copy-command` | 10 |
| [03 — Buffers](2-practicas/lab-03-buffers/README.md) | `buffer-limit` y buffers con nombre reproducidos; bracketed paste explicado; `guardar-buffers.sh` completo y limpio | 10 |
| [04 — capture-pane](2-practicas/lab-04-capture-pane/README.md) | `-S`, `-E`, `-J` y `-e` probados; `capturar.sh` valida con `list-panes` y termina en el prompt | 10 |
| [05 — Portapapeles del sistema](2-practicas/lab-05-portapapeles-del-sistema/README.md) | Problema de tu plataforma reproducido y resuelto; pruebas con `path-falso`; copias desde tmux y pegas fuera | 10 |
| [06 — Portapapeles roto](2-practicas/lab-06-portapapeles-roto/README.md) | Los cuatro errores explicados; `Ms` presente; `prefix` `Y` y textos largos funcionan | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 04`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `bin-completo-y-limpio`, que vale **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-mode-keys` — copy mode usa las teclas de vi | 3 |
| `conf-historial` — history-limit es de al menos 10000 líneas | 3 |
| `conf-set-clipboard` — set-clipboard está en on | 3 |
| `conf-copy-command` — copy-command apunta a bin/kit-copiar del kit | 3 |
| `conf-teclas` — v selecciona, C-v hace rectángulo e y copia con copy-pipe | 3 |
| `conf-de-punta-a-punta` — Copiar con y en copy mode llega al portapapeles | 3 |
| `kc-wayland` — En Wayland copia con wl-copy | 3 |
| `kc-wayland-sin-herramienta` — En Wayland sin wl-copy sale con 1 y dice qué instalar | 3 |
| `kc-wayland-sin-herramienta-rc` — En Wayland sin wl-copy el código de salida es 1 | 3 |
| `kc-xclip` — En X11 copia con xclip en CLIPBOARD, no en PRIMARY | 3 |
| `kc-xsel` — En X11 sin xclip usa xsel | 3 |
| `kc-macos` — En macOS copia con pbcopy | 3 |
| `kc-wsl` — En WSL copia con clip.exe | 3 |
| `kc-wsl-utf8` — En WSL prefiere win32yank.exe, que respeta la ñ | 3 |
| `kc-ssh` — Por SSH usa OSC 52 aunque haya herramientas locales | 3 |
| `kc-sin-grafico` — Sin entorno gráfico usa OSC 52 | 3 |
| `kc-dentro-de-tmux` — Dentro de tmux, OSC 52 pasa por load-buffer -w | 3 |
| `kc-uso` — Con argumentos, kit-copiar sale con 2 | 3 |
| `bin-completo-y-limpio` — Los scripts de bin/ no tienen TODOs y pasan shellcheck | 6 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Comentarios del porqué** | Explican `-F` y `current_file`, `set-clipboard on`, SSH antes que todo, `load-buffer -w`, `-selection clipboard` y la ñ de `clip.exe` | Repiten el código | 10 |
| **Mensajes de error** | Cada fallo dice qué instalar o qué pasó, por stderr, con los códigos 1 y 2 en la cabecera | Mensaje genérico | 8 |
| **Portabilidad** | Ninguna ruta a tu home; el kit funciona enlazado en `~/.config/tmux` y con `-f "$PWD/tmux.conf"` | Funciona solo en una de las dos | 8 |
| **Probado de verdad** | El README dice en qué plataforma probaste y, si tienes acceso, que copiaste por SSH | Solo el autograding | 6 |
| **README y bitácora** | `kit-copiar` en la tabla con ejemplo, la instalación con `ln -s` y la bitácora de la semana | Falta uno de los tres | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `kit-copiar` ejecuta el texto copiado (`eval`, `sh -c "$texto"`, `send-keys` sin `-l`) | −10 pts |
| `kit-copiar` usa una herramienta local por SSH en lugar de OSC 52 | −5 pts |
| Rutas absolutas a tu home dentro de `tmux-kit` | −5 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf` ni en `bin/`
- [ ] `./scripts/verificar-semana.sh 04` con las 19 comprobaciones en verde
- [ ] Commit `feat(week-04): ...` en tu `tmux-kit`

---

[← Volver a la Semana 04](README.md)
