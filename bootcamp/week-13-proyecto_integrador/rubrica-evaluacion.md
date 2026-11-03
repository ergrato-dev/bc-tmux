# Rúbrica de Evaluación — Semana 13

> Proyecto integrador. Se evalúan tres evidencias por separado, y hace falta
> **70% en cada una**. Un instalador elegante no compensa uno que borra la
> config que había, y una batería de checks en verde no vale nada si sigue en
> verde con el kit roto.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` final con `install.sh`, `tests/run` y README: 60 pts de autograding + 40 pts de calidad |

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
| 1 | ¿Por qué el instalador enlaza el directorio entero del kit en vez de copiar los archivos, y por qué `@kit-dir` sigue apuntando al kit aunque tmux lea la config a través del enlace? |
| 2 | Ejecutas dos veces `ln -s ~/tmux-kit ~/.config/tmux`. ¿Qué aparece dentro del kit, por qué la segunda vez sale con 0, y qué cambia `-n` en `ln -sfn`? |
| 3 | Ya tenías un `~/.config/tmux` real con tu config. ¿Por qué el instalador lo mueve a `tmux.bak.<fecha>` antes de enlazar, en vez de borrarlo o de usar `ln -sfn` directamente? |
| 4 | Tu instalador funciona en tu máquina y en la de un compañero acaba en `/home/tu-usuario/.config`. ¿Qué dos variables tiene que respetar y por qué `${XDG_CONFIG_HOME:-$HOME/.config}` y no una ruta escrita a mano? |
| 5 | Instalas el kit y tu prefix sigue siendo `C-b` en algunas sesiones, o las teclas se duplican. ¿Qué tiene que ver `~/.tmux.conf`, y por qué el instalador avisa en vez de borrarlo? |
| 6 | `--uninstall` borra `~/.config/tmux` solo si es un enlace a este kit. ¿Qué podría perder el usuario sin esa comprobación, y por qué un enlace ajeno sale con 1 y no con 0? |
| 7 | ¿Por qué el instalador calcula su ruta con `cd "$(dirname "$0")" && pwd -P` y no con `$PWD` ni con `readlink -f`? |
| 8 | `tmux -f kit/tmux.conf new -d` sale con 0 aunque `conf.d/` tenga un error de sintaxis. ¿Por qué, y cómo comprueba `tests/run` que la config carga de verdad? |
| 9 | Tu `tests/run` sale todo en verde. ¿Por qué eso no demuestra que sirva, y qué te dice romper el prefix a propósito y volver a ejecutarlo? |
| 10 | ¿Por qué `tests/run` usa un servidor `-L` propio, un `HOME` temporal y un `trap`? Di qué se rompería en tu máquina si faltara cada uno. |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** Con el enlace, el repositorio del kit es la config: un `git pull`
actualiza tmux sin reinstalar nada, y lo que cambias en `~/.config/tmux`
queda en el repositorio. Una copia se queda vieja en cuanto editas el kit.
tmux resuelve el enlace al leer la config: `#{d:current_file}` es el
directorio real del kit, así que `@kit-dir` y los `source-file` de
`conf.d/` funcionan igual que sin enlace.

**2.** La primera vez crea el enlace. La segunda, el destino ya es un
directorio (el enlace lleva a uno), y `ln` hace lo que haría con cualquier
directorio: crea el enlace dentro, `~/tmux-kit/tmux-kit`. No es un error
para `ln`, por eso sale con 0. `-n` trata el enlace como un archivo y no lo
sigue: con `-f`, lo reemplaza. Sobre un directorio real `-n` no sirve: el
enlace acaba dentro igual.

**3.** Esa config es del usuario y quizá no esté en ningún otro sitio:
borrarla es perderla. `ln -sfn` sobre un directorio real no lo reemplaza,
mete el enlace dentro y deja la config vieja cargándose. Moverlo con fecha
deja el sitio libre para el enlace y permite volver atrás: `--uninstall`
restaura el backup más reciente.

**4.** `HOME` y `XDG_CONFIG_HOME`. Cada usuario tiene su `HOME`, y quien
define `XDG_CONFIG_HOME` espera que todas sus configs vivan ahí; tmux la
busca primero en `$XDG_CONFIG_HOME/tmux/`. Una ruta escrita a mano solo
vale para quien la escribió y rompe los checks, que instalan en un `HOME`
temporal.

**5.** tmux carga todos los archivos de config que existen, y
`~/.tmux.conf` va antes que el de XDG: lo que haya allí se mezcla con el
kit, cambia opciones o añade teclas. El instalador no sabe si ese archivo
importa, y borrar config ajena no es su trabajo: avisa para que el usuario
decida.

**6.** Si `~/.config/tmux` es un directorio real o un enlace a la config
de otro kit, borrarlo es perder esa config. Que el kit no esté instalado
no es un error (exit 0: no hay nada que hacer), pero que haya algo ajeno
en su sitio sí: el usuario pidió desinstalar y no ha pasado nada, y un
script que lo llame tiene que poder saberlo.

**7.** `$0` es la ruta con la que se lanzó el script: `dirname` da su
directorio y `cd` + `pwd -P` lo convierte en ruta absoluta y sin enlaces,
lances el script desde donde lo lances. `$PWD` es el directorio desde el
que lo lanzas, no donde está el kit. `readlink -f` es de GNU y el macOS de
serie no lo tiene.

**8.** Los errores de la config inicial no paran el arranque: tmux los
guarda para mostrarlos al primer cliente que se conecte, y `new -d` no
conecta ninguno. `tests/run` arranca el servidor con `-f /dev/null` y luego
hace `source-file` de `tmux.conf`: así el error sale por stderr y el código
de salida es 1.

**9.** Un check que nunca puede fallar también sale en verde. Romper el kit
a propósito (mutación) y ver que el check pasa a ❌ demuestra que mira lo
que dice mirar. Si sigue en verde con el prefix cambiado, el check no
comprueba el prefix.

**10.** El `-L` propio evita tocar tu servidor de siempre: sin él, los
tests cargan su config en tus sesiones o un `kill-server` las cierra. El
`HOME` temporal evita que `install.sh` mueva tu `~/.config/tmux` real a un
backup. El `trap` cierra el servidor y borra el `HOME` temporal aunque un
check falle o pulses `C-c`: sin él quedan servidores y directorios sueltos.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — Enlaces y XDG](2-practicas/lab-01-enlaces-y-xdg/README.md) | Prefix `C-a` con el enlace y sin `-f`; `#{config_files}` con la ruta real; el `starter -> starter` del segundo `ln -s` explicado; `ln -sfn` sobre un directorio real deja el enlace dentro; dos archivos cargados con `~/.tmux.conf` o `XDG_CONFIG_HOME` | 10 |
| [02 — Instalador idempotente](2-practicas/lab-02-instalador-idempotente/README.md) | Ruta absoluta lanzado desde `/tmp`; respeta `XDG_CONFIG_HOME`; segunda ejecución `ya instalado` con 0; backup con contenido intacto; `--dry-run` sin cambios; opción desconocida con 2 y `shellcheck` limpio | 10 |
| [03 — Desinstalar y restaurar](2-practicas/lab-03-desinstalar-y-restaurar/README.md) | Nada instalado sale con 0; enlace ajeno o config real con 1, sin tocarlos; tmux vuelve a `C-b`; `--dry-run --uninstall` solo informa; el backup más reciente vuelve a su sitio | 10 |
| [04 — Checks propios](2-practicas/lab-04-checks-propios/README.md) | `tests/run` en verde con `trap` y `TMUX_SOCKET`; las tres mutaciones (prefix, `status-rigth`, `update-environment`) en ❌ con exit 1; tu servidor `kit-test` sigue vivo | 10 |
| [05 — Auditoría del kit](2-practicas/lab-05-auditoria-del-kit/README.md) | `audit.sh` encuentra los cuatro defectos y sale con 1; el segundo entre `run job` y `job died` en el log de `-vvv`; kit arreglado con arranque por debajo de 300 ms; `run-shell -b` explicado | 10 |
| [06 — Instalador roto](2-practicas/lab-06-instalador-roto/README.md) | Los fallos provocados, explicados y corregidos: `cd` relativo, ruta fija a otro home, `ln -s` sin `-n`, `rm -rf` sin backup e `XDG_CONFIG_HOME` ignorado | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 13`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `install-backup` y `tests-detectan-prefix`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `install-enlaza` — install.sh enlaza ~/.config/tmux al directorio del kit | 3 |
| `install-xdg` — install.sh instala en $XDG_CONFIG_HOME/tmux cuando XDG_CONFIG_HOME está definida | 3 |
| `install-ruta-absoluta` — Lanzado como ./install.sh desde el kit, el enlace guarda la ruta absoluta | 3 |
| `install-idempotente` — Ejecutar install.sh dos veces sale con 0 y no crea backups | 3 |
| `install-backup` — install.sh guarda la config que había en un backup, con su contenido intacto | 6 |
| `tmux-arranca-instalado` — Tras install.sh, tmux sin -f arranca con la config del kit (prefix C-a) | 3 |
| `install-dry-run` — install.sh --dry-run explica lo que haría sin cambiar nada | 3 |
| `install-avisa-tmux-conf` — install.sh avisa si también existe ~/.tmux.conf | 3 |
| `install-desinstala` — install.sh --uninstall quita el enlace y devuelve la config que había | 3 |
| `install-enlace-ajeno` — install.sh --uninstall sale con 0 si no hay nada instalado y con 1 ante un enlace ajeno, que no toca | 3 |
| `install-uso` — install.sh sale con 2 ante una opción desconocida, sin tocar nada | 3 |
| `tests-pasan` — tests/run tiene al menos 5 checks y todos pasan | 3 |
| `tests-detectan-prefix` — tests/run falla si alguien cambia el prefix | 6 |
| `tests-detectan-error` — tests/run falla si un archivo de conf.d tiene un error | 3 |
| `tests-sin-servidores` — tests/run no deja ningún servidor de tmux en marcha | 3 |
| `readme-secciones` — El README del kit tiene las secciones Instalación, Desinstalación, Atajos, Scripts y Tests | 3 |
| `kit-shellcheck` — install.sh, tests/run, bin/ y plugin/ pasan shellcheck | 3 |
| `kit-sin-todos` — El kit no tiene ningún TODO | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Instalador que no pierde nada** | Backup con fecha antes de enlazar, `--uninstall` que solo borra un enlace propio y restaura el backup, `--dry-run` que no toca nada | Funciona, pero algún caso borra o pisa config sin backup | 10 |
| **Checks propios que fallan** | `tests/run` cubre carga, prefix, recarga, `dev-up` e instalación; cada check se ha visto en ❌ con una mutación | Pasan, pero alguno no se ha probado rompiendo el kit | 10 |
| **Aislamiento** | Servidor `-L` propio que respeta `TMUX_SOCKET`, `HOME` temporal y `trap` que limpia; nunca toca la sesión ni la config del usuario | Aislado, pero sin `trap` o deja algo al salir | 6 |
| **Portabilidad** | `${XDG_CONFIG_HOME:-$HOME/.config}`, ruta del kit con `pwd -P`, nada de GNU-only ni rutas a tu home | Funciona en Linux, pero usa `readlink -f` o algo de GNU | 6 |
| **Scripts limpios** | Cabecera con uso y códigos de salida (0/1/2), errores por stderr con el nombre del script, `set -euo pipefail`, `shellcheck` sin avisos | Falta uno | 4 |
| **README final** | Instalación, desinstalación, atajos, scripts y tests al día, con un ejemplo que se pueda pegar; fila `13` en la bitácora | Falta una sección o está desactualizada | 4 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| `install.sh` que borra o sobrescribe config del usuario sin backup | −10 pts |
| Un test que toca el `HOME`, la config o el servidor tmux reales | −10 pts |
| Un script que ejecuta `kill-server` sin `-L` o `-S` | −10 pts |
| Rutas absolutas a tu home dentro del kit | −5 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO`
- [ ] `tests/run` en verde, y en rojo con el prefix cambiado a propósito
- [ ] `./scripts/verificar-semana.sh 13` con todas las comprobaciones en verde
- [ ] `install.sh` ejecutado en tu equipo: tu `tmux-kit` es ya tu config de tmux
- [ ] Commit `feat(week-13): ...` en tu `tmux-kit`

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Proyecto — tmux-kit: instalador, checks propios y entrega final](3-proyecto/README.md) | [Recursos — ebooks](4-recursos/ebooks-free/README.md) → |

[↑ Semana 13](README.md)
