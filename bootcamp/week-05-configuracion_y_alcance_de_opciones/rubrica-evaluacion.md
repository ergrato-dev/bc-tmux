# Rúbrica de Evaluación — Semana 05

> Configuración y alcance de opciones. Se evalúan tres evidencias por
> separado, y hace falta **70% en cada una**. Una config que funciona solo
> desde tu repositorio no compensa un prefix bonito.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` modular con `kit-option`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Moviste tu config a `~/.config/tmux/tmux.conf`, pero una tecla que borraste hace meses sigue haciendo algo. ¿De dónde puede venir y cómo lo compruebas? |
| 2 | Editas `tmux.conf`, abres una sesión nueva con `tmux new` y no ves el cambio. ¿Por qué? Da dos formas de verlo. |
| 3 | `set status-style bg=red` (sin `-g`) en tu `tmux.conf` no hace nada, pero la misma línea escrita en `prefix` `:` sí cambia algo. ¿Qué cambia en cada caso y por qué? |
| 4 | `show -p -t api:1.0 status-style` imprime un valor aunque nunca hiciste `set -p`. ¿Por qué, y cómo averiguas en qué nivel está fijado de verdad? |
| 5 | Quitas `set -g status-position top` de tu config y pulsas `prefix` `r`. La barra sigue arriba. ¿Por qué, y cómo lo arreglas sin reiniciar el servidor? |
| 6 | Tu config tiene `set -ga update-environment WAYLAND_DISPLAY`. ¿Qué pasa tras cinco recargas, y cómo escribes la línea para que no pase? |
| 7 | `source-file conf.d/*.conf` funciona si arrancas tmux en el directorio del kit y no carga nada si lo arrancas desde `~`. ¿Por qué, y qué escribes en su lugar? |
| 8 | Al mover `set -sF copy-command "#{d:current_file}/bin/kit-copy"` a `conf.d/10-options.conf`, copiar deja de funcionar. ¿Por qué? ¿Por qué la tecla de recarga necesita `@kit-dir` en vez de `current_file`? |
| 9 | En `conf.d/` tienes `10-options.conf`, `20-bindings.conf` y `5-local.conf`. ¿En qué orden se cargan y qué consecuencia tiene? |
| 10 | Con `set -g prefix C-a`, ¿qué hace `bind C-a send-prefix` y qué pasa con `C-b` si no haces `unbind C-b`? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** De `~/.tmux.conf`: tmux carga todos los que existan, `~/.tmux.conf`
antes que `~/.config/tmux/tmux.conf`, y lo que la nueva no pise sigue activo.
`tmux display -p '#{config_files}'` lista los archivos cargados; si aparece,
bórralo o renómbralo.

**2.** La config se lee al arrancar el **servidor**, no al crear sesiones ni
conectar clientes; `tmux new` usa el servidor que ya está en marcha.
`source-file` (o `prefix` `r`) la ejecuta de nuevo, o `kill-server` y
arrancar.

**3.** Sin `-g`, `set` actúa sobre la sesión actual. En el prompt hay una (la
tuya) y se le pone ese valor solo a ella. Al leer la config al arrancar no
hay ninguna: el comando falla (`no current session`) y no cambia nada.

**4.** Con el nombre de una opción, `show` deduce el alcance por la opción y
no por `-p`: muestra el de la sesión de `api`, que sí lo tiene. Para saber el
nivel, se lista cada nivel sin nombre (`show -p -t api:1.0`, `show -w`,
`show -t api`, `show -g`) y se busca en cuál aparece; `show -A` marca con `*`
lo heredado.

**5.** `source-file` ejecuta la config encima del estado actual: no vuelve a
los valores por defecto. Nadie ejecutó un `set` con `bottom`.
`set -gu status-position` devuelve el valor por defecto.

**6.** Cada recarga ejecuta `-ga` otra vez: cinco recargas, cinco
`WAYLAND_DISPLAY` más. `set -gu update-environment` justo antes devuelve la
lista a su valor por defecto, y el resultado es el mismo siempre.

**7.** Una ruta relativa se resuelve desde el directorio en el que arrancas
tmux, no desde el archivo que la contiene. `set -gF @kit-dir
"#{d:current_file}"` en `tmux.conf` y `source-file -F
"#{@kit-dir}/conf.d/*.conf"`.

**8.** `current_file` es el archivo que se está leyendo: en el módulo es
`conf.d/10-options.conf`, y la ruta pasa a ser `conf.d/bin/kit-copy`, que
no existe. Además, `current_file` solo existe mientras se lee un archivo; al
pulsar `prefix` `r` no hay ninguno. `@kit-dir` guarda el directorio del kit
una vez, en `tmux.conf`, para usarlo después.

**9.** Por orden alfabético: `10-`, `20-`, `5-`. `5-local.conf` carga el
último y pisa lo que fije cualquier otro módulo, aunque la intención fuera
que fuese la base. Con dos cifras (`05-`) carga primero.

**10.** `send-prefix` envía un `C-a` real al programa del panel cuando pulsas
el prefix dos veces (en bash, ir al inicio de línea). La config por defecto
trae `bind C-b send-prefix`: sin `unbind`, `C-b` sigue ocupada en la tabla
`prefix` y no puedes usarla para otra cosa.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Dónde vive la config](2-practicas/lab-01-donde-vive-la-config/README.md) | Orden de carga y `~/.tmux.conf` explicados; errores encontrados con `source-file`; `install.sh` idempotente que no pisa nada | 10 |
| [02 — Prefix propio](2-practicas/lab-02-prefix-propio/README.md) | Prefix elegido y documentado; `C-b` libre; `send-prefix` probado; prefix por sesión con `show -A` | 10 |
| [03 — Alcances y herencia](2-practicas/lab-03-alcances-y-herencia/README.md) | Valores en cuatro niveles con `show -A`; `escape-time` explicado; `scope.sh` completo; el `-g` olvidado explicado | 10 |
| [04 — Recarga en caliente](2-practicas/lab-04-recarga-en-caliente/README.md) | `prefix` `r` desde cualquier directorio; lo que la recarga no deshace; `-gu` + `-ga`; `compare-reload.sh` | 10 |
| [05 — Config modular](2-practicas/lab-05-config-modular/README.md) | `conf.d/` desde `/`; `copy-command` con `@lab-dir`; orden del glob; `local.conf`; `check-modules.sh` | 10 |
| [06 — Config rota](2-practicas/lab-06-config-rota/README.md) | Los cuatro errores explicados; carga igual desde `~`, `/` y el lab | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 05`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `recarga-idempotente` y
`bin-completo-y-limpio`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores | 3 |
| `entrada-sin-opciones` — tmux.conf no define opciones ni teclas: carga conf.d/ | 3 |
| `opciones-en-10` — Las opciones viven en conf.d/10-options.conf | 3 |
| `teclas-en-20` — Las teclas viven en conf.d/20-bindings.conf | 3 |
| `desde-otro-directorio` — La config carga entera aunque arranques tmux desde otro directorio | 3 |
| `prefix-propio` — El prefix ya no es C-b | 3 |
| `prefix-send-prefix` — El prefix pulsado dos veces llega al programa del panel | 3 |
| `c-b-libre` — C-b ya no tiene ninguna función en la tabla prefix | 3 |
| `escape-time` — escape-time es de 20 ms o menos | 3 |
| `recarga-funciona` — prefix r recarga la config del kit desde cualquier directorio | 3 |
| `recarga-idempotente` — Recargar la config dos veces no cambia ninguna opción ni tecla | 6 |
| `update-environment` — update-environment incluye WAYLAND_DISPLAY | 3 |
| `copy-command-sigue` — copy-command sigue apuntando a bin/kit-copy | 3 |
| `ko-panel` — kit-option dice que un valor viene del panel | 3 |
| `ko-ventana` — kit-option dice que un valor viene de la ventana | 3 |
| `ko-global` — kit-option dice que un valor heredado viene de global | 3 |
| `ko-servidor` — kit-option reconoce las opciones de servidor | 3 |
| `bin-completo-y-limpio` — tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck | 6 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Alcance explícito** | Cada `set` con `-s`, `-g` o `setw -g`, en el bloque de su alcance | Flags explícitos, sin agrupar | 10 |
| **Comentarios del porqué** | Explican `@kit-dir` y `-F`, el orden de `conf.d/`, `escape-time`, `-gu` antes de `-ga` y tu prefix | Repiten el código | 10 |
| **kit-option** | Comenta por qué lista sin nombre; errores por stderr con los códigos 1 y 2 en la cabecera | Funciona, sin explicar | 6 |
| **Portabilidad** | `local.conf` en `.gitignore`; ninguna ruta a tu home; carga igual desde cualquier directorio | Falta uno de los tres | 6 |
| **README y bitácora** | Estructura, cómo probar sin instalar, tu prefix y por qué, `kit-option` y la bitácora | Falta uno | 8 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Un `set` sin flag de alcance en `conf.d/` (depende de que haya sesión actual) | −5 pts |
| `source-file` con una ruta relativa | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/` ni `bin/`
- [ ] `./scripts/verificar-semana.sh 05` con las 18 comprobaciones en verde
- [ ] Commit `feat(week-05): ...` en tu `tmux-kit`

---

[← Volver a la Semana 05](README.md)
