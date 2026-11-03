# Proyecto Semana 03 — tmux-kit: sesiones

⏱ Duración estimada: ~3 h

## Contexto

Con una sesión por proyecto, en una semana acabas con seis: `api`, `web`, `notas`, `infra`... Para saltar entre ellas abres `choose-tree`, buscas con la vista y rezas para que `tmux attach -t api` no te deje en `api-vieja`. Desde dentro de tmux, además, `attach` falla con el error de anidado y tienes que acordarte de que lo que querías era `switch-client`.

Añades a tu `tmux-kit` el script **`bin/sesiones`**: lista tus sesiones con la más reciente primero, salta a una por su nombre exacto (dentro o fuera de tmux, sin pensar), crea la que falte y agrupa dos sesiones para que compartan ventanas.

```bash
$ sesiones
api (3 ventanas) *
notas (1 ventana)
web (2 ventanas)
$ sesiones ir web          # dentro de tmux: switch-client; fuera: attach
$ sesiones nueva infra ~/src/infra
```

## Estructura del proyecto

```
starter/                 ← tu tmux-kit de la semana 02 + lo nuevo
├── README.md            ← añade sesiones y la bitácora de la semana 03
└── bin/
    ├── check-version    (semana 01)
    ├── kit-tree         (semana 01)
    ├── kit-layout       (semana 02)
    └── sesiones         ← TODOs
```

Se trabaja **sobre `starter/`**: es lo que corrige el autograding.

## Lo que debes construir

### `sesiones` o `sesiones ls`

1. Lista una línea por sesión. Si no hay servidor, avisa por stderr y sale con **1** sin arrancar ninguno (`list-sessions` solo pregunta; `new-session` y `start-server` arrancan uno).
2. Cada línea es `NOMBRE (N ventanas)`, con `1 ventana` en singular.
3. La sesión usada más recientemente (`#{session_activity}`) va primero; a igual actividad, por nombre. Si ejecutas el script **dentro de tmux y en el mismo servidor**, la sesión actual termina en ` *`.

### `sesiones ir NOMBRE`

4. Salta a la sesión con ese nombre **exacto** (`-t "=NOMBRE"`): `ir api` nunca te lleva a `api-2`. Dentro de tmux (`$TMUX` no vacío) usa `switch-client`; fuera, `attach-session`. Si no existe, sale con **1** y dice cuáles hay.

### `sesiones nueva NOMBRE [DIR]`

5. Si la sesión no existe, la crea en segundo plano en `DIR` (por defecto, el directorio actual). Después salta a ella. Ejecutarlo dos veces deja una sola sesión y sale con 0. Un nombre con `.` o `:` se rechaza con salida **2**: tmux los cambiaría por `_` sin avisar.

### `sesiones grupo BASE NUEVA`

6. Crea `NUEVA` en el grupo de `BASE` (`new-session -d -t`): las dos comparten ventanas y cada una tiene su propia ventana actual. Si `BASE` no existe o `NUEVA` ya existe, sale con **1** sin crear nada.

### Uso y kit

7. Cualquier otra orden muestra el uso y sale con **2** (ya viene hecho en el starter).
8. Añade `sesiones` a la tabla del `README.md` con un ejemplo y escribe la bitácora de la semana.

## Paso a paso

Todo se hace en una terminal **fuera de tmux** (`echo "$TMUX"` imprime una
línea vacía), la **terminal A**, contra un servidor aparte `-L kit`: tu tmux
de siempre no se toca. Cuando un paso te conecta a tmux, lo dice y te dice
cómo salir.

0. **Prepara el entorno.** Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/3-proyecto
   export TMUX_SOCKET=kit
   starter/bin/sesiones; echo $?
   starter/bin/sesiones volar; echo $?
   ```
   ```
   sesiones ls: sin implementar
   99
   Uso: sesiones [ls]                 lista, la usada más recientemente primero
        sesiones ir NOMBRE            salta a la sesión (attach o switch-client)
        sesiones nueva NOMBRE [DIR]   la crea si no existe y salta a ella
        sesiones grupo BASE NUEVA     crea NUEVA en el grupo de BASE
   Salida: 0 bien, 1 la sesión no existe o no hay servidor, 2 uso incorrecto.
   2
   ```
   `TMUX_SOCKET=kit` hace que `sesiones` (con su `tmx`) hable con el servidor
   `kit`; los comandos que escribes a mano llevan `-L kit`. El uso (punto 7)
   ya viene hecho. Instala `shellcheck` si no lo tienes
   (`sudo apt install shellcheck` en Ubuntu, `brew install shellcheck` en
   macOS) y comprueba:
   ```bash
   shellcheck --version | head -2
   ```
   ```
   ShellCheck - shell script analysis tool
   version: 0.9.0
   ```
   (Algo como: la versión puede ser otra.) Abre `starter/bin/sesiones` con tu
   editor. En cada función, borra las dos líneas `echo "... sin implementar"`
   y `exit 99` cuando empieces su TODO. `existe` y `nombres` ya vienen hechas.

1. **TODO 1, listar sin arrancar un servidor.** `listar` guarda la salida de
   `list-sessions` en `filas` (o sale con el error) y de momento imprime las
   filas ordenadas:
   ```bash
   local filas
   filas=$(tmx list-sessions -F '#{session_activity} #{session_name} #{session_windows}' 2>/dev/null) ||
     error "no hay servidor de tmux en este socket"
   sort -k1,1nr -k2,2 <<<"$filas"
   ```
   `sort -k1,1nr -k2,2`
   ordena por el primer campo como número y al revés (la actividad más
   reciente primero) y, si empatan, por el segundo (el nombre). Prueba sin
   servidor:
   ```bash
   starter/bin/sesiones; echo $?
   tmux -L kit ls; echo $?
   ```
   ```
   sesiones: no hay servidor de tmux en este socket
   1
   error connecting to /tmp/tmux-1000/kit (No such file or directory)
   1
   ```
   (Algo como: si el archivo del socket quedó de otra vez, el segundo error es
   `no server running on /tmp/tmux-1000/kit`.) El segundo comando confirma que
   `sesiones` no arrancó ningún servidor. Ahora crea dos sesiones, con un
   segundo entre ellas para que la actividad sea distinta:
   ```bash
   tmux -L kit -f /dev/null new -d -s notas; sleep 1; tmux -L kit new -d -s web \; new-window -d -t web:
   starter/bin/sesiones
   ```
   ```
   1793664324 web 2
   1793664323 notas 1
   ```
   (Algo como: el primer número es la hora en segundos.) `-f /dev/null`
   arranca el servidor sin tu config, igual que el autograding.

2. **TODO 2, el formato.** Cambia el `sort ... <<<"$filas"` del TODO 1 por un
   bucle sobre su salida:
   ```bash
   sort -k1,1nr -k2,2 <<<"$filas" | while read -r _ nombre ventanas; do
     local plural="s"; (( ventanas == 1 )) && plural=""
     echo "$nombre ($ventanas ventana$plural)"
   done
   ```
   `_` recoge la actividad, que ya no hace falta. Prueba:
   ```bash
   starter/bin/sesiones
   ```
   ```
   web (2 ventanas)
   notas (1 ventana)
   ```

3. **TODO 3, el asterisco.** Antes del bucle, calcula `actual` solo si el
   socket de `$TMUX` es el de este servidor:
   ```bash
   local actual=""
   if [[ -n "${TMUX:-}" && "${TMUX%%,*}" == "$(tmx display-message -p '#{socket_path}')" ]]; then
     actual=$(tmx display-message -p '#{session_name}')
   fi
   ```
   Dentro de un panel, `display-message` sin `-t` contesta por el panel de
   `$TMUX_PANE`. En el bucle, añade `" *"` a la línea cuando
   `[[ "$nombre" == "$actual" ]]`. Primero, con un `$TMUX` de **otro**
   servidor no debe marcar nada:
   ```bash
   TMUX=/tmp/otro,1,0 starter/bin/sesiones
   ```
   ```
   web (2 ventanas)
   notas (1 ventana)
   ```
   Ahora de verdad dentro de tmux. En la terminal A conéctate a `notas` (el
   servidor no carga config: el prefix es `C-b`):
   ```bash
   tmux -L kit attach -t =notas
   ```
   En el panel (está en `3-proyecto/`, donde arrancó el servidor, y hereda
   `TMUX_SOCKET=kit` del entorno con el que arrancó):
   ```bash
   starter/bin/sesiones
   ```
   ```
   notas (1 ventana) *
   web (2 ventanas)
   ```
   Conectarte cuenta como actividad: `notas` pasa arriba. Sal con `C-b` `d`:
   ```
   [detached (from session notas)]
   ```

4. **TODO 4, `ir`.**
   ```bash
   existe "$1" || error "no existe la sesión '$1'. Disponibles: $(nombres)"
   if [[ -n "${TMUX:-}" ]]; then
     tmx switch-client -t "=$1"
   else
     tmx attach-session -t "=$1"
   fi
   ```
   Prueba que el nombre es
   exacto y que el error dice qué hay:
   ```bash
   tmux -L kit new -d -s api-2
   starter/bin/sesiones ir api; echo $?
   ```
   ```
   sesiones: no existe la sesión 'api'. Disponibles: api-2 notas web
   1
   ```
   Fuera de tmux, `ir` conecta:
   ```bash
   starter/bin/sesiones ir web
   ```
   La terminal A pasa a tmux, con `[web]` en la barra. Dentro, en el panel:
   ```bash
   starter/bin/sesiones ir notas
   ```
   No imprime nada y la barra pasa a `[notas]`: `switch-client`, sin anidar.
   Sal con `C-b` `d`:
   ```
   [detached (from session notas)]
   ```

5. **TODO 5, `nueva`.** El nombre no válido sale con 2, no con `error`
   (que sale con 1):
   ```bash
   local nombre="$1" dir="${2:-$PWD}"
   [[ -n "$nombre" && "$nombre" != *[.:]* ]] || {
     echo "sesiones: nombre no válido '$nombre' (sin '.' ni ':')" >&2
     exit 2
   }
   existe "$nombre" || tmx new-session -d -s "$nombre" -c "$dir"
   ir "$nombre"
   ```
   Primero el nombre no válido:
   ```bash
   starter/bin/sesiones nueva a.b; echo $?
   ```
   ```
   sesiones: nombre no válido 'a.b' (sin '.' ni ':')
   2
   ```
   Después créala en `/tmp`. Te conecta (`[api]` en la barra); sal con `C-b`
   `d` y comprueba su directorio:
   ```bash
   starter/bin/sesiones nueva api /tmp
   tmux -L kit display -p -t =api: '#{session_path}'
   ```
   ```
   [detached (from session api)]
   /tmp
   ```
   Con `display -p`, el target lleva `:` al final: `-t =api` a secas deja los
   campos vacíos. Ejecútalo otra vez: no crea nada, solo salta. Sal con `C-b`
   `d` y cuenta las sesiones `api`:
   ```bash
   starter/bin/sesiones nueva api /tmp; echo $?
   tmux -L kit ls -F '#{session_name}' | grep -cx api
   ```
   ```
   [detached (from session api)]
   0
   1
   ```

6. **TODO 6, `grupo`.** En `new-session`, `-t` no es un destino: es la
   sesión con la que agruparse.
   ```bash
   local base="$1" nueva="$2"
   existe "$base" || error "no existe la sesión base '$base'"
   existe "$nueva" && error "ya existe una sesión '$nueva'"
   tmx new-session -d -t "=$base" -s "$nueva"
   echo "sesión '$nueva' creada en el grupo de '$base'. Entra con: sesiones ir $nueva"
   ```
   Prueba los tres casos:
   ```bash
   starter/bin/sesiones grupo api espejo; echo $?
   starter/bin/sesiones grupo api espejo; echo $?
   starter/bin/sesiones grupo nada x; echo $?
   tmux -L kit ls -F '#{session_name} #{session_group_list}'
   ```
   ```
   sesión 'espejo' creada en el grupo de 'api'. Entra con: sesiones ir espejo
   0
   sesiones: ya existe una sesión 'espejo'
   1
   sesiones: no existe la sesión base 'nada'
   1
   api api,espejo
   api-2
   espejo api,espejo
   notas
   web
   ```
   El listado completo queda así:
   ```bash
   starter/bin/sesiones
   ```
   ```
   espejo (1 ventana)
   api (1 ventana)
   notas (1 ventana)
   web (2 ventanas)
   api-2 (1 ventana)
   ```
   (Algo como: el orden depende de lo que hayas tocado y de qué sesiones
   empatan en el mismo segundo.)

7. **README y alias.** En `starter/README.md`, rellena la fila de
   `bin/sesiones` (qué hace y un ejemplo, como `bin/sesiones ir api`) y la
   fila 03 de la bitácora. Añade una sección corta con el alias que usarás,
   por ejemplo `s() { ~/tmux-kit/bin/sesiones "$@"; }` (con la ruta donde
   tengas tu kit). Comprueba que no queda ningún TODO:
   ```bash
   grep -n 'TODO' starter/README.md starter/bin/*; echo $?
   ```
   ```
   1
   ```
   `grep` sale con 1 cuando no encuentra nada.

8. **Calidad.** Pasa `shellcheck` a todos los scripts:
   ```bash
   shellcheck starter/bin/*; echo $?
   ```
   ```
   0
   ```

9. **Limpia y verifica.** Cierra el servidor de pruebas, quita la variable y
   ejecuta el autograding desde la raíz:
   ```bash
   tmux -L kit kill-server; unset TMUX_SOCKET
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 03
   ```
   ```
   Semana 03 — Sesiones, targets y sockets

     ✅ Sin servidor, sesiones sale con 1
     ✅ Sin servidor, sesiones no arranca ninguno
     ...
     ✅ Una orden desconocida sale con 2
     ✅ Los scripts de bin/ no tienen TODOs y pasan shellcheck

   20/20 comprobaciones superadas.
   ```
   Si algo falla, cada ❌ trae una pista con el lab y el paso donde se
   explica.

En el autograding no hay terminal para conectar un cliente: `tests/espia-tmux`
anota los `attach-session` y `switch-client` en vez de ejecutarlos, y pasa el
resto de comandos al tmux real.

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 03` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] Sin servidor, sesiones sale con 1
- [ ] Sin servidor, sesiones no arranca ninguno
- [ ] Una línea por sesión
- [ ] Cada línea dice el nombre y cuántas ventanas tiene
- [ ] Una sola ventana se escribe en singular
- [ ] La sesión usada más recientemente va primero
- [ ] Dentro de tmux, la sesión actual lleva un asterisco
- [ ] Con TMUX de otro servidor, no marca ninguna
- [ ] Fuera de tmux, ir conecta un cliente con attach
- [ ] Dentro de tmux, ir cambia de sesión con switch-client
- [ ] ir api no salta a api-2
- [ ] Si la sesión no existe, lista las disponibles
- [ ] nueva crea la sesión en el directorio indicado
- [ ] nueva salta a la sesión que crea
- [ ] nueva dos veces deja una sola sesión y sale con 0
- [ ] nueva rechaza nombres con punto o dos puntos
- [ ] grupo crea una sesión que comparte las ventanas de la base
- [ ] grupo sale con 1 si la base no existe
- [ ] Una orden desconocida sale con 2
- [ ] Los scripts de bin/ no tienen TODOs y pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Todo target de sesión con `=`: ningún `-t "$nombre"` que pueda coincidir por prefijo.
- Mensajes de error por stderr que dicen qué pasó y cómo seguir.
- Comentarios que explican el porqué (`=`, `switch-client` frente a `attach`, la comparación de `$TMUX`).
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- Un alias o función en tu shell (`s() { ~/tmux-kit/bin/sesiones "$@"; }`) documentado en el README.

## Entrega

Commit con el mensaje:
```
feat(week-03): sesiones para listar, saltar y agrupar sesiones
```
