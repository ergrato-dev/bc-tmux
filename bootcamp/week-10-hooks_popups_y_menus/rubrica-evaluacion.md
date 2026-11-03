# Rúbrica de Evaluación — Semana 10

> Hooks, popups y menús. Se evalúan tres evidencias por separado, y hace
> falta **70% en cada una**. Un menú vistoso no compensa un hook que se
> duplica al recargar ni un prompt que ejecuta lo que escribes.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `bin/kit-log`, `bin/kit-projects` y `conf.d/50-hooks-popups.conf`: 60 pts de autograding + 40 pts de calidad |

**Mínimo 70% en cada evidencia.** No en el promedio.

| Calificación | Rango |
|---|:--:|
| Sobresaliente | 90-100% |
| Notable | 80-89% |
| Aprobado | 70-79% |
| No aprobado | < 70% |

---

## 🧠 Conocimiento (30%)

Diez preguntas, 3 puntos cada una. Se pide explicar por qué, no recordar sintaxis.

| # | Pregunta |
|:--:|---|
| 1 | Tu config tiene `set-hook -ga after-new-window '...'`. Tras recargarla tres veces, cada ventana nueva ejecuta el comando cuatro veces. ¿Por qué, y qué dos formas hay de que recargar no cambie nada? |
| 2 | En `after-split-window` guardas `#{hook_pane}` para saber qué panel se creó y la opción queda vacía. ¿Por qué, qué usas en su lugar y cómo lo compruebas? |
| 3 | Un hook `after-new-window` con `new-window -d` crea una sola ventana extra, pero con `run-shell "tmux new-window -d"` no para nunca. ¿Qué diferencia hay entre los dos para el servidor? |
| 4 | Con `bind b run-shell 'sleep 3'`, pulsar `prefix` `b` y luego `prefix` `c` tarda tres segundos en crear la ventana. ¿Por qué, adónde va la salida de ese `run-shell` y qué cambia `-b`? |
| 5 | `display-popup 'ls'` deja el popup abierto y `q` no lo cierra. ¿Por qué? ¿Cuándo eliges `-E` y cuándo `-EE`, y por qué un script que lanza el popup no sigue hasta que lo cierras? |
| 6 | En 3.4, `bind y display-popup -E 'echo #{session_name}; read -r'` muestra `#{session_name}` literal. ¿Por qué, cómo obtienes el nombre desde dentro, y por qué preguntarlo desde dentro es además más seguro que pegarlo en el comando? |
| 7 | Una entrada de tu menú es `'Info' i 'display-message "sesión #{session_name}"'`. ¿Cuándo se expande ese format, y qué pasa al pulsar `i` en una sesión llamada `x"; set -g @pwn si; set -g @z "`? |
| 8 | `command-prompt "rename-window '%%'"` y `command-prompt { rename-window "%%" }` parecen iguales. Escribes `x"; set -g @pwn si; set -g @z "`: ¿por qué el primero ejecuta `set -g @pwn si` y el segundo no? |
| 9 | Tu interruptor de log hace `pipe-pane -o "cat >> '$dir/#{session_name}.log'"`. ¿Qué le pasa a un `#` de `$dir`, y qué hace una sesión llamada `a'$(touch x)'b`? ¿Cómo lo evitas? |
| 10 | Tu selector con fzf cambia de sesión con `switch-client -t "=$nombre"`. ¿Con qué nombre falla, por qué el id (`$3`) no, y por qué cancelar con `Esc` no debe ser un error del script? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Un hook es una opción de tipo lista. `-a` añade una entrada al final
cada vez que se ejecuta la línea, así que la config cargada al arrancar más
tres recargas deja cuatro entradas iguales, `[0]` a `[3]`, y tmux las ejecuta
todas. Se arregla con un índice fijo (`set-hook -g 'after-new-window[10]' ...`),
que sustituye siempre la misma entrada, o borrando antes con
`set-hook -gu after-new-window`. El índice fijo es mejor: no toca hooks que
haya puesto otro archivo.

**2.** En `after-split-window` lanzado desde una tecla o la línea de
comandos, `#{hook_pane}` sale vacío: tmux no lo rellena para este hook. El
hook se ejecuta con el panel nuevo como actual, así que `#{pane_id}` es el
que se acaba de crear. Se comprueba con `split-window -P -F '#{pane_id}'` y
`show -gv` de la opción que guarda el hook: los dos imprimen el mismo `%N`.

**3.** Un comando escrito directamente en el hook lo ejecuta el servidor
mientras procesa el hook, y no dispara hooks: hay una ventana extra y se
acaba. `run-shell "tmux new-window -d"` lanza una shell, y el `tmux` de
dentro es un cliente nuevo que manda `new-window` al servidor como cualquier
otro comando: dispara `after-new-window`, que lanza otro `tmux`, y así sin
fin.

**4.** `run-shell` sin `-b` espera a que la shell termine, y mientras tanto
el cliente que pulsó la tecla no procesa las siguientes: `prefix` `c` se
queda en cola tres segundos. Su salida no vuelve a ningún sitio visible
salvo el modo vista del panel activo, que se cierra con `q`. Con `-b` la
shell corre en segundo plano y la tecla vuelve en el acto.

**5.** Sin `-E` el popup se queda abierto cuando el comando termina, para que
leas la salida. No hay programa dentro que reciba la `q`; solo `Escape`
(o `display-popup -C`) lo cierra. `-E` lo cierra al terminar el comando,
salga como salga; `-EE` solo si sale con 0, para que un error quede a la
vista. Popup, menú, prompt y confirmación esperan a que se cierren: el
comando que los lanzó no vuelve hasta entonces.

**6.** En 3.4 el comando de `display-popup` no pasa por los formats: llega a
la shell tal cual. Dentro del popup está `$TMUX`, así que
`tmux display -p '#{session_name}'` le pregunta al mismo servidor. Además es
más seguro: lo que devuelve es un dato que se imprime o se cita, nunca texto
que se pega en una línea de comandos y se vuelve a parsear.

**7.** Los nombres y comandos de un menú se expanden **al abrirlo**, y el
comando resultante se parsea después como texto. El nombre se pega dentro de
las comillas: `display-message "sesión x"; set -g @pwn si; set -g @z ""`.
El `"` del nombre cierra la cadena, el `;` separa comandos y
`set -g @pwn si` se ejecuta. Por
eso ningún `#{session_name}` va dentro de un comando de menú: se actúa sobre
la sesión actual sin nombrarla o se usa un script que la pregunta.

**8.** Con la plantilla como texto, tmux sustituye `%%` por lo que escribiste
y vuelve a parsear la cadena entera: las comillas y el `;` que tecleaste son
sintaxis, y las comillas de la plantilla no protegen nada. Entre llaves la
plantilla ya está parseada: lo escrito entra como valor del argumento de
`rename-window` y no se vuelve a leer como comando. La ventana se llama,
literal, `x"; set -g @pwn si; set -g @z "`.

**9.** El comando de `pipe-pane` se expande como format antes de ir a la
shell: un `#` de la ruta empieza un format y hay que escribirlo `##`, y
`#{session_name}` se sustituye por el nombre. La `'` del nombre cierra la
comilla simple, `$(touch x)` queda fuera y la shell lo ejecuta. Se evita
saneando el nombre (solo letras, cifras, `_` y `-`) o escapando cada `'` como
`'\''` y cada `#` como `##` antes de construir el comando.

**10.** Falla con un nombre que empieza por `$`: `-t "=\$x"` no encuentra la
sesión (`can't find session`), porque tmux lee el `$` como un id. Un id como
`$3` es único, no depende de lo que el usuario escriba ni de prefijos, y no
se reinterpreta. Cancelar fzf con `Esc` sale con 130: es la forma normal de
decir "no quiero nada", y si el script lo trata como error, el popup con
`-EE` se queda abierto con un fallo que no lo es. Cancelar sale con 0 y no
cambia de sesión.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Hooks](2-practicas/lab-01-hooks/README.md) | Hook con índice fijo que queda una sola vez tras dos recargas; `session-created` guarda la sesión nueva; `after-split-window` con `#{pane_id}` frente a `#{hook_pane}` comprobado; `-u` de una entrada frente a `-u` de todas explicado; `client-attached` muestra el mensaje | 10 |
| [02 — Popups](2-practicas/lab-02-popups/README.md) | `q` frente a `Escape` explicado; `display-popup -E 'exit 4'` devuelve 4; `#{session_name}` literal explicado y resuelto desde dentro con `popup-info.sh`; `prefix` `y` y `prefix` `u` abren y cierran sus popups | 10 |
| [03 — Menús y prompts](2-practicas/lab-03-menus-y-prompts/README.md) | Menú propio que crea y se cierra con `q`; inyección con `"%%"` en plantilla de texto demostrada y explicada; plantilla entre llaves que deja `@pwn` sin crear; menú de `prefix` `K` y confirmación de `prefix` `k` funcionando | 10 |
| [04 — run-shell y pipe-pane](2-practicas/lab-04-run-shell-y-pipe-pane/README.md) | Salida de `run-shell` y su modo explicados; `-b` que no bloquea `prefix` `c`; `pane-log.sh` rechaza `%99` con 1, crea el log de `a b;c` sin ejecutar nada y alterna `log on`/`log off`; `prefix` `H` alterna el log | 10 |
| [05 — fzf en un popup](2-practicas/lab-05-fzf-en-un-popup/README.md) | `pick-session.sh -l` lista con ids; cambio por id explicado; la sesión `$(touch …)` se elige sin ejecutar nada; sin fzf repite la pregunta y acaba en `lab`; `prefix` `O` abre el selector y `Escape` lo cierra sin cambiar | 10 |
| [06 — Hooks rotos](2-practicas/lab-06-hooks-rotos/README.md) | Los cinco fallos (hook duplicado, hook recursivo, popup sin `-E`, prompt con plantilla de texto, `run-shell` que bloquea) provocados, explicados y corregidos | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 10`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `hooks-sin-duplicar`, `kit-projects-hostil`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `hook-client-attached` — Al conectarse un cliente, un hook muestra un mensaje | 3 |
| `hooks-sin-duplicar` — Recargar la config dos veces no duplica los hooks del kit | 6 |
| `kit-log-on` — kit-log PANEL guarda lo que sale en el panel en SESION-VENTANA-PANEL.log | 3 |
| `kit-log-off` — kit-log dos veces sobre el mismo panel cierra el log | 3 |
| `kit-log-hostil` — Un XDG_STATE_HOME con comillas, # y $(...) no ejecuta nada | 3 |
| `kit-log-panel-no-existe` — kit-log con un panel que no existe sale con 1 y lo dice | 3 |
| `hook-autolog` — Con @kit-autolog on, las ventanas y los paneles nuevos empiezan con log | 3 |
| `kit-projects-lista` — kit-projects -l lista los subdirectorios de @kit-projects-dir en orden, sin ocultos ni archivos | 3 |
| `kit-projects-tilde` — Con el @kit-projects-dir por defecto, kit-projects -l lista ~/src | 3 |
| `kit-projects-sin-dir` — Con un @kit-projects-dir que no existe, kit-projects -l sale con 1 y lo dice | 3 |
| `kit-projects-abre` — kit-projects -d api abre el proyecto api con dev-up | 3 |
| `kit-projects-no-listado` — kit-projects -d .. sale con 1 y no crea ninguna sesión | 3 |
| `kit-projects-hostil` — Un proyecto con $(...) en el nombre no ejecuta nada | 6 |
| `popup-proyectos` — prefix P abre kit-projects en un popup que se cierra al terminar | 3 |
| `menu-confirma` — El menú del kit (prefix K) cierra la sesión solo tras confirmar | 3 |
| `teclas-con-nota` — prefix P y prefix K llevan nota kit: | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Hooks idempotentes** | Índice fijo (o `-u` antes), ningún `set-hook -ga`; el autolog decide con `if -F`, no con una shell | Fijos, pero deciden con `run-shell` | 6 |
| **Nada externo llega a tmux como código** | Ruta del log con `##` y `'\''`, proyectos como argumentos de `dev-up`, ningún `#{session_name}` en un comando del menú, ningún `command-prompt` con plantilla de texto | Algún dato externo sin escapar | 10 |
| **Popups que se comportan** | `-EE` donde un fallo debe verse, sin `-E` donde hay que leer; la ruta del kit preguntada desde dentro | Un popup que se cierra antes de leerlo | 6 |
| **Comentarios del porqué** | Explican el índice `[50]`, `#{pane_id}` frente a `#{hook_pane}`, `list-panes` para validar, `run-shell` sin `-b`, `prefix K` y no `M` | Repiten el código | 8 |
| **Scripts y README** | `kit-projects` sin fzf, cancelar no es error, cabecera con códigos, errores por stderr, README con teclas, hooks, aviso del log y bitácora | Falta uno | 10 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `set-hook -ga` en la config (se duplica al recargar) | −5 pts |
| `#{session_name}` o un nombre externo dentro del comando de un menú o prompt | −10 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/` ni `bin/`
- [ ] `./scripts/verificar-semana.sh 10` con todas las comprobaciones en verde
- [ ] Commit `feat(week-10): ...` en tu `tmux-kit`

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Proyecto — tmux-kit: popup de proyectos, menú y log de paneles](3-proyecto/README.md) | [Recursos — ebooks](4-recursos/ebooks-free/README.md) → |

[↑ Semana 10](README.md)
