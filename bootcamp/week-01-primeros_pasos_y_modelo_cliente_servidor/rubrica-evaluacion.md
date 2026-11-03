# Rúbrica de Evaluación — Semana 01

> Primeros pasos y modelo cliente-servidor. Se evalúan tres evidencias por
> separado, y hace falta **70% en cada una**. Saberte los atajos no compensa
> no saber por qué tu compilación siguió viva cuando cerraste la terminal.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `check-version` y `kit-tree`: 60 pts de autograding + 40 pts de calidad |

**Mínimo 70% en cada evidencia.** No en el promedio.

| Calificación | Rango |
|---|:--:|
| Sobresaliente | 90-100% |
| Notable | 80-89% |
| Aprobado | 70-79% |
| No aprobado | < 70% |

---

## 🧠 Conocimiento (30%)

Diez preguntas, 3 puntos cada una. No se pide recordar teclas: se pide
explicar por qué tmux se comporta así.

| # | Pregunta |
|:--:|---|
| 1 | Lanzas un `go test` de 40 minutos dentro de tmux, cierras la pestaña de la terminal y vuelves más tarde: los tests terminaron. ¿Qué proceso era el padre de `go test` y por qué no recibió el SIGHUP que mata a los trabajos de una terminal cerrada? |
| 2 | ¿Por qué `tmux -L lab kill-server` es seguro durante un lab y `tmux kill-server` a secas puede costarte trabajo? |
| 3 | Escribes `exit` en el único panel de tu única sesión y `tmux ls` responde `no server running`. ¿Por qué el servidor terminó si nadie lo mató? |
| 4 | `kit-tree` necesita saber si hay un servidor. ¿Por qué usa `list-sessions` y no `new-session -d` o `start-server` para comprobarlo? |
| 5 | Dos clientes miran la misma sesión desde terminales de tamaños distintos. ¿Por qué tmux no puede mostrarle a cada uno la ventana a su tamaño completo, y qué decide el tamaño que se usa? |
| 6 | Dentro de tmux, `tmux new -s otra` falla con `sessions should be nested with care`. ¿Cómo sabe tmux que estás dentro de él, y qué pasaría si dejara conectar un cliente de un servidor dentro de un panel de ese mismo servidor? |
| 7 | ¿Por qué un script debería apuntar a un panel por su id (`%3`) y no por su posición (`api:1.0`)? |
| 8 | `prefix` `c` y ejecutar `tmux new-window` desde otra shell producen lo mismo. ¿Por qué son equivalentes, y qué te permite eso que no te permiten los atajos? |
| 9 | `check-version` separa la versión en mayor y menor y las compara como números. Da un ejemplo concreto en el que comparar las versiones como texto da la respuesta equivocada. |
| 10 | El directorio `/tmp/tmux-<UID>/` tiene permisos `0700`. ¿Qué podría hacer otro usuario de la máquina si pudiera escribir en tu socket? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** El padre era la shell de un panel, y el padre de esa shell es el
**servidor** de tmux, no tu terminal. Al cerrar la pestaña, el SIGHUP llega a
la shell de la terminal y a sus trabajos; ahí solo vivía el **cliente** de
tmux, que muere. El servidor no depende de esa terminal y sus paneles siguen
corriendo.

**2.** `-L lab` habla con el servidor del socket `lab`, que solo tiene las
sesiones del lab. Sin `-L`, tmux usa el socket `default`: el de tus sesiones de
verdad, con todo lo que tengas abierto. `kill-server` cierra todas las sesiones
de ese servidor y sus programas sin preguntar.

**3.** El panel era el último. Al cerrarse su programa se cierra el panel, sin
paneles se cierra la ventana, sin ventanas la sesión, y un servidor sin
sesiones no tiene nada que guardar: termina solo (opción `exit-empty`, activa
por defecto).

**4.** `new-session` y `start-server` arrancan un servidor si no existe: el
script crearía justo lo que quería comprobar, y en el peor caso dejaría un
servidor vacío o una sesión basura. `list-sessions` solo pregunta: si no hay
servidor falla con `no server running` y no cambia nada.

**5.** Una ventana tiene un único tamaño, porque los programas de sus paneles
solo pueden dibujar a un tamaño a la vez. Con `window-size latest` (por
defecto) manda el cliente que se usó más recientemente; el otro ve el sobrante
relleno de puntos o la ventana recortada.

**6.** Por la variable de entorno `$TMUX`, que tmux define en cada panel (socket,
pid del servidor, sesión). Un cliente del mismo servidor dentro de un panel
suyo dibujaría la sesión dentro de sí misma: cada actualización provoca otra,
y las teclas no tienen un destino claro. Por eso tmux lo rechaza salvo que
borres `$TMUX` a propósito.

**7.** La posición cambia: si cierras el panel 0, el que era `api:1.1` pasa a
ser `api:1.0`; si renombras o mueves la ventana, también. El id `%3` no cambia
mientras el panel exista, así que el script sigue apuntando al panel correcto
aunque alguien reorganice la sesión mientras corre.

**8.** El atajo es solo una ligadura de la tabla `prefix` al comando
`new-window`; desde fuera ejecutas el mismo comando a través del socket. Eso
permite automatizar: scripts, `cron`, otros programas o tu `.bashrc` pueden
construir y consultar sesiones sin que nadie pulse teclas.

**9.** Como texto, `"3.10" < "3.9"` porque se compara carácter a carácter y
`1` < `9`. Un `check-version 3.9` rechazaría tmux 3.10, que es más nuevo. Lo
mismo con `3.5a`: como texto no es comparable con `3.5` sin quitar la letra.

**10.** Podría hablar con tu servidor como si fuera tú: crear ventanas,
mandar teclas a tus paneles con `send-keys` y, por tanto, ejecutar cualquier
comando con tus permisos, o leer lo que hay en tus paneles con `capture-pane`.
El socket es una puerta a tu shell.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.
Cada criterio de éxito se comprueba ejecutando el comando en tu equipo o en el
laboratorio.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Primera sesión](2-practicas/lab-01-primera-sesion/README.md) | tmux ≥ 3.4 comprobado; `first.sh` crea `primera` con la ventana `inicio` sin conectarte; explicas el `duplicate session` y el fin del servidor | 10 |
| [02 — Detach y attach](2-practicas/lab-02-detach-y-attach/README.md) | El contador siguió durante el detach; dos clientes en `list-clients`; `status.sh` cuenta clientes por sesión | 10 |
| [03 — Prefix y línea de comandos](2-practicas/lab-03-prefix-y-linea-de-comandos/README.md) | Ventana creada desde el prompt y desde fuera; `shortcuts.sh` imprime las 7 líneas; detach remoto con `detach-client` | 10 |
| [04 — Sesión, ventana, panel](2-practicas/lab-04-sesion-ventana-panel/README.md) | Estructura construida a mano; ids listados; `build.sh` imprime las 3 líneas exactas | 10 |
| [05 — Servidores y sockets](2-practicas/lab-05-servidores-y-sockets/README.md) | Dos servidores aislados; error de anidado reproducido y explicado; `servers.sh` distingue un socket vivo de uno huérfano | 10 |
| [06 — Sobrevivir a una desconexión](2-practicas/lab-06-sobrevivir-a-una-desconexion/README.md) | Log sin tmux detenido y log con tmux avanzando; sesión recuperada; `launch.sh` deja la tarea corriendo sin clientes | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 01`. Es binario: pasa o no pasa.

| Comprobación | Puntos |
|---|:--:|
| `cv-acepta-3-4` — check-version acepta tmux 3.4 | 4 |
| `cv-acepta-3-8` — check-version acepta tmux 3.8 | 3 |
| `cv-letra-de-parche` — acepta versiones con letra de parche como 3.5a | 4 |
| `cv-version-next` — acepta versiones de desarrollo como next-3.9 | 3 |
| `cv-compara-numeros` — compara números y no texto: 3.9 es menor que 3.10 | 5 |
| `cv-rechaza-3-2a` — sale con 1 ante tmux 3.2a | 4 |
| `cv-mensaje-util` — al rechazar, muestra la versión encontrada y la mínima | 3 |
| `cv-sin-tmux` — sale con 2 si tmux no está instalado | 4 |
| `cv-tmux-real` — acepta el tmux instalado | 2 |
| `tree-sin-servidor` — sin servidor, kit-tree sale con 1 y no arranca ninguno | 5 |
| `tree-socket` — kit-tree empieza con la ruta del socket | 3 |
| `tree-sesiones` — una línea por sesión | 4 |
| `tree-ventanas-y-clientes` — la línea de sesión dice cuántas ventanas y clientes tiene | 4 |
| `tree-ventanas-indentadas` — cada ventana bajo su sesión con índice, nombre y paneles | 4 |
| `tree-paneles` — cada panel bajo su ventana con índice e id | 4 |
| `bin-completo-y-limpio` — bin/ sin TODOs y limpio para shellcheck | 4 |
| **Total** | **60** |

### Calidad — 40 puntos

Lo que el autograding no puede ver.

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **README del kit** | Explica qué es, la versión mínima, cada script con un ejemplo y la bitácora de la semana | Lista los scripts sin ejemplos | 8 |
| **Mensajes de error** | Cada fallo dice qué pasó y qué hacer, por stderr, con el código de salida documentado | Mensaje genérico | 8 |
| **Comentarios del porqué** | Los comentarios explican decisiones (ids en vez de nombres, `list-sessions` en vez de `new-session`), no repiten el código | Comentarios que repiten el código | 8 |
| **Aislamiento** | Ningún comando de tmux sin pasar por `tmx`; `TMUX_BIN` y `TMUX_SOCKET` respetados en todo el script | Una llamada directa a `tmux` | 8 |
| **Git** | `tmux-kit` en un repositorio con al menos un commit con mensaje descriptivo | Sin historial | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |
| `kit-tree` crea sesiones o arranca un servidor | −10 pts |
| Rutas absolutas a tu home dentro de `tmux-kit` | −5 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/bin/` sin ningún `TODO`
- [ ] `./scripts/verificar-semana.sh 01` con las 16 comprobaciones en verde
- [ ] `tmux-kit` versionado con git

---

[← Volver a la Semana 01](README.md)
