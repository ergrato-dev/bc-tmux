# Rúbrica de Evaluación — Semana 11

> Plugins y ecosistema. Se evalúan tres evidencias por separado, y hace
> falta **70% en cada una**. Un kit con diez plugins no compensa uno que
> no carga sin TPM, ni un plugin propio que se duplica al recargar.

---

## 📊 Distribución de Evidencias

| Evidencia | Peso | Instrumento |
|---|:--:|---|
| 🧠 Conocimiento | 30% | Las 10 preguntas de esta rúbrica, respondidas por escrito |
| 💪 Desempeño | 40% | Los 6 labs, con sus criterios de éxito verificados en tu máquina o en el laboratorio |
| 📦 Producto | 30% | `tmux-kit` con `plugin/tmux-kit.tmux`, `conf.d/60-plugins.conf` y `bin/kit-plugins`: 60 pts de autograding + 40 pts de calidad |

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
| 1 | TPM "instala un plugin". ¿Qué hace exactamente con `tmux-plugins/tmux-resurrect#v4.0.0`, quién crea la tecla `prefix` `C-s` y por qué podrías cargar el mismo plugin sin TPM? |
| 2 | Tu config tiene dos líneas `set -g @plugin ...` y `show -g @plugin` solo muestra una, pero TPM instala las dos. ¿Por qué ambas cosas son ciertas a la vez? |
| 3 | Mueves tus `@plugin` a `conf.d/60-plugins.conf`, que cargas con `source-file -F "#{@kit-dir}/conf.d/*.conf"`, y `prefix` `I` ya no instala nada ni da error. ¿Por qué, y por qué `@tpm_plugins` lo arregla? |
| 4 | ¿Por qué el `run-shell` de TPM va al final de la config? Pon un ejemplo de opción que deja de funcionar si va antes, y explica por qué un plugin "funciona al recargar pero no al arrancar". |
| 5 | Un compañero declara `tmux-plugins/tmux-resurrect` sin tag. ¿Qué versión tendrá cada máquina dentro de seis meses, y por qué no basta con añadir después el tag en la config? |
| 6 | Tu plugin pone `@kit-sessions-label` a `ses`. ¿Por qué lo lee con `show -gqv` antes de fijarlo, por qué con `-q`, y qué pasa si el usuario lo fija después del `run-shell`? |
| 7 | El plugin del lab 04 cambia `#{sysload_load}` por `#(ruta/load.sh)`. ¿Por qué tiene que cargarse después de `status-right`, por qué `display -p` desde la terminal muestra la carga vacía, y por qué recargar no debe dejar dos `#(...)`? |
| 8 | `bind C-s ...` funciona, pero tu config arranca sin TPM en la máquina del autograding: `run-shell ~/.config/tmux/plugins/tpm/tpm` hace que `source-file` salga con 127. ¿Por qué arrancar con `-f` sale con 0 igualmente, y cómo cargas TPM solo si está instalado? |
| 9 | Restauras con resurrect y vuelven las ventanas con su directorio, `top` también, pero el servidor de desarrollo que corría con `sleep`/`npm run` no. ¿Qué guarda resurrect, por qué un programa solo vuelve si era hijo de la shell, y por qué continuum no guarda nada sin un cliente conectado? |
| 10 | Tienes `bin/dev-up` (bash) y puedes escribir lo mismo en un YAML de tmuxp. ¿Qué ganas y qué pierdes con cada uno, y cuándo es mejor no instalar un plugin y escribir diez líneas de config? |

<details>
<summary><strong>Respuestas</strong></summary>

**1.** TPM clona el repositorio con `git clone --branch v4.0.0` en su
carpeta de plugins y, en cada carga de la config, ejecuta con `run-shell`
cada `*.tmux` que encuentra ahí. Quien crea `prefix` `C-s` es
`resurrect.tmux`, que llama a `tmux bind-key`. TPM no añade nada que
`run-shell /ruta/resurrect.tmux` no haga: por eso el lab 02 carga los dos
plugins sin TPM.

**2.** Para tmux, `@plugin` es una opción de usuario normal, no una lista:
cada `set -g @plugin` sustituye el valor anterior y queda la última. TPM no
le pregunta al servidor: lee el texto de los archivos con `awk` y recoge
cada línea `set -g @plugin`, así que ve las dos.

**3.** TPM solo mira `tmux.conf` y las rutas de sus `source-file`, un solo
nivel y con la ruta escrita tal cual. Con `-F` y `#{@kit-dir}`, lo que
extrae es `-F #{@kit-dir}/...`, que no es ningún archivo: no lee nada, no
encuentra plugins y sale con 0 sin imprimir nada. `@tpm_plugins` es una
opción que TPM lee del servidor con `show-option`, así que le da igual en
qué archivo esté o cómo se cargue.

**4.** TPM ejecuta cada plugin en ese momento, con las opciones que existan
ya. Un `set -g @resurrect-save 'S'` después del `run-shell` llega tarde: la
tecla sigue siendo `C-s`. Igual con un `status-right` escrito después: el
plugin que lo interpola o continuum no lo ven. "Funciona al recargar" pasa
cuando algo (como `@tpm_plugins`) se fija después de TPM: al arrancar no
existe todavía, y en la recarga ya viene del arranque anterior.

**5.** Cada una tendrá lo que hubiera en la rama principal el día que
instaló (por ejemplo `v4.0.0-18-gcff343c`), así que dos máquinas pueden
comportarse distinto con la misma config. Añadir después el tag no cambia
nada: TPM ve la carpeta y dice `Already installed`. Hay que borrar la
carpeta del plugin e instalar.

**6.** El usuario fija sus opciones antes de cargar el plugin; el plugin
solo pone su valor si la opción está vacía, para no pisar la elección del
usuario. Sin `-q`, `show -gv @noexiste` imprime `invalid option` y sale con
1: en una asignación con `set -e`, el script termina ahí. Si el usuario
la fija después, su valor sustituye a `ses`, y en este plugin se ve porque
la barra lleva `#{@kit-sessions-label}`, que se expande al dibujar. Lo que
el plugin lee una sola vez al cargarse (una tecla, como `@resurrect-save`)
se queda con el valor por defecto hasta la siguiente carga.

**7.** El plugin solo puede sustituir lo que ya está escrito en la opción:
si `status-right` se fija después, no hay marcador que cambiar y el valor
nuevo lo pisa. `#(...)` solo se ejecuta al dibujar la barra de un cliente;
`display -p` desde la terminal nunca lo ejecuta. Un plugin que añade en vez
de sustituir, o que vuelve a sustituir sobre su propio resultado, alarga la
barra en cada recarga y ejecuta el script dos veces.

**8.** `run-shell` de un archivo que no existe sale con 127, y
`source-file` desde la CLI lo devuelve. Al arrancar con `-f` el servidor
arranca igual y el error no se ve: la config "carga" pero sin plugins. Se
protege con `if-shell "test -x #{q:@kit-dir}/plugins/tpm/tpm" { run-shell
... }`: sin TPM no se ejecuta nada y la config carga limpia.

**9.** Guarda sesiones, ventanas con nombre, paneles, directorio y layout
(y, si lo pides, el contenido de cada panel). No guarda procesos: busca por
`ps` el hijo de la shell de cada panel y, si está en su lista (`top`,
`less`, `vim`...), lo relanza; `new-window top` no tiene shell, así que no
lo encuentra, y `sleep` o un servidor no están en la lista: vuelven como
shell. continuum guarda desde un `#(...)` en `status-right`, y eso solo
corre al dibujar la barra de un cliente conectado.

**10.** Con tmuxp el YAML se lee de un vistazo y `freeze` lo genera desde
una sesión viva, pero añades Python y cualquier lógica (comprobar un
puerto, decidir un directorio) te devuelve a bash. `dev-up` no tiene
dependencias y controlas la idempotencia, a cambio de más código. Un
plugin sobra cuando lo que hace son opciones y teclas que ya sabes
escribir: cada plugin es código ajeno que corre con tus permisos en cada
carga y una versión más que mantener.

</details>

---

## 💪 Desempeño (40%)

Diez puntos por lab. El Desempeño es la suma sobre 60, llevada a porcentaje.

| Lab | Criterio | Puntos |
|---|---|:--:|
| [01 — TPM desde cero](2-practicas/lab-01-tpm-desde-cero/README.md) | TPM en `v3.1.0` y resurrect en `v4.0.0` instalados sin teclado; `prefix` `C-s`/`C-r` tras recargar; `@resurrect-save 'S'` antes del `run-shell` cambia la tecla; `show -g @plugin` frente a lo que instala TPM explicado; `clean_plugins` lo retira | 10 |
| [02 — resurrect y continuum](2-practicas/lab-02-resurrect-y-continuum/README.md) | Archivo `last` con las tres ventanas y sus directorios; restauradas tras `kill-server`, `top` incluido; `sleep 600` frente a `top` explicado; continuum restaura al arrancar y autoguarda solo con un cliente | 10 |
| [03 — Anatomía de un plugin](2-practicas/lab-03-anatomia-de-un-plugin/README.md) | `@zoom-flag-text` del usuario respetado; `prefix` `Z` hace `resize-pane -Z`; segmento una sola vez tras dos recargas; `[ZOOM]` solo con zoom y `#{@zoom-flag-text}` explicado; `shellcheck` limpio | 10 |
| [04 — Interpolación en la status](2-practicas/lab-04-interpolacion-en-la-status/README.md) | Marcadores cambiados por `#(load.sh)` y por los núcleos; la barra se actualiza; dos recargas, mismo `status-right`; `display -p` vacío y ruta con espacio sin `%q` explicados; `shellcheck` limpio | 10 |
| [05 — tmuxp](2-practicas/lab-05-tmuxp/README.md) | `tmuxp 1.76.0` instalado con `uv`; `api` con sus ventanas, paneles, directorio y `top`; segundo `load -d` sin cambios; el YAML congelado carga las 4 ventanas; lo que se pierde al congelar explicado | 10 |
| [06 — Plugins rotos](2-practicas/lab-06-plugins-rotos/README.md) | Los seis fallos (plugin sin permiso de ejecución, plugin que duplica al recargar, `~` entre comillas, `@plugin` que TPM no ve, plugin sin tag, TPM antes de `@tpm_plugins`) provocados, explicados y corregidos | 10 |

Dentro de cada lab: 10 puntos si se cumplen todos los criterios y explicas con
tus palabras por qué funciona; 8 si se cumplen todos; 7 si falla uno; menos de
7 si fallan dos o más.

---

## 📦 Producto (30%)

### Verificable por el autograding — 60 puntos

Lo ejecuta `./scripts/verificar-semana.sh 11`. Es binario: pasa o no pasa.
Cada comprobación vale **3 puntos**, salvo `plugin-idempotente` y `kit-plugins-check-sin-tag`, que valen **6**.

| Comprobación | Puntos |
|---|:--:|
| `conf-parsea-sin-tpm` — tmux.conf carga sin errores en una máquina sin TPM | 3 |
| `plugin-run-shell` — El plugin del kit, cargado solo con run-shell, cambia #{kit_sessions} por el número de sesiones | 3 |
| `plugin-opcion` — El plugin respeta un @kit-sessions-label fijado antes de cargarlo | 3 |
| `plugin-git` — La rama git de la barra sale del marcador #{kit_git} del plugin | 3 |
| `plugin-idempotente` — Recargar la config y volver a ejecutar el plugin deja la status line igual | 6 |
| `plugins-fijados` — @tpm_plugins declara tpm v3.1.0, tmux-resurrect v4.0.0 y tmux-continuum v3.1.0 | 3 |
| `tpm-ruta-kit` — TPM instala los plugins en plugins/ dentro del kit | 3 |
| `tpm-se-ejecuta` — Con plugins/tpm/tpm instalado, la config lo ejecuta al cargar | 3 |
| `resurrect-xdg` — resurrect guarda en ~/.local/share/tmux/resurrect, no en ~/.tmux | 3 |
| `continuum-restaura` — continuum restaura el último guardado al arrancar el servidor | 3 |
| `kit-plugins-uso` — kit-plugins sin subcomando o con uno desconocido sale con 2 | 3 |
| `kit-plugins-sin-servidor` — kit-plugins list sin servidor sale con 1 y lo dice | 3 |
| `kit-plugins-list` — kit-plugins list dice de cada plugin si está instalado, en el orden de @tpm_plugins | 3 |
| `kit-plugins-check-ok` — kit-plugins check sale con 0 con los plugins del kit | 3 |
| `kit-plugins-check-sin-tag` — kit-plugins check sale con 1 y nombra un plugin sin tag | 6 |
| `kit-plugins-check-rama` — kit-plugins check sale con 1 con un plugin fijado a master | 3 |
| `gitignore-plugins` — El .gitignore del kit deja fuera plugins/ | 3 |
| `kit-completo-y-limpio` — tmux.conf, conf.d/, bin/ y plugin/ no tienen TODOs y bin/ y plugin/ pasan shellcheck | 3 |
| **Total** | **60** |

### Calidad — 40 puntos

| Criterio | Excelente | Suficiente | Puntos |
|---|---|---|:--:|
| **Plugin propio idempotente y con defaults** | Sustituye marcadores en vez de añadir, no pisa una opción que ya tiene valor, cita la ruta del kit con `#{q:...}`, funciona igual con `run-shell` que con TPM | Funciona, pero rehace trabajo al recargar o pisa una opción | 10 |
| **Versiones fijadas y carga segura** | Todo plugin con tag (nunca rama), `run-shell` de TPM al final y protegido con `if-shell "test -x ..."`, opciones de resurrect/continuum antes de él, plugins en `plugins/` del kit y fuera de git | Algún plugin sin tag o TPM sin proteger | 10 |
| **Comentarios del porqué** | Explican `@tpm_plugins` frente a `@plugin`, la barra final de `TMUX_PLUGIN_MANAGER_PATH`, por qué TPM va al final, por qué resurrect va a XDG y qué le pasa a continuum sin cliente | Repiten el código | 8 |
| **`bin/kit-plugins` limpio** | `tmx()`, `set -euo pipefail`, cabecera con subcomandos y códigos de salida, errores por stderr, `install` que no reclona lo que ya está | Falta uno | 6 |
| **README del kit** | Fila de `kit-plugins`, de `60-plugins.conf` y de `plugin/`, sección `## Plugins` (qué se instala, cómo, y cómo funciona sin TPM) y fila `11` en la bitácora | Falta la sección o la bitácora | 6 |
| **Total** | | | **40** |

### Penalizaciones

| Situación | Deducción |
|---|:--:|
| Un plugin declarado sin tag o fijado a `master`/`main` | −5 pts |
| `run-shell` de TPM sin comprobar que existe (la config falla en una máquina sin TPM) | −5 pts |
| `plugins/` (código de terceros) subido al repositorio del kit | −5 pts |
| Un script que ejecuta `kill-server` sin `-L` | −10 pts |

---

## 📋 Checklist de entrega

- [ ] Los 6 labs con sus criterios de éxito comprobados
- [ ] Las 10 preguntas de Conocimiento respondidas por escrito
- [ ] `3-proyecto/starter/` sin ningún `TODO` en `tmux.conf`, `conf.d/`, `bin/` ni `plugin/`
- [ ] `./scripts/verificar-semana.sh 11` con todas las comprobaciones en verde
- [ ] Commit `feat(week-11): ...` en tu `tmux-kit`

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Proyecto — tmux-kit: plugin propio y plugins de terceros fijados](3-proyecto/README.md) | [Recursos — ebooks](4-recursos/ebooks-free/README.md) → |

[↑ Semana 11](README.md)
