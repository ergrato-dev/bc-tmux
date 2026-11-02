# Rúbrica de Evaluación — Semana 03

> Sesiones, targets y sockets. Se evalúan tres evidencias por separado, y hace
> falta **70% en cada una**. Saltar rápido entre sesiones no compensa un
> script que cierra la sesión equivocada.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `sesiones`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Tienes `api-vieja` y ya cerraste `api`. Un script ejecuta `tmux kill-session -t api`. ¿Qué pasa y por qué? ¿Qué cambia con `-t =api`? |
| 2 | Con `api-2` y `api-3`, `tmux has-session -t api` falla; con solo `api-2`, sale con 0. ¿Por qué el mismo comando da resultados distintos? |
| 3 | ¿Por qué dentro de tmux se usa `switch-client` y no `attach-session` para ir a otra sesión? |
| 4 | Un script crea una sesión con el nombre de un directorio, `web.app`, y después no la encuentra. ¿Qué hizo tmux con el nombre y cómo se lee el target `web.app`? |
| 5 | `display-message -p -t api:9 '#{window_index}'` imprime `0` y sale con 0 aunque la ventana 9 no existe. ¿Qué comando usarías para validar el target antes y por qué? |
| 6 | Dos clientes en la misma sesión frente a dos sesiones del mismo grupo: ¿qué comparten y qué no? Da un caso en el que elegirías cada uno. |
| 7 | `sesiones` marca la sesión actual solo si `${TMUX%%,*}` coincide con `#{socket_path}`. ¿Qué marcaría mal si solo comprobara que `$TMUX` no está vacío? |
| 8 | Algo borró `/tmp/tmux-1000/default` mientras trabajabas. `tmux ls` dice que no puede conectar. ¿Perdiste tus sesiones? ¿Cómo vuelves a entrar? |
| 9 | ¿Qué diferencia hay entre `tmux -L par` y `tmux -S /tmp/par`, y por qué el segundo exige pensar en los permisos del archivo? |
| 10 | `sesiones nueva api` crea la sesión solo si no existe y después salta a ella. ¿Por qué es mejor que `new-session -A -s api` dentro de un script que también tiene que funcionar dentro de tmux? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** `api` no existe, así que tmux busca sesiones que empiecen por `api`: solo
hay una, `api-vieja`, y la cierra sin avisar. Con `=api` solo vale el nombre
exacto: no existe, el comando falla y no se cierra nada.

**2.** Tras no encontrar el nombre exacto, tmux reúne las sesiones que empiezan
por `api` (o encajan como patrón). Con una sola candidata la usa; con dos, el
target es ambiguo y falla. El resultado depende de qué otras sesiones existan,
justo lo que un script no controla.

**3.** `attach-session` crea un cliente nuevo que dibuja una sesión en la
terminal actual. Dentro de tmux esa terminal es un panel: el cliente quedaría
dibujado dentro del propio servidor, y tmux lo rechaza (`sessions should be
nested with care`). `switch-client` cambia de sesión el cliente que ya existe.

**4.** tmux cambia `.` y `:` por `_` y crea `web_app`. El target `web.app` se lee
como sesión `web`... y panel `app` (el punto separa ventana y panel), así que
`has-session -t =web.app` no la encuentra. Hay que convertir el nombre antes
de crear y de buscar.

**5.** `list-panes -t api:9` (o `has-session` para sesiones): falla si el target
no existe. `display-message` resuelve un target inexistente usando otro objeto
y sale con 0, así que no sirve para validar.

**6.** Dos clientes en una sesión comparten todo, incluida la ventana actual:
útil para enseñar algo a otra persona que mira lo mismo que tú. Un grupo
comparte las ventanas pero cada sesión tiene su ventana actual: útil para dos
monitores o para que dos personas trabajen en ventanas distintas del mismo
proyecto.

**7.** Si estás dentro de tmux en el servidor `default` y el script lista el
servidor `lab`, `$TMUX` no está vacío pero no habla de `lab`. `display-message`
contra `lab` no encontraría tu panel y devolvería la sesión más reciente de
`lab`: marcaría como actual una sesión en la que no estás.

**8.** No: el servidor y sus sesiones siguen vivos, solo falta la puerta.
`kill -USR1 PID_DEL_SERVIDOR` le pide que recree el socket. El pid sale de
`ps` o de `$TMUX` en cualquier panel (segundo campo).

**9.** `-L par` crea el socket dentro de `/tmp/tmux-UID/`, un directorio `0700`
que solo tú puedes abrir. `-S /tmp/par` lo crea donde digas, sin ese
directorio: lo protegen solo los permisos del propio socket, y quien pueda
escribir en él controla tus paneles.

**10.** `new-session -A` hace attach si la sesión existe, y attach dentro de tmux
falla por anidado. Separar "crear si falta" (`has-session` + `new-session -d`)
de "saltar" (switch o attach según `$TMUX`) funciona en los dos casos y deja
cada paso comprobable.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Varias sesiones](2-practicas/lab-01-varias-sesiones/README.md) | Saltas y cierras desde `choose-tree`; muestras que `ls` no arranca un servidor; `limpiar.sh` imprime las 3 líneas y respeta las sesiones con clientes | 10 |
| [02 — Targets](2-practicas/lab-02-targets/README.md) | Cada fila de la tabla probada; el `kill-session` por prefijo reproducido y evitado; `resolver.sh` da las 3 líneas | 10 |
| [03 — Moverte entre sesiones](2-practicas/lab-03-moverte-entre-sesiones/README.md) | `prefix` `L`; árbol filtrado; `detach-on-destroy` explicado; `saltar.sh` dentro y fuera de tmux | 10 |
| [04 — Grupos de sesiones](2-practicas/lab-04-grupos-de-sesiones/README.md) | Diferencia entre dos clientes y un grupo; ids de ventana iguales; `espejo.sh` idempotente | 10 |
| [05 — Sockets y TMUX](2-practicas/lab-05-sockets-y-la-variable-tmux/README.md) | `-L`, `-S` y `TMUX_TMPDIR`; `$TMUX` explicado; socket recuperado con `USR1`; `quien-soy.sh` dentro y fuera | 10 |
| [06 — La sesión rota](2-practicas/lab-06-sesion-rota/README.md) | Los cuatro errores explicados; nunca salta a `api-vieja` ni duplica sesiones; funciona dentro y fuera de tmux | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 03`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**.

| Comprobación | Puntos |
|---|:--:|
| `ls-sin-servidor` — sin servidor, sesiones sale con 1 | 3 |
| `ls-no-arranca` — sin servidor, no arranca ninguno | 3 |
| `ls-una-linea` — una línea por sesión | 3 |
| `ls-formato` — nombre y número de ventanas | 3 |
| `ls-singular` — "1 ventana" en singular | 3 |
| `ls-orden` — la sesión usada más recientemente primero | 3 |
| `ls-marca-actual` — dentro de tmux, la actual lleva `*` | 3 |
| `ls-otro-servidor` — con `$TMUX` de otro servidor, no marca ninguna | 3 |
| `ir-fuera` — fuera de tmux, `attach` | 3 |
| `ir-dentro` — dentro de tmux, `switch-client` | 3 |
| `ir-exacto` — `ir api` no salta a `api-2` | 3 |
| `ir-sugiere` — si no existe, lista las disponibles | 3 |
| `nueva-crea` — crea la sesión en el directorio indicado | 3 |
| `nueva-salta` — salta a la sesión que crea | 3 |
| `nueva-idempotente` — dos veces, una sola sesión y salida 0 | 3 |
| `nueva-nombre-invalido` — rechaza `.` y `:` con salida 2 | 3 |
| `grupo-comparte` — la sesión nueva comparte las ventanas de la base | 3 |
| `grupo-sin-base` — sale con 1 si la base no existe | 3 |
| `uso` — una orden desconocida sale con 2 | 3 |
| `bin-completo-y-limpio` — bin/ sin TODOs y limpio para shellcheck | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Targets exactos** | Todo target de sesión lleva `=`; ningún `ls \| grep` para comprobar si existe | Un target sin `=` en un comando que no puede hacer daño | 10 |
| **Mensajes de error** | Cada fallo dice qué pasó y qué hacer, por stderr, con los códigos 1 y 2 documentados | Mensaje genérico | 8 |
| **Comentarios del porqué** | Explican `=`, `switch-client` frente a `attach`, la comparación de `$TMUX` y el `-t` de los grupos | Repiten el código | 8 |
| **Integración en la shell** | Un alias o función documentado en el README para usar `sesiones` desde cualquier sitio | Sin documentar | 6 |
| **README y bitácora** | `sesiones` en la tabla con ejemplo y la bitácora de la semana escrita | Falta uno de los dos | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Un script que ejecuta `kill-server` o `kill-session` sin `-L`/`=` sobre un nombre que viene de fuera | −10 pts |
| `sesiones` (sin argumentos) arranca un servidor | −10 pts |
| Rutas absolutas a tu home dentro de `tmux-kit` | −5 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/bin/` sin ningún `TODO`
- [ ] `./scripts/verificar-semana.sh 03` con las 20 comprobaciones en verde
- [ ] Commit `feat(week-03): ...` en tu `tmux-kit`

---

[← Volver a la Semana 03](README.md)
