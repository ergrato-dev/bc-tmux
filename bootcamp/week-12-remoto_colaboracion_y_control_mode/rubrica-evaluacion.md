# Rúbrica de Evaluación — Semana 12

> Remoto, colaboración y control mode. Se evalúan tres evidencias por
> separado, y hace falta **70% en cada una**. Un toggle impecable no
> compensa una sesión compartida en la que el invitado puede escribir en
> tu shell.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `conf.d/70-remote.conf` y `bin/kit-pair`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | Se te cae la wifi en mitad de una compilación que lanzaste por SSH dentro de tmux. ¿Por qué sigue corriendo, qué es exactamente lo que has perdido y por qué `new -A` es el comando para entrar y también para volver? |
| 2 | `ssh build-01 tmux new -A -s main` falla con `open terminal failed: not a terminal` y `ssh -t ...` funciona. ¿Qué cambia `-t` y por qué tmux lo necesita para conectarse? |
| 3 | Usas mosh para ir del portátil al servidor. ¿Qué te da que no te da ssh, y por qué sigues necesitando tmux en el servidor? |
| 4 | Con tmux en tu portátil y en el servidor, los dos con prefix `C-a`, `C-a` `c` siempre crea la ventana fuera. ¿Por qué el de dentro nunca recibe su prefix, y cómo lo resuelve `bind C-a send-prefix`? |
| 5 | El toggle hace `set prefix None \; set key-table off` y vuelve con `set -u prefix \; set -u key-table`. ¿Por qué `set` sin `-g`, por qué `-u` en vez de guardar el prefix anterior, y por qué el `F12` de vuelta tiene que estar en la tabla `off`? |
| 6 | Tu config pinta la barra de azul con `if-shell '[ -n "$SSH_CONNECTION" ]'`. ¿Por qué no se hace con un format, y en qué caso entras por SSH y la barra sigue verde? |
| 7 | Compartes con `tmux -L pair` y le das al socket permisos `660` del grupo `pair`, pero tu compañero recibe `Permission denied`. ¿Por qué, y por qué la solución es `-S` en un directorio `710` en vez de `chmod 777`? |
| 8 | Con el socket bien abierto al grupo, ¿qué añade `server-access`? Explica por qué `server-access -a invitado` es peligroso sin `-r` y por qué `access not allowed` sale con código 0. |
| 9 | Le pides a tu compañero que se conecte con `attach -r` "para que no toque nada". ¿Por qué eso no te protege si tiene (W), y qué puede hacer alguien que escribe en tu sesión? |
| 10 | En control mode, ¿cómo sabe un programa qué líneas son la respuesta a su comando y cuáles son eventos? ¿Por qué `display -p nope-#{session_name}` sin comillas da `%error`, y para qué usa iTerm2 `-CC`? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** El servidor de tmux y sus procesos viven en el servidor remoto;
SSH solo llevaba el cliente, que es lo único que muere con la conexión.
La compilación es hija de una shell de un panel, no de ssh, así que
sigue. `new -A` se conecta a la sesión si existe y la crea si no: con el
mismo comando entras la primera vez y vuelves tras un corte, sin
`duplicate session`.

**2.** Sin `-t`, ssh ejecuta el comando sin terminal: la entrada y la
salida son tuberías. Un cliente de tmux tiene que dibujar la pantalla y
leer teclas de una terminal, así que sale con `not a terminal`. `-t` le
pide a ssh una pseudoterminal en el remoto.

**3.** mosh va por UDP y sincroniza la pantalla: sobrevive a un cambio de
IP o a la suspensión del portátil sin reconectar, y hace eco local de lo
que escribes con latencia alta. Pero solo sincroniza la pantalla visible
(sin historial) y, si cierras la terminal local, no puedes volver a ese
mosh. tmux en el servidor sí te deja volver desde cualquier terminal, y
te da ventanas, paneles e historial.

**4.** Toda tecla pasa primero por el tmux de fuera, que es quien lee tu
teclado; el de dentro es solo un programa en uno de sus paneles. Con el
mismo prefix, el de fuera se lo queda siempre. `send-prefix` hace que
`prefix` `C-a` escriba un `C-a` en el panel: viaja por ssh como texto, el
de dentro lo recibe como su prefix y la tecla siguiente actúa allí.

**5.** Sin `-g` cambias solo la sesión en la que pulsas `F12`; las demás
sesiones del servidor siguen funcionando. `set -u` borra ese valor y la
sesión vuelve a heredar el global, sea el que sea: no hay que guardar
nada, cambiar el prefix en la config no rompe el toggle y recargar no lo
deshace. El `F12` de vuelta va en `off` porque esa es la tabla donde
empiezan las teclas mientras está apagado: en la tabla `prefix` haría
falta un prefix que ya no existe.

**6.** Un format lee opciones y datos de tmux, no variables de entorno.
`if-shell` ejecuta una shell al cargar la config con el entorno del
servidor y deja el resultado en una opción (`@kit-remote`). Por eso
detecta cómo arrancó el servidor: si el servidor ya estaba arrancado en
local y te conectas a él por SSH, sigue siendo `off` hasta reiniciarlo.

**7.** `-L` deja el socket en `/tmp/tmux-UID/`, un directorio `700`: los
demás no pueden atravesarlo, da igual qué permisos tenga el socket. Con
`-S` eliges la ruta: un directorio tuyo `710` del grupo deja que el grupo
llegue al socket sin listar ni crear nada, y el socket `660` solo admite
al grupo. `777` deja entrar a cualquier usuario de la máquina y que
cualquiera borre o sustituya el socket.

**8.** El sistema de archivos solo decide quién llega al socket; desde
tmux 3.3, `server-access` decide quién de ellos puede conectarse y si
escribe. `-a` sin `-r` añade con escritura: el invitado podría ejecutar
comandos en tu shell. `access not allowed` sale con 0 porque el cliente sí
llegó al servidor y este lo rechazó con un mensaje; un script tiene que
mirar el texto, no el código.

**9.** `attach -r` lo decide el cliente, no tú: con (W), el invitado lo
quita con `switch-client -r` o escribe sin conectarse con `send-keys` desde
otra shell. Quien escribe en tu sesión ejecuta comandos como tú: lee tus
claves SSH, tus tokens, tu historial y puede borrar lo que puedas borrar
tú. Solo `server-access -r` lo impide, porque lo aplica el servidor.

**10.** Cada comando responde entre `%begin` y `%end` (o `%error`) con el
mismo número de orden y la flag `1` si lo mandó el cliente; todo lo que
llega fuera de un bloque, como `%window-add` o `%output`, es una
notificación. Sin comillas, `#` empieza un comentario y el comando queda
mal formado, así que tmux responde con `parse error` y `%error`. iTerm2
usa `-CC` para hablar ese protocolo y dibujar las ventanas y paneles de
tmux como ventanas y pestañas propias.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — SSH y sesión persistente](2-practicas/lab-01-ssh-y-sesion-persistente/README.md) | `@lab-remote` `off` en local y `on` por SSH; `trabajo` sin `(attached)` tras `Enter` `~` `.` y `top` en marcha al volver con `new -A`; `SSH_CONNECTION` de la sesión distinto del global; `not a terminal` sin `-t` explicado | 10 |
| [02 — tmux anidado](2-practicas/lab-02-tmux-anidado/README.md) | Cliente de dentro con `tmux-256color`; `C-b` `c` crea fuera y `C-b` `C-b` `c` dentro; prefix `C-a` en el de dentro; por qué `sessions should be nested with care` solo sale en el mismo socket | 10 |
| [03 — Toggle de anidado](2-practicas/lab-03-toggle-de-anidado/README.md) | `F12` en la tabla root y en `off`; `key-table` sin valor tras `F12` `F12`; `OFF` en la barra; una sesión apagada y otra no a la vez; `C-b` `c` llega al de dentro con el toggle apagado | 10 |
| [04 — Socket compartido](2-practicas/lab-04-socket-compartido/README.md) | `Permission denied` con `600` y `access not allowed` sin `server-access`; `share.sh` idempotente; invitado `read-only` con aviso en su barra; (R) frente a (W) comprobado con `send-keys`; `server-access -d` lo desconecta | 10 |
| [05 — Control mode](2-practicas/lab-05-control-mode/README.md) | `%begin`/`%end` y `%error` explicados; `events.sh` termina con su `timeout`; traduce crear, renombrar y cerrar ventanas, renombrar la sesión y `%exit`; `shellcheck` limpio | 10 |
| [06 — Colaboración rota](2-practicas/lab-06-colaboracion-rota/README.md) | Los fallos provocados, explicados y corregidos: socket abierto a todos, `attach -r` sin `server-access`, toggle que no vuelve, prefix interior que nunca llega y `TERM` equivocado en el anidado | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 12`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `f12-vuelve` y `kit-pair-lectura`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea` — tmux.conf carga sin errores con conf.d/70-remote.conf | 3 |
| `f12-sin-prefix` — F12 deja la sesión sin prefix | 3 |
| `f12-tabla-off` — F12 pone la sesión en la tabla off | 3 |
| `f12-indicador` — Con el toggle apagado, la barra muestra OFF | 3 |
| `f12-vuelve` — Un segundo F12 deja la sesión exactamente como estaba | 6 |
| `f12-tras-recarga` — El toggle sigue funcionando después de recargar la config dos veces | 3 |
| `ssh-status` — La barra marca SSH solo si el servidor arrancó por SSH | 3 |
| `kit-pair-uso` — bin/kit-pair sale con 2 ante un uso incorrecto | 3 |
| `kit-pair-permisos` — kit-pair start deja el directorio en 710 y el socket en 660, del grupo compartido | 3 |
| `kit-pair-idempotente` — Ejecutar kit-pair start dos veces deja una sola sesión pair | 3 |
| `kit-pair-sin-servidor` — kit-pair allow sin sesión compartida sale con 1 y lo dice | 3 |
| `kit-pair-lectura` — kit-pair allow da solo lectura por defecto | 6 |
| `kit-pair-escritura` — kit-pair allow USUARIO -w pasa a escritura a quien ya tenía acceso | 3 |
| `kit-pair-inexistente` — kit-pair allow rechaza un usuario que no existe | 3 |
| `kit-pair-nombre-hostil` — kit-pair allow rechaza con 2 un nombre que tmux leería como opción o ruta | 3 |
| `kit-pair-deny` — kit-pair deny quita el acceso | 3 |
| `kit-pair-stop` — kit-pair stop cierra el servidor compartido y borra su directorio | 3 |
| `kit-completo-y-limpio` — tmux.conf, conf.d/, bin/ y plugin/ no tienen TODOs y bin/ y plugin/ pasan shellcheck | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Toggle sin estado** | Valores de sesión con `set` sin `-g` y vuelta con `set -u`; la tabla `off` solo tiene `F12`; ninguna tecla del kit deja de funcionar al volver; recargar no lo rompe | Funciona, pero guarda el prefix anterior o cambia el global | 10 |
| **Seguridad por capas en `kit-pair`** | Directorio propio comprobado con `-O`, permisos por grupo (nunca `o+rw`), `server-access` en solo lectura por defecto, nombres validados antes de llegar a tmux | Permisos bien, pero algún nombre llega sin validar o el directorio no se comprueba | 10 |
| **Idempotencia** | `start`, `deny` y `stop` se pueden repetir; `allow` cambia el modo de quien ya estaba | Alguno falla la segunda vez | 6 |
| **Comentarios del porqué** | Explican `-S` y no `-L`, el `chmod` del socket, el `rm -f` tras `kill-server`, `if-shell` porque un format no lee el entorno y qué SSH detecta | Repiten el código | 6 |
| **`bin/kit-pair` limpio** | Cabecera con uso y códigos de salida, errores por stderr con el nombre del script, `set -euo pipefail`, `shellcheck` sin avisos | Falta uno | 4 |
| **README del kit** | Fila de `kit-pair`, barra (`OFF`, `SSH`, `PAIR`), sección `## Remoto y compartir` y fila `12` en la bitácora | Falta la sección o la bitácora | 4 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Socket o directorio con permisos para otros (`o+r`, `o+w`, `777`) | −10 pts |
| `allow` que da escritura por defecto o confía en `attach -r` como protección | −10 pts |
| Un nombre de usuario sin validar que llega a `server-access` o a una ruta | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` o `-S` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/`, `bin/` ni `plugin/`
- [ ] `./scripts/verificar-semana.sh 12` con todas las comprobaciones en verde
- [ ] `docker compose down` al terminar: borra la clave SSH y el `sshd` del laboratorio
- [ ] Commit `feat(week-12): ...` en tu `tmux-kit`

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Proyecto — tmux-kit: toggle de anidado, barra remota y sesión compartida](3-proyecto/README.md) | [Recursos — ebooks](4-recursos/ebooks-free/README.md) → |

[↑ Semana 12](README.md)
