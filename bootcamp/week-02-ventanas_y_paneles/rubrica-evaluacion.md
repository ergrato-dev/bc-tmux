# Rúbrica de Evaluación — Semana 02

> Ventanas y paneles. Se evalúan tres evidencias por separado, y hace falta
> **70% en cada una**. Partir paneles con soltura no compensa un script que
> apunta al panel equivocado.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `kit-layout`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Haces `cd ~/src/api` en un panel y pulsas `prefix` `%`. El panel nuevo empieza en otro directorio. ¿Por qué tmux no hereda el directorio del panel que partes, y cómo se lo pides? |
| 2 | Un script parte un panel y después titula `api:0.1`. A veces titula el panel equivocado. ¿Qué cambió entre el split y el título, y por qué el id que devuelve `-P -F '#{pane_id}'` no tiene ese problema? |
| 3 | ¿Por qué un script de tmux debe usar `split-window -d`? ¿Qué podría salir mal si el panel nuevo se vuelve el activo? |
| 4 | Lanzas `split-window` sin `-t` desde un script que ejecutas dentro de un panel de la sesión `notas`, y el panel aparece en `notas` aunque el script acababa de crear `api`. ¿Por qué? |
| 5 | Pones `main-pane-width 60%` después de `select-layout main-vertical` y el panel principal no cambia. ¿Por qué, y en qué orden van? |
| 6 | ¿Qué ventaja tiene `main-pane-width 60%` frente a `main-pane-width 120` cuando trabajas en un portátil y en un monitor grande? |
| 7 | Una cadena de layout guardada describe 4 paneles y la aplicas en una ventana de 3. ¿Por qué `kit-layout load` comprueba el número de paneles antes de llamar a `select-layout`? |
| 8 | `display-message -p -t api:nada '#{window_layout}'` sale con 0 e imprime un layout. ¿De qué ventana es, y cómo validas que un target existe? |
| 9 | Mueves un panel con un servidor de desarrollo corriendo de una ventana a otra con `join-pane`. ¿Por qué el servidor no se reinicia, y qué cambia del panel y qué no? |
| 10 | Un script envía a varios paneles un texto que viene de un archivo con `send-keys -t "$p" "$texto" Enter`. ¿Qué riesgo tiene, y por qué `send-keys -l -- "$texto"` más un `Enter` aparte lo evita? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Cada panel es un proceso nuevo que tmux arranca con el directorio de
inicio de la sesión; tmux no sigue los `cd` de tu shell salvo que se lo pidas.
Se lo pides con `split-window -c '#{pane_current_path}'`, que tmux lee del
proceso del panel actual en el momento del split.

**2.** Los índices dependen de la posición: al partir, los paneles que quedan a
la derecha o debajo se renumeran, y `api:0.1` puede pasar a ser otro panel. El
id (`%7`) se asigna al crear el panel y no cambia mientras exista, así que el
título siempre va al panel que el script creó.

**3.** Sin `-d`, el panel nuevo se vuelve el activo, y cualquier comando
posterior sin `-t` (o un `-t` con la ventana) actúa sobre él. Con `-d` el foco
no cambia: el resultado no depende del orden en que el script crea los paneles,
y si alguien está conectado, no ve saltar el cursor.

**4.** Sin `-t`, tmux usa como objetivo el panel de `$TMUX_PANE`: el panel
desde el que se ejecuta el comando. Crear `api` no cambia eso. Un script debe
apuntar siempre con `-t` y un id.

**5.** `main-pane-width` se lee al calcular el layout, no después. Ponerla tarde
solo cambia la opción para el siguiente `select-layout`. Orden: primero la
opción, después `select-layout`.

**6.** El porcentaje se recalcula según el ancho de la ventana: el panel
principal mide el 60 % en las dos pantallas. Con 120 celdas fijas, en el
portátil puede ocupar casi todo y dejar los demás paneles sin espacio, y en el
monitor grande se queda corto.

**7.** tmux 3.4 no siempre rechaza un layout con otro número de paneles:
`select-layout` puede salir con 0 sin aplicar lo que esperabas o aplicándolo a
medias. Comprobarlo antes da un error claro y deja la ventana como estaba.

**8.** De otra ventana: con un target que no existe, `display-message` usa la
ventana actual o la más reciente y sale con 0. `list-panes -t api:nada` sí
falla, así que es la forma de validar antes de leer.

**9.** `join-pane` mueve el panel, no lo recrea: el proceso y su terminal
virtual siguen siendo los mismos y solo cambian de ventana. Conserva el id y el
programa; cambia su índice, su ventana y su tamaño.

**10.** Sin `-l`, `send-keys` interpreta palabras como `C-c`, `Enter` o `Escape`
como teclas: un texto puede interrumpir programas o ejecutar líneas que no
pediste. Con `-l` todo es texto literal, `--` evita que un texto que empieza
por `-` se lea como opción, y el único `Enter` es el que decide el script.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Split y navegación](2-practicas/lab-01-split-y-navegacion/README.md) | Te mueves con flechas, `o`, `;` y `q`; muestras la diferencia con `-c`; títulos en el borde; `tres.sh` imprime las 3 líneas | 10 |
| [02 — Resize y zoom](2-practicas/lab-02-resize-y-zoom/README.md) | Resize repetible; `-x 30` exacto; `window_zoomed_flag` comprobado; `ajustar.sh` ajusta y rechaza 95 con código 2 | 10 |
| [03 — Layouts](2-practicas/lab-03-layouts/README.md) | Los cinco layouts; principal al 60 %; explicas la cadena de layout; `layout.sh` restaura un layout hecho a mano | 10 |
| [04 — Mover paneles y ventanas](2-practicas/lab-04-mover-paneles-y-ventanas/README.md) | El contador sobrevive a `join-pane` y `break-pane`; panel marcado; `reorganizar.sh` imprime las 2 líneas | 10 |
| [05 — Sincronizar paneles](2-practicas/lab-05-sincronizar-paneles/README.md) | Comando en los tres paneles con `synchronize-panes`; `difundir.sh` envía texto literal con `-l` | 10 |
| [06 — La ventana rota](2-practicas/lab-06-ventana-rota/README.md) | Los cuatro errores explicados; el script corre dentro de tmux sin tocar `otra`; ningún `-t` con índices | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 02`. Es binario: pasa o no pasa.

| Comprobación | Puntos |
|---|:--:|
| `new-crea-sesion` — kit-layout new crea la sesión si no existe | 4 |
| `tres-paneles` — la ventana trabajo tiene tres paneles | 4 |
| `titulos` — los paneles se titulan editor, shell y logs | 4 |
| `editor-izquierda` — el editor ocupa la columna izquierda con un 55-65 % del ancho | 4 |
| `shell-sobre-logs` — shell y logs se apilan a la derecha, shell arriba | 4 |
| `editor-activo` — el panel activo al terminar es el editor | 3 |
| `directorio` — los tres paneles empiezan en el directorio indicado | 4 |
| `sesion-existente` — en una sesión existente, añade la ventana sin tocar las demás | 4 |
| `no-duplica-falla` — si la ventana trabajo ya existe, sale con 1 | 4 |
| `no-duplica-ventana` — tras dos ejecuciones sigue habiendo una sola ventana trabajo | 3 |
| `save-formato` — save escribe un layout de tmux válido | 4 |
| `load-restaura` — load devuelve la ventana al layout guardado | 5 |
| `load-rechaza-paneles` — load sale con 1 si el número de paneles no coincide | 4 |
| `save-ventana-inexistente` — save sale con 1 si la ventana no existe | 3 |
| `uso` — sin argumentos sale con 2 | 2 |
| `bin-completo-y-limpio` — bin/ sin TODOs y limpio para shellcheck | 4 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Solo ids** | Ningún `-t` con índices de panel después de partir; cada panel nuevo se guarda con `-P -F '#{pane_id}'` | Un índice en un sitio donde no se renumera | 10 |
| **Mensajes de error** | Cada fallo dice qué pasó y qué hacer, por stderr, con los códigos 1 y 2 documentados | Mensaje genérico | 8 |
| **Comentarios del porqué** | Explican `-d`, los ids, la validación con `list-panes` y el conteo de paneles | Repiten el código | 8 |
| **Layout propio** | Un layout tuyo guardado en el kit y documentado en el README con el comando para cargarlo | Guardado sin documentar | 6 |
| **README y bitácora** | `kit-layout` en la tabla con ejemplo y la bitácora de la semana escrita | Falta uno de los dos | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |
| `kit-layout new` conecta un cliente o cambia la ventana activa de otra sesión | −5 pts |
| Rutas absolutas a tu home dentro de `tmux-kit` | −5 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/bin/` sin ningún `TODO`
- [ ] `./scripts/verificar-semana.sh 02` con las 16 comprobaciones en verde
- [ ] Commit `feat(week-02): ...` en tu `tmux-kit`

---

[← Volver a la Semana 02](README.md)
