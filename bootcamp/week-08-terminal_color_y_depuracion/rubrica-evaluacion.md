# Rúbrica de Evaluación — Semana 08

> Terminal, color y depuración. Se evalúan tres evidencias por separado, y
> hace falta **70% en cada una**. Unos colores perfectos con
> `default-terminal xterm-256color` o un `allow-passthrough all` sin explicar
> no compensan nada.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `conf.d/40-terminal.conf`, `bin/kit-doctor` y `docs/diagnostico.md`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Dentro de un panel, `echo "$TERM"` da `tmux-256color`, y en la terminal desde la que te conectaste da `xterm-256color`. ¿Quién pone cada uno, quién lo lee y por qué no son el mismo? |
| 2 | Un compañero pone `set -g default-terminal xterm-256color` "para que los colores vayan bien". ¿Qué le promete eso a los programas del panel y qué se puede romper? Pon un ejemplo concreto. |
| 3 | Tu barra usa `#3fb950` y en pantalla sale un verde parecido pero no igual. Tu terminal sí tiene color de 24 bits. ¿Qué ha hecho tmux con el color y por qué? |
| 4 | Añades `RGB` a `terminal-features`, recargas la config y el color sigue igual. `show -s terminal-features` sí enseña tu entrada. ¿Qué falta? |
| 5 | ¿Por qué el kit escribe `set -su terminal-features` justo antes de `set -sa terminal-features ...`? ¿Qué pasa sin el `-u` tras recargar cinco veces? |
| 6 | Escribes `xterm*:RBG` en `terminal-features` y tmux no da ningún error. ¿Por qué no avisa, y con qué comando descubres el fallo? |
| 7 | Con `escape-time 500`, pulsar `Esc` en un programa del panel tarda medio segundo en hacer efecto. ¿Qué está esperando tmux? ¿Por qué no es buena idea bajarlo a 0 si trabajas por SSH? |
| 8 | Tienes `bind -n C-Enter display hola` y al pulsar `C-Enter` se ejecuta un `Enter` normal. ¿Qué dos piezas hacen falta para que tmux distinga `C-Enter`, y por qué no basta con una? |
| 9 | ¿Qué riesgo abre `allow-passthrough on`? ¿Por qué el kit lo deja en `on` y no en `all`? |
| 10 | Algo se ve mal dentro de tmux. ¿Por qué arrancas un servidor nuevo con `-L limpio -f /dev/null` en vez de comentar líneas y recargar tu servidor de siempre? ¿Qué te dice si el fallo sigue? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** El de fuera lo pone tu emulador y lo lee el cliente al conectarse: tmux
busca esa entrada terminfo para saber cómo dibujar en tu terminal y lo guarda
en `#{client_termname}`. El de dentro lo pone tmux en el entorno de cada panel
nuevo con `default-terminal`, y lo leen los programas del panel. No son el
mismo porque esos programas no hablan con tu terminal sino con tmux, que
traduce: un cliente puede tener otro `TERM` (otra terminal, SSH) y el panel no
cambia.

**2.** Les promete que delante hay un xterm, y lo que tienen delante es tmux.
Los programas usan secuencias de xterm que tmux no entiende o traduce distinto:
Inicio y Fin, por ejemplo, llegan como `^[[1~` y `^[[4~` (lo que describe
`tmux-256color`), pero `xterm-256color` espera `^[OH` y `^[OF`, así que el
programa no las reconoce. El color de 24 bits no se arregla con eso: depende
del `TERM` de fuera y de `terminal-features`.

**3.** La entrada terminfo del `TERM` de fuera (`xterm-256color`) no declara
24 bits, así que tmux no sabe que tu terminal los tiene y aproxima cada color
al índice 256 más cercano: `#3fb950` sale como `38;5;71`. Se arregla
diciéndoselo con la feature `RGB`, no cambiando el `TERM` de dentro.

**4.** Las features de un cliente se calculan al conectarse. Tu cliente ya
estaba conectado y sigue con las de antes: `#{client_termfeatures}` no
incluye `RGB`. Hay que desconectarse y volver a conectar.

**5.** `-a` añade una entrada nueva al array cada vez que se ejecuta, también
en cada recarga: tras cinco recargas habría cinco copias de la misma línea. No
rompe nada visible, pero ensucia `show -s` y es la clase de config que no es
idempotente. `-u` devuelve la opción a sus tres entradas de fábrica y el `-a`
de después deja siempre el mismo resultado.

**6.** `terminal-features` es una lista de texto con patrones y nombres; tmux
no valida que el nombre sea una feature conocida, igual que un patrón que no
casa con ningún `TERM` no es un error. Se descubre mirando el efecto:
`display -p '#{client_termfeatures}'` (tras reconectar) no incluye `RGB`.

**7.** `Esc` es también el primer byte de las secuencias de teclas (flechas,
`M-x`). tmux espera `escape-time` milisegundos por si llega el resto antes de
decidir que era un `Esc` solo. Con 0, por una conexión lenta los bytes de una
secuencia pueden llegar separados y tmux los parte: una flecha o un `M-` se
convierten en `Esc` más letras sueltas. Un valor pequeño (10-50 ms) quita la
espera sin ese riesgo.

**8.** `extended-keys on` en tmux y la feature `extkeys` para tu terminal. La
opción le dice a tmux que use teclas extendidas; la feature le dice que tu
terminal sabe mandarlas y cómo pedírselo. Con solo la opción, tmux no se las
pide a la terminal y le sigue llegando un `Enter`; con solo la feature, tmux no
las activa. Y tu terminal tiene que soportarlas.

**9.** Con passthrough, cualquier programa del panel puede mandar secuencias
directamente a tu terminal sin que tmux las filtre: cambiar el título,
escribir en el portapapeles con OSC 52 o lo que tu emulador acepte, también
desde un `cat` de un archivo malicioso o una salida remota. `on` solo lo
permite al panel visible; `all` también a los paneles ocultos, que escriben a
tu terminal sin que veas qué están haciendo.

**10.** Recargar no deja el servidor como de fábrica: opciones de servidor
como `terminal-overrides` siguen con el valor viejo aunque borres la línea, y
las features no cambian hasta reconectar, así que puedes sacar conclusiones
falsas. Un servidor nuevo en otro socket, sin config, no toca tu sesión y
parte de cero. Si el fallo sigue ahí, no es tu config: está en tu terminal o
en su terminfo, y se mira con `show-messages -T` e `infocmp -x`.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Dos TERM](2-practicas/lab-01-dos-term/README.md) | `TERM` de fuera y de dentro leídos y explicados; `client_termname` comprobado; efecto de `default-terminal xterm-256color` en un panel nuevo observado y revertido | 10 |
| [02 — Terminfo](2-practicas/lab-02-terminfo/README.md) | Capacidades leídas con `infocmp -x` y `tput`; entrada propia con `RGB` compilada con `tic` en un `TERMINFO` temporal y visible solo con esa variable | 10 |
| [03 — Color de 24 bits](2-practicas/lab-03-color-de-24-bits/README.md) | `RGB` en `#{client_termfeatures}` tras reconectar; los bytes grabados pasan de `38;5` a `38;2`; `terminal-features` idempotente al recargar | 10 |
| [04 — Teclas extendidas](2-practicas/lab-04-teclas-extendidas/README.md) | Binding a `C-Enter` disparado; papel de `extended-keys` y de `extkeys` comprobado por separado; lo que depende de tu terminal, dicho | 10 |
| [05 — Passthrough y estilos](2-practicas/lab-05-passthrough-y-estilos/README.md) | Secuencia envuelta descartada con `allow-passthrough off` y entregada con `on`; subrayado ondulado con `usstyle` comprobado en los bytes; riesgo de `all` explicado | 10 |
| [06 — Depurar una terminal rota](2-practicas/lab-06-depurar-una-terminal-rota/README.md) | Los cinco fallos encontrados con `-vvv`, `show-messages -T` y `-f /dev/null`, explicados y corregidos | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 08`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `bin-completo-y-limpio`, `features-idempotente`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `terminal-modulo` — conf.d/40-terminal.conf fija default-terminal en tmux-256color | 3 |
| `rgb-feature` — Un cliente xterm-256color tiene la feature RGB | 3 |
| `usstyle-feature` — Un cliente xterm-256color tiene la feature usstyle | 3 |
| `extkeys-feature` — Un cliente xterm-256color tiene la feature extkeys | 3 |
| `features-idempotente` — Recargar la config no duplica terminal-features | 6 |
| `extended-keys` — extended-keys vale on | 3 |
| `focus-events` — focus-events vale on | 3 |
| `allow-passthrough` — allow-passthrough vale on, no all | 3 |
| `doctor-uso` — kit-doctor sale con 2 si recibe argumentos | 3 |
| `doctor-sin-servidor` — Sin servidor, kit-doctor avisa en la línea servidor y no arranca uno | 3 |
| `doctor-formato` — Cada línea de kit-doctor es «ok|aviso|fallo  tema  detalle» | 3 |
| `doctor-config-buena` — Con la config del kit y un cliente xterm-256color, kit-doctor sale con 0 | 3 |
| `doctor-default-terminal` — Con default-terminal xterm-256color, kit-doctor da fallo en default-terminal | 3 |
| `doctor-escape-time` — Con escape-time 500, kit-doctor da fallo en escape-time y sale con 1 | 3 |
| `doctor-sin-rgb` — Con un cliente sin RGB, kit-doctor avisa en la línea color | 3 |
| `guia-diagnostico` — docs/diagnostico.md tiene secciones para colores, undercurl, Esc, C-Enter y portapapeles | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/, bin/ y docs/ no tienen TODOs y bin/ pasa shellcheck | 6 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Organización de `40-terminal.conf`** | Agrupado por tema (TERM de dentro, features, teclas y foco, passthrough), cada opción con su alcance explícito | Agrupado, con algún alcance implícito | 8 |
| **Comentarios del porqué** | Explican los dos `TERM`, `tmux-256color` frente a `xterm-256color`, qué aporta cada feature, `-u` antes de `-a`, `on` y no `always`, y el riesgo de `allow-passthrough` | Repiten el código | 12 |
| **kit-doctor** | Sin efectos secundarios, reutiliza `check-version`, cabecera con códigos de salida y formato de línea | Funciona, sin explicar | 8 |
| **docs/diagnostico.md** | Comandos que se pegan tal cual con lo que debe salir; dice qué solo se ve en una terminal real | Lista síntomas sin comandos | 8 |
| **README y bitácora** | `kit-doctor` y la guía en el README del kit, fila 08 en la bitácora | Falta uno | 4 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `default-terminal` con `xterm-256color` o `screen-256color` | −10 pts |
| `allow-passthrough all` | −5 pts |
| Un script que arranca un servidor o ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/`, `bin/` ni `docs/`
- [ ] `./scripts/verificar-semana.sh 08` con todas las comprobaciones en verde
- [ ] Commit `feat(week-08): ...` en tu `tmux-kit`

---

[← Volver a la Semana 08](README.md)
