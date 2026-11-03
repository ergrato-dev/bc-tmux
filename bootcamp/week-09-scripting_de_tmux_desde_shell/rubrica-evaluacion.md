# Rúbrica de Evaluación — Semana 09

> Scripting de tmux desde shell. Se evalúan tres evidencias por separado, y
> hace falta **70% en cada una**. Un `dev-up` que funciona en la demo pero
> crea ventanas duplicadas al relanzarlo, o que teclea un nombre sin escapar,
> no compensa nada.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `bin/dev-up` y `bin/dev-down`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Tu script hace `tmux new-session -s api` y funciona desde la terminal, pero desde un `cron` o un hook falla con `open terminal failed: not a terminal`. ¿Por qué, y qué cambia `-d`? |
| 2 | ¿Por qué el script guarda el `%id` que imprime `split-window -P -F '#{pane_id}'` en vez de apuntar luego a `api:1.1`? Da un caso en que el índice apunte a otro panel. |
| 3 | Con solo `api-2` abierta, `has-session -t api` sale con 0. ¿Qué hace tmux con ese target, qué decide entonces tu script y qué pasaría con `kill-session -t api`? |
| 4 | Un compañero valida el target con `tmux display -p -t "$t" '#{pane_id}' >/dev/null && echo existe`. ¿Por qué siempre dice "existe", y qué usas en su lugar? |
| 5 | `send-keys -t %1 "tail -n 3 $f" Enter` funciona con todos tus logs hasta que llega uno que se llama `viejo;touch PWNED`. ¿Qué pasa, quién ejecuta el `touch` y qué dos cosas lo evitan? |
| 6 | ¿Por qué el `Enter` va en un `send-keys` aparte cuando el texto se envía con `-l`? ¿Qué llega al panel si lo metes dentro del texto? |
| 7 | Tu script lanza `make` en un panel y luego hace `sleep 10` antes de leer el resultado. ¿Qué dos problemas tiene, y cómo los resuelven `wait-for` y `timeout`? |
| 8 | El panel envía `wait-for -S hecho` medio segundo antes de que tu script llegue a `wait-for hecho`. ¿Se queda el script esperando para siempre? ¿Por qué? |
| 9 | `new-session -A -d -s api` parece la forma idempotente de "crear o reutilizar". ¿Por qué falla en un script cuando la sesión ya existe, y con qué lo sustituyes? |
| 10 | Tu script crea las ventanas `editor`, `run` y `logs`. ¿Qué tiene que comprobar para que lanzarlo dos veces no deje seis, y por qué por nombre y no contando ventanas o mirando índices? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Sin `-d`, `new-session` crea la sesión y además conecta un cliente a
ella, y un cliente necesita una terminal donde dibujar. Desde la terminal la
hay; desde `cron`, un hook o un pipe no, y el comando falla. Con `-d` la
sesión nace sin cliente, el comando vuelve en el acto y el script sigue; ya te
conectarás después con `attach` o `switch-client`.

**2.** El índice describe la posición de hoy: cambia si alguien mueve o
borra una ventana, si `renumber-windows` renumera, si `base-index` no es 0 en
la config del usuario o si un `split` o `swap-pane` reordena los paneles. El
`%id` lo asigna tmux al crear el panel y no cambia hasta que el panel
desaparece. Ejemplo: cierras la ventana 0 con `renumber-windows on` y la que
era `api:1` pasa a ser `api:0`; `api:1.1` ya es otro panel, o ninguno.

**3.** Sin `=`, tmux busca primero el nombre exacto y, si no lo hay, acepta
una sesión cuyo nombre empiece por `api`: encuentra `api-2`. El script cree
que `api` ya existe y no la crea nunca, y lo que haga después (ventanas,
`send-keys`) cae en `api-2`. `kill-session -t api` cerraría `api-2`. Con
`-t "=api"` solo casa el nombre exacto.

**4.** `display -p -t X` no falla cuando `X` no existe: sale con 0 e imprime
campos vacíos o los de otro objeto (la ventana actual, otra ventana de la
sesión). La condición es siempre verdadera. `list-panes -t X` sí sale con 1
y dice `can't find ...`, también cuando la sesión existe pero la ventana o el
panel no.

**5.** `send-keys` teclea el texto en la shell del panel como si lo
escribieras tú, y esa shell lo interpreta: el `;` termina `tail` y empieza
`touch PWNED`, que ejecuta la shell del panel con tus permisos. tmux no
ejecuta nada; la shell sí. Se evita escapando el valor antes
(`printf -v line 'tail -n 3 -- %q' "$f"`) y enviándolo con `-l --` para que
ningún trozo se interprete como tecla ni como opción.

**6.** Con `-l`, todo el texto va literal: un `Enter` o un `C-c` dentro de él
llegan como esas letras, no como teclas, y el panel se queda con la línea a
medio escribir mostrando `... Enter`. El `Enter` aparte, sin `-l`, es la
única palabra que tmux busca como nombre de tecla. Separar las dos llamadas
deja claro qué es texto y qué es tecla.

**7.** Si `make` tarda más de 10 s, lees un resultado a medias; si tarda 1 s,
pierdes 9 en cada ejecución. Y el `sleep` no te da el código de salida.
`wait-for` bloquea justo hasta que el panel envía la señal al terminar (y el
panel puede guardar antes `$?` en una opción `@`), y `timeout` pone el
límite: si el comando se cuelga, el script no se queda esperando y sale con
124, un error distinguible.

**8.** No. Si nadie está esperando cuando llega `wait-for -S`, tmux guarda la
señal en el canal, y el siguiente `wait-for` de ese canal vuelve en el acto.
Por eso no hay carrera entre teclear el comando y empezar a esperar, aunque
el comando del panel sea instantáneo.

**9.** `-A` convierte `new-session` en `attach-session` si la sesión existe,
y conectar necesita una terminal aunque pongas `-d`: falla con `open terminal
failed: not a terminal` y rc 1. La primera ejecución funciona (la sesión no
existía) y la segunda falla, justo lo contrario de idempotente. Se sustituye
por `has-session -t "=api" 2>/dev/null || new-session -d -s api ...`.

**10.** Tiene que leer `list-windows -t "=api" -F '#{window_name}'` y crear
cada ventana solo si su nombre no está. Contar ventanas falla en cuanto el
usuario abre una suya o cierra `logs` (hay 3, pero no las tuyas); los índices
dependen de `base-index`, de `renumber-windows` y del orden en que se
crearon. El nombre es lo que el script define y lo que quiere encontrar, y
así una segunda ejecución recrea solo lo que falte.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Crear sin conectarse](2-practicas/lab-01-crear-sin-conectarse/README.md) | Sesión con ventanas y paneles creada con `-d`, `-c` y `-x`/`-y` sin conectarse; ids capturados con `-P -F` y usados como target; `attach` después comprobado | 10 |
| [02 — Consultar con formatos](2-practicas/lab-02-consultar-con-formatos/README.md) | Estado del servidor leído con `list-* -F` y `-f` y recorrido con `while read -r`; `display -p` frente a `list-panes` con un target inexistente, comprobado y explicado | 10 |
| [03 — Enviar teclas con cuidado](2-practicas/lab-03-enviar-teclas-con-cuidado/README.md) | Texto enviado con `-l` y `Enter` aparte; inyección con un nombre hostil demostrada y evitada con `%q`; panel ocupado recuperado con `respawn-pane -k` | 10 |
| [04 — Esperar con wait-for](2-practicas/lab-04-esperar-con-wait-for/README.md) | Comando de un panel esperado con `wait-for` sin `sleep`; límite con `timeout` (124) comprobado; código de salida del panel recuperado | 10 |
| [05 — Idempotencia](2-practicas/lab-05-idempotencia/README.md) | Sesión y ventanas creadas solo si faltan, por nombre exacto; `list-windows -F` igual antes y después de la segunda ejecución; `api` frente a `api-2` comprobado | 10 |
| [06 — Script roto](2-practicas/lab-06-script-roto/README.md) | Los cinco fallos de `team-up` provocados, explicados y corregidos; el script arreglado pasa con el servidor ocupado | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 09`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `dev-up-hostil`, `dev-up-idempotente`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `dev-up-uso` — dev-up sin argumentos sale con 2 | 3 |
| `dev-up-dir-no-existe` — dev-up con un directorio que no existe sale con 1 y lo dice | 3 |
| `dev-up-nombre-invalido` — dev-up con un NAME que lleva . o : sale con 2 | 3 |
| `dev-up-nombre-saneado` — Con DIR mi.app, dos ejecuciones dejan una sola sesión mi_app | 3 |
| `dev-up-nombre-explicito` — dev-up DIR NAME llama NAME a la sesión | 3 |
| `dev-up-ventanas` — dev-up crea las ventanas editor, run y logs, en ese orden | 3 |
| `dev-up-directorio` — Todos los paneles de la sesión arrancan en DIR | 3 |
| `dev-up-idempotente` — Ejecutar dev-up dos veces no duplica sesiones ni ventanas | 6 |
| `dev-up-recrea-ventana` — Si cierras la ventana logs, dev-up la vuelve a crear | 3 |
| `dev-up-prefijo` — Con una sesión api-2 abierta, dev-up crea api igualmente | 3 |
| `dev-up-hostil` — Un directorio con $(...) en el nombre no ejecuta nada | 6 |
| `dev-up-tmux-kit` — La línea run: de .tmux-kit se ejecuta en la ventana run | 3 |
| `dev-up-tmux-kit-una-vez` — Volver a ejecutar dev-up no reenvía los comandos de .tmux-kit | 3 |
| `dev-down-uso` — dev-down sin argumentos sale con 2 | 3 |
| `dev-down-cierra` — dev-down api cierra la sesión api y deja api-2 | 3 |
| `dev-down-prefijo` — Sin sesión api, dev-down api sale con 1, lo dice y no cierra api-2 | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Idempotencia de verdad** | Cada objeto se crea solo si falta; la segunda ejecución no crea, no reenvía y no cambia la ventana actual | Idempotente, pero reenvía comandos o cambia de ventana | 8 |
| **Targets sin sorpresas** | `=` en todo comando de sesión, ids de panel de `-P -F` para `send-keys`, ningún índice escrito a mano | Falta `=` en algún comando | 8 |
| **Nada externo llega a una shell** | Rutas con `-c`, comandos con `send-keys -l`, `.tmux-kit` con `read -r` (sin `eval`, `source` ni `bash -c`) | Algún dato externo sin citar | 8 |
| **Comentarios del porqué** | Explican el `=`, sanear antes que tmux, `send-keys` frente al comando de `new-window`, por qué no `new-session -A`, `switch-client` frente a `attach` | Repiten el código | 8 |
| **Cabecera, errores y README** | Uso y códigos de salida en la cabecera, errores por stderr con el nombre del script, README con `## Proyectos` y la bitácora | Falta uno | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `eval`, `source` o `bash -c` sobre el contenido de `.tmux-kit` | −10 pts |
| `has-session` o `kill-session` sin `=` | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/`, `bin/` ni `docs/`
- [ ] `./scripts/verificar-semana.sh 09` con todas las comprobaciones en verde
- [ ] Commit `feat(week-09): ...` en tu `tmux-kit`

---

[← Volver a la Semana 09](README.md)
