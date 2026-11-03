# Rúbrica de Evaluación — Semana 06

> Key bindings, tablas y navegación. Se evalúan tres evidencias por separado,
> y hace falta **70% en cada una**. Una tecla que funciona en tu shell y le
> roba una tecla a otro programa no compensa un modo resize bonito.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con modo resize, navegación y `kit-keys`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Añades `bind -n Tab next-window` y el autocompletado deja de funcionar en todos los paneles de todas las sesiones. ¿Por qué, y cómo lo deshaces sin reiniciar el servidor? |
| 2 | `conf.d/20-bindings.conf` define `bind -N "kit: sesiones" s choose-tree -s` y `conf.d/40-extra.conf` hace `bind s choose-tree`. ¿Qué hace `prefix` `s`, qué muestra `prefix` `?` para `s` y por qué nadie dio un error? |
| 3 | `unbind M-Left` no quita un `bind -n M-Left select-pane -L`. ¿Por qué? ¿Qué escribes en su lugar? |
| 4 | Las flechas de `prefix` llevan `-r` de serie. ¿Qué gana una tecla de movimiento con `-r`, y por qué `bind -r n next-window` te da sorpresas al escribir en la shell? |
| 5 | Tu modo resize (`prefix` `R` entra en la tabla `resize`) solo redimensiona una vez: la segunda `h` aparece escrita en la shell. ¿Por qué, y qué cambias en el binding de `h`? |
| 6 | Estás en la tabla `resize` y pulsas `C-h`, que esa tabla no tiene. ¿Qué pasa con la tecla y en qué tabla queda el cliente? ¿Cómo lo compruebas? |
| 7 | ¿Por qué la navegación con `C-h` decide con `if -F '#{alternate_on}'` y no con `if 'ps ... \| grep ...'` ni con `#{pane_current_command}`? |
| 8 | Con `C-h/j/k/l` en `root`, ¿qué pierdes en la shell, cómo lo recuperas y qué programa sigue recibiendo navegación en lugar de la tecla? |
| 9 | En `bind -T copy-mode-vi y if -F '#{selection_present}' { send -X copy-selection-and-cancel } { send -X cancel }`, ¿por qué `send -X` y no `send-keys y`, y qué ganas con `{ }` frente a comillas? |
| 10 | Tu kit tiene veinte teclas. ¿Qué te da `bind -N "kit: ..."` que no te da un comentario en `20-bindings.conf`? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** `-n` es `-T root`: la tabla activa por defecto. tmux busca ahí cada tecla
antes de dársela al panel, y una tecla de `root` vale para todos los clientes y
todos los paneles. `Tab` ya no llega a la shell. `unbind -n Tab` (o
`unbind -T root Tab`) la devuelve, y hay que quitar la línea de la config:
recargar no deshace un `bind`.

**2.** Ejecuta `choose-tree` sin `-s`: `40-extra.conf` se carga después y su
`bind` sustituye al anterior entero, nota incluida, así que `prefix` `?` ya no
muestra `s`. Pisar una tecla es una operación válida, no un error: tmux no
avisa. `list-keys -T prefix s` dice qué quedó, y un `grep` de `bind.* s ` por
`conf.d/` encuentra quién la pisa.

**3.** `unbind` sin `-n` ni `-T` busca en la tabla `prefix`, y el binding está en
`root`. `unbind -n M-Left`.

**4.** Durante `repeat-time` (500 ms) el cliente sigue en la tabla `prefix`:
`prefix` `Up` `Up` `Up` mueve tres veces sin repetir el prefix. Con
`bind -r n next-window`, si escribes una palabra con `n` justo después de
cambiar de ventana, esa `n` vuelve a cambiar de ventana en vez de llegar a la
shell. `-r` se reserva para teclas de movimiento o redimensionado que nadie
escribe tras usarlas.

**5.** `switch-client -T resize` mete al cliente en la tabla solo para la
**siguiente** tecla; después vuelve a `root`, y la segunda `h` sale hacia la
shell. El binding de `h` tiene que volver a entrar:
`bind -T resize h { resize-pane -L 5; switch-client -T resize }`.

**6.** Una tecla que la tabla no tiene devuelve el cliente a `root` y se busca
allí: si `root` tiene `C-h` (la navegación), se ejecuta; si no, llega al
programa. El cliente queda en `root`. `display -p '#{client_key_table}'` antes y
después, o la tabla en `status-right`.

**7.** `if -F` evalúa un format dentro de tmux; `if` sin `-F` lanza `sh -c` en
cada pulsación (más lento, depende del `PATH` y de `ps`). `pane_current_command`
es el proceso en primer plano y falla: con `seq 100 | less`, tmux 3.4 dice
`bash`. Además, una lista de nombres de programas hay que mantenerla.
`alternate_on` mira lo que importa, si el panel está en pantalla alternativa, y
funciona con cualquier programa.

**8.** `C-l` deja de limpiar la pantalla de la shell; se recupera con
`bind C-l send-keys C-l` (`prefix` `C-l`). Si tu terminal envía `C-h` con
Backspace, también pierdes el borrado. Un programa que no usa la pantalla
alternativa, como el REPL de `python3`, recibe navegación y no la tecla.

**9.** En copy mode las acciones son comandos del modo (`begin-selection`,
`copy-selection-and-cancel`): `send -X` ejecuta el comando por su nombre, sin
depender de qué tecla lo tenga asignado; `send-keys y` enviaría una tecla, no
una acción. Los bloques `{ }`
agrupan cada rama sin anidar comillas ni escapar `\;`, que es justo donde se
rompen los `if` escritos a mano.

**10.** La nota vive en el servidor: `prefix` `?` y `list-keys -N` la muestran
mientras trabajas, y reflejan lo que de verdad quedó cargado después de que un
módulo pisara a otro. Un comentario solo describe el archivo. Con el prefijo
`kit:`, además, un script (`bin/kit-keys`) puede separar tus teclas de las de
serie.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — bind, unbind y list-keys](2-practicas/lab-01-bind-unbind-y-list-keys/README.md) | Bindings creados, pisados y quitados con `list-keys -T` como prueba; notas con `-N` visibles en `prefix` `?`; `keys-of.sh` lista una tabla con sus notas | 10 |
| [02 — Repetición y tabla root](2-practicas/lab-02-repeticion-y-tabla-root/README.md) | `-r` y `repeat-time` comprobados; `bind -n` con Alt + flechas; `Tab` robado a la shell demostrado y devuelto con `unbind -n` | 10 |
| [03 — Tablas propias](2-practicas/lab-03-tablas-propias/README.md) | Modo resize que se repite y sale con `Escape`, `q` y `Enter`; `#{client_key_table}` visto con `display -p` y en la barra | 10 |
| [04 — Copy mode a medida](2-practicas/lab-04-copy-mode-a-medida/README.md) | Bindings de `copy-mode-vi` con `send -X`; bloque `{ }` con varios comandos; `if -F '#{selection_present}'` copia o sale | 10 |
| [05 — Navegación consciente](2-practicas/lab-05-navegacion-consciente/README.md) | `C-h/j/k/l` mueve en la shell y pasa la tecla a `less` y `watch` (y explicas por qué `top` no); `prefix` `C-l` limpia; explicado por qué no `pane_current_command` | 10 |
| [06 — Teclas rotas](2-practicas/lab-06-teclas-rotas/README.md) | Los cinco errores encontrados con `list-keys`, `source-file` y `show-messages`, explicados y corregidos | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 06`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `resize-repite`, `nav-pasa`,
`notas-kit` y `bin-completo-y-limpio`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `split-derecha` — prefix | divide a la derecha en el directorio del panel | 3 |
| `split-debajo` — prefix - divide debajo en el directorio del panel | 3 |
| `resize-entra` — prefix R mete al cliente en la tabla kit-resize | 3 |
| `resize-repite` — En kit-resize, h redimensiona el panel y el cliente sigue en kit-resize | 6 |
| `resize-sale` — q y Escape devuelven el cliente a la tabla root | 3 |
| `nav-mueve` — C-h sin prefix cambia al panel de la izquierda en la shell | 3 |
| `nav-pasa` — C-l llega al programa cuando el panel está a pantalla completa | 6 |
| `nav-desactivable` — Con @kit-nav off, C-l ya no cambia de panel | 3 |
| `nav-limpiar` — prefix C-l envía C-l al programa del panel | 3 |
| `notas-kit` — Todas las teclas que el kit añade o cambia tienen una nota kit: | 6 |
| `kit-keys-uso` — kit-keys sale con 2 si recibe más de una tabla | 3 |
| `kit-keys-tabla` — kit-keys kit-resize lista h con su nota | 3 |
| `kit-keys-todas` — kit-keys sin argumentos lista las teclas del kit de prefix y root | 3 |
| `kit-keys-sin-servidor` — kit-keys sale con 1 sin servidor y no arranca ninguno | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck | 6 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Organización de `20-bindings.conf`** | Teclas agrupadas por función (prefix, recarga, splits, resize, navegación, copy mode) y alineadas como tabla | Agrupadas, sin alinear | 8 |
| **Comentarios del porqué** | Explican por qué cada tecla de `kit-resize` vuelve a entrar, por qué `alternate_on` y no `pane_current_command`, qué tecla de serie pisas (`prefix` `-`) y qué cuesta robar `C-l` | Repiten el código | 12 |
| **Notas `kit:`** | Cortas, dicen qué hace la tecla, no cómo; ninguna tecla del kit sin nota | Alguna nota describe el comando | 6 |
| **kit-keys** | Comenta por qué pregunta con `list-sessions` antes de `list-keys`; errores por stderr con los códigos 1 y 2 en la cabecera | Funciona, sin explicar | 8 |
| **README y bitácora** | Sección de teclas, `kit-keys` en la tabla de scripts y la fila 06 de la bitácora | Falta uno | 6 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Una tecla en `root` (`bind -n`) sin condición que la devuelva al programa | −5 pts |
| `if` sin `-F` (lanza una shell en cada pulsación) donde basta un format | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/` ni `bin/`
- [ ] `./scripts/verificar-semana.sh 06` con todas las comprobaciones en verde
- [ ] Commit `feat(week-06): ...` en tu `tmux-kit`

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Proyecto — tmux-kit: modo resize, navegación sin prefix y teclas documentadas](3-proyecto/README.md) | [Recursos — ebooks](4-recursos/ebooks-free/README.md) → |

[↑ Semana 06](README.md)
