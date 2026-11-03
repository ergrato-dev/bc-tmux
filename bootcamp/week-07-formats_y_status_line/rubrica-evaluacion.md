# Rúbrica de Evaluación — Semana 07

> Formats y status line. Se evalúan tres evidencias por separado, y hace falta
> **70% en cada una**. Una barra bonita que lanza un proceso por segundo o que
> pasa una ruta sin citar a la shell no compensa nada.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `conf.d/30-status.conf` y `bin/kit-git-branch`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | `display -p '#{sesion_name}'` imprime una línea vacía y sale con 0, pero `show -gv @nada` da `invalid option`. ¿Por qué un format no avisa, y cómo encuentras el nombre mal escrito? |
| 2 | `#{<:10,9}` vale `1`. ¿Por qué? ¿Cómo escribes "más de 9 ventanas" para que funcione? |
| 3 | `status-right` tiene `#{?client_prefix,#[fg=red,bold]PREFIX#[default],}` y la barra muestra `bold]PREFIX` aunque no pulses nada. ¿Qué ha pasado y cómo lo corriges? |
| 4 | `#{?1,a,b}` da `b`, pero `#{?#{==:x,x},a,b}` da `a`. ¿Qué dice esto sobre cómo y en qué orden expande tmux un format? |
| 5 | Guardas la etiqueta de ventana con `set -gF @kit-window-label '#{window_index}:#{window_name}'` y todas las ventanas de la barra muestran el mismo texto. ¿Por qué, y qué cambias? |
| 6 | ¿Qué ganas escribiendo `status-style 'bg=#{@kit-color-bg}'` en lugar del color directamente? ¿Por qué `@kit-color-bg nocolor` no da error al hacer `set` y sí lo daría `status-style 'bg=nocolor'`? |
| 7 | Pruebas `display -p '#(kit-git-branch .)'` y sale vacío, pero en la barra sí aparece la rama. ¿Por qué? Y si el script tarda 3 segundos, ¿se congela la barra? |
| 8 | ¿Por qué el kit escribe `#(kit-git-branch #{q:pane_current_path})` y no `#(kit-git-branch #{pane_current_path})`? Pon un nombre de directorio que lo demuestre. |
| 9 | `status-interval 1` hace que el segundero de `#(date +%%S)` vaya fino. ¿Qué cuesta? ¿Por qué la hora del kit usa `%H:%M` y no `#(date +%H:%M)`? |
| 10 | En el modo resize la sesión se pinta con el color del prefix aunque no hayas pulsado el prefix. ¿Por qué, y con qué variable distingues un caso del otro para mostrar `RESIZE`? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Un format se expande al dibujar la barra, varias veces por segundo y sin
nadie que lea un error: lo que no existe se expande a vacío. `show` es un
comando y sí puede fallar. Para encontrarlo, prueba el format por partes con
`display -p` hasta que una parte salga vacía, y compara el nombre con la lista
de FORMATS de `man tmux`.

**2.** `<`, `>` y `==` comparan texto, carácter a carácter: `"1" < "9"`, así
que `10` va antes que `9`. Para números hay que usar una expresión:
`#{e|>|:#{session_windows},9}`, con el `#{}` explícito porque `e|` no resuelve
nombres.

**3.** La coma del estilo corta la rama del sí: `#[fg=red` es la rama del sí y
`bold]PREFIX#[default],` pasa a ser la del no, que se ve cuando el prefix **no**
está pulsado. Dentro de un condicional la coma se escribe `#,`:
`#{?client_prefix,#[fg=red#,bold]PREFIX#[default],}`.

**4.** La condición es un nombre de variable, no un valor: `1` no es ninguna
variable y se expande a vacío, falso. En cambio `#{==:x,x}` es un format, y
tmux lo expande primero, de dentro hacia fuera, hasta `1`, que sí es verdadero.
Por eso un condicional sobre una opción se escribe `#{?@kit-status-git,...}` o
con una comparación `#{?#{==:#{@kit-status-git},on},...}`.

**5.** `-F` expande el valor una sola vez, al ejecutar `set`, con la ventana
que había entonces; la opción guarda texto ya resuelto. Sin `-F` se guarda el
format literal y `#{E:@kit-window-label}` lo expande cada vez, para cada
ventana de la lista.

**6.** La paleta vive en un sitio: cambias `@kit-color-bg` y cambia todo lo que
la usa, también en caliente, porque las opciones `*-style` se evalúan al
dibujar. Por eso mismo tmux no puede validar el color en el `set`: guarda el
format `bg=#{@kit-color-bg}` sin expandirlo. Con `bg=nocolor` escrito tal cual,
el estilo se valida al hacer `set` y falla con `invalid style`.

**7.** `display -p` nunca ejecuta `#()`: solo lo hace la barra de un cliente
conectado. No se congela: `#()` corre en segundo plano y la barra muestra la
última salida (vacía la primera vez) hasta que termina la siguiente. Un script
lento enseña datos viejos, no bloquea.

**8.** Los `#{}` se expanden antes de pasar el comando a `sh -c`. Con un
directorio llamado `mi repo $(touch PWNED)`, la versión sin `q:` parte la ruta
en dos argumentos y ejecuta `touch PWNED` cada vez que se redibuja la barra.
`q:` escapa espacios, `$`, `;` y comillas para la shell.

**9.** Cada `#()` se relanza en cada intervalo, en cada cliente: con
`status-interval 1` y tres scripts son tres procesos por segundo y cliente, y
la barra se redibuja sin parar. `%H:%M` lo resuelve tmux con strftime al
dibujar, sin lanzar ningún proceso.

**10.** `client_prefix` vale 1 en cualquier tabla distinta de `root`, y el modo
resize es la tabla `kit-resize`. `#{client_key_table}` dice en qué tabla está
el cliente: `#{?#{==:#{client_key_table},kit-resize}, RESIZE ,}`.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Formats y display](2-practicas/lab-01-formats-y-display/README.md) | Variables de sesión, ventana, panel y cliente leídas con `display -p`; `list-windows -F` usado desde un script; explicado por qué un format inexistente sale vacío | 10 |
| [02 — Condicionales y comparaciones](2-practicas/lab-02-condicionales-y-comparaciones/README.md) | Indicadores de prefix y zoom con `#{?...}`; comparaciones de texto frente a `e\|>=\|`; `m:` y `&&`/`\|\|`; una coma escapada con `#,` | 10 |
| [03 — Modificadores](2-practicas/lab-03-modificadores/README.md) | Recortes, relleno, sustitución, `b:`/`d:`, fechas, `q:`, `E:` y aritmética con salidas comprobadas | 10 |
| [04 — Estilos y ventanas](2-practicas/lab-04-estilos-y-ventanas/README.md) | Barra pintada con `*-style` y `#[...]` desde opciones de usuario; ventana actual distinta; separador y bucle `W:` comprobados | 10 |
| [05 — Comandos y varias líneas](2-practicas/lab-05-comandos-y-varias-lineas/README.md) | Rama git del panel con `#(...)` y `q:`; efecto de `status-interval` observado en la barra; segunda línea con `status 2` y `status-format[1]` | 10 |
| [06 — Status rota](2-practicas/lab-06-status-rota/README.md) | Los cinco errores encontrados, explicados y corregidos, con la barra como prueba | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 07`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `paleta-en-caliente`,
`git-en-status` y `bin-completo-y-limpio`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `status-modulo` — La status line se define en conf.d/30-status.conf | 3 |
| `paleta` — La paleta define @kit-color-bg, -fg, -accent, -alert y -warn | 3 |
| `paleta-en-caliente` — Cambiar @kit-color-accent en caliente cambia el color de la sesión | 6 |
| `prefix-resalta` — Con el prefix pulsado, la sesión usa @kit-color-alert | 3 |
| `resize-indicador` — En el modo resize, la izquierda muestra RESIZE | 3 |
| `zoom-marca` — Una ventana con zoom muestra ZOOM en la lista de ventanas | 3 |
| `sync-marca` — Una ventana con synchronize-panes muestra SYNC en la lista de ventanas | 3 |
| `ventana-actual-estilo` — La ventana actual tiene un estilo propio, distinto del de las demás | 3 |
| `git-uso` — kit-git-branch sale con 2 sin argumentos | 3 |
| `git-rama` — kit-git-branch DIR imprime la rama de un repo | 3 |
| `git-sin-repo` — kit-git-branch no imprime nada y sale con 0 fuera de un repo | 3 |
| `git-en-status` — La derecha muestra la rama del panel aunque su ruta tenga espacios | 6 |
| `git-apagado` — Con @kit-status-git off, la derecha deja de mostrar la rama | 3 |
| `nav-indicador` — Con @kit-nav off, la derecha muestra NAV off | 3 |
| `status-interval` — status-interval vale entre 1 y 5 segundos | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck | 6 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Organización de `30-status.conf`** | Agrupado por zona (paleta, barra, izquierda, ventanas, derecha); ningún color fuera de la paleta | Agrupado, con algún color suelto | 8 |
| **Comentarios del porqué** | Explican `set -g` sin `-F`, `#,` en los condicionales, `q:` en el `#(...)`, el coste de `status-interval` y por qué `client_prefix` se enciende en el modo resize | Repiten el código | 12 |
| **Una sola etiqueta de ventana** | `@kit-window-label` sirve a la actual y a las demás; solo cambia el estilo | Formato duplicado | 6 |
| **kit-git-branch** | Rápido (sin `git status`), silencioso ante cualquier fallo, códigos de salida en la cabecera | Funciona, sin explicar | 8 |
| **README y bitácora** | Sección de la barra con sus opciones `@kit-*`, `kit-git-branch` en la tabla de scripts y la fila 07 de la bitácora | Falta uno | 6 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `#(...)` con una variable sin `q:` (inyección de comandos) | −10 pts |
| Un `#(...)` que tarda más de `status-interval` (`git status`, red) | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/` ni `bin/`
- [ ] `./scripts/verificar-semana.sh 07` con todas las comprobaciones en verde
- [ ] Commit `feat(week-07): ...` en tu `tmux-kit`

---

[← Volver a la Semana 07](README.md)
