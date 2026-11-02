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

Si sigues con tu propio kit, copia en él `starter/bin/sesiones`; el autograding solo mira el comportamiento.

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

## Verificación

```bash
export TMUX_SOCKET=kit                        # servidor aislado para probar
starter/bin/sesiones; echo $?                 # 1: no hay servidor
tmux -L kit new -d -s api-2
starter/bin/sesiones ir api; echo $?          # 1, y te dice que existe api-2
starter/bin/sesiones nueva api /tmp           # la crea y te conecta; sal con prefix d
starter/bin/sesiones grupo api espejo
starter/bin/sesiones                          # tres sesiones, la última usada primero
tmux -L kit kill-server; unset TMUX_SOCKET

./scripts/verificar-semana.sh 03              # desde la raíz del repositorio
```

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
