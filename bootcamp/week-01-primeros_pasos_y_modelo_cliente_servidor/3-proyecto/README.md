# Proyecto Semana 01 — tmux-kit: check-version y kit-tree

⏱ Duración estimada: ~3 h

## Contexto

Entras en un equipo de plataforma que mantiene una flota de servidores Linux. Todo el mundo trabaja por SSH dentro de tmux, pero cada persona tiene una versión distinta: unos con 3.2a, otros con 3.4, alguno con una versión compilada a mano. Los scripts del equipo fallan de forma rara en las versiones viejas y nadie sabe qué sesiones quedaron abiertas en cada máquina.

Empiezas tu **`tmux-kit`**, el kit personal que irás ampliando todo el bootcamp ([docs/proyecto-hilo-conductor.md](../../../docs/proyecto-hilo-conductor.md)), con dos herramientas que el equipo necesita hoy:

- **`bin/check-version`**: dice si el tmux de la máquina cumple la versión mínima, con un código de salida que otros scripts puedan usar.
- **`bin/kit-tree`**: dibuja qué hay en un servidor de tmux (sesiones, ventanas, paneles) **sin tocar nada**.

## Estructura del proyecto

```
starter/                 ← aquí trabajas: es tu tmux-kit (lo corrige el autograding)
├── README.md            ← documentación del kit (TODOs)
└── bin/
    ├── check-version    ← TODOs
    └── kit-tree         ← TODOs
tests/
└── fake-tmux            ← imita "tmux -V" con la versión que le digas; no lo toques
```

## Lo que debes construir

### `bin/check-version [MINIMA]`

1. Lee la versión con `"${TMUX_BIN:-tmux}" -V`. La mínima por defecto es `3.4`; si te pasan un argumento, esa es la mínima. Una mínima que no sea `MAYOR.MENOR` (por ejemplo `3`) sale con **2**.
2. Si la versión cumple, imprime `tmux 3.4 >= 3.4: ok` y sale con **0**. Si es más vieja, sale con **1**.
3. Acepta los formatos reales de `tmux -V`: `tmux 3.4`, `tmux 3.5a` (la letra es un parche: cuenta como 3.5) y `tmux next-3.9` (versión de desarrollo: cuenta como 3.9).
4. Compara **mayor y menor como números**, por separado. `3.10` es mayor que `3.9`.
5. Al rechazar, el mensaje (por stderr) dice la versión encontrada y la mínima, y qué hacer: `tmux 3.2a < 3.4: actualiza tmux (docs/setup-entorno.md)`.
6. Si tmux no está instalado (o `TMUX_BIN` apunta a algo que no existe), avisa por stderr y sale con **2**. También con 2 si la salida de `-V` no se entiende.

### `bin/kit-tree`

7. Habla con tmux solo a través de la función `tmx` del starter, que respeta `TMUX_BIN` y `TMUX_SOCKET` (equivale a `tmux -L "$TMUX_SOCKET"`).
8. Si no hay servidor, avisa por stderr y sale con **1**. **Nunca arranca un servidor**: usa `list-sessions`, no `new-session`.
9. Imprime el árbol con este formato exacto (dos espacios por nivel; el último campo del panel es su programa, `bash` o `zsh` según tu shell):

```
socket: /tmp/tmux-1000/kit
sesion api ventanas=2 clientes=0
  ventana 0:editor paneles=2
    panel 0 %0 bash
    panel 1 %1 bash
  ventana 1:logs paneles=1
    panel 0 %2 bash
sesion notas ventanas=1 clientes=0
  ventana 0:bash paneles=1
    panel 0 %3 bash
```

10. Recorre las sesiones por **id** (`#{session_id}`) y las ventanas por id (`#{window_id}`), no por nombre.

### El kit

11. Completa `starter/README.md`: qué es el kit, la versión mínima, cada script con un ejemplo y la bitácora de la semana.
12. Haz commit de `starter/` en tu copia del repositorio.

## Paso a paso

### Paso 0 — Preparar la terminal

Fuera de tmux y desde la raíz del repositorio:

```bash
cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/3-proyecto
starter/bin/check-version; echo $?
```
```
check-version: sin implementar (min=3.4, bin=tmux)
99
```

Instala `shellcheck` si no lo tienes (`shellcheck --version` lo dice):
`sudo apt install shellcheck` en Ubuntu/WSL2 o `brew install shellcheck` en
macOS. El laboratorio Docker ya lo trae.

Todos los comandos de prueba se ejecutan desde `3-proyecto/`. `tests/fake-tmux`
imita a tmux: con `FAKE_TMUX_VERSION=3.2a TMUX_BIN=tests/fake-tmux`, tu script
cree que tiene tmux 3.2a.

### Paso 1 — `check-version`, TODO 1: leer la versión

Abre `starter/bin/check-version`. Guarda la salida de `"$bin" -V` en `output`
dentro de un `if ! output=$(...); then`, con `2>/dev/null` para que el error
del sistema no se mezcle con el tuyo. Si falla, escribe tu aviso con `>&2` y
`exit 2`. Prueba:

```bash
TMUX_BIN=/ruta/que/no/existe/tmux starter/bin/check-version; echo $?
```
Algo como (el texto es el tuyo):
```
tmux no está instalado o '/ruta/que/no/existe/tmux' no se puede ejecutar
2
```

### Paso 2 — TODO 2: extraer mayor y menor

- `version=${output#tmux }` quita `tmux ` del principio; repite con `next-`.
- `[[ "$version" =~ ^([0-9]+)\.([0-9]+) ]]` casa y deja los números en
  `BASH_REMATCH[1]` y `BASH_REMATCH[2]`. Sin `$` al final, la `a` de `3.5a`
  no estorba.
- Si no casa: aviso por stderr y `exit 2`.

```bash
FAKE_TMUX_VERSION=rara TMUX_BIN=tests/fake-tmux starter/bin/check-version; echo $?
```
Algo como:
```
no entiendo la versión: 'tmux rara'
2
```

### Paso 3 — TODO 3: validar la mínima

Lo mismo con `"$min"`, pero con `$` al final de la expresión
(`^([0-9]+)\.([0-9]+)$`): la mínima es exactamente `MAYOR.MENOR`. Guarda los
números en `min_major` y `min_minor`.

```bash
starter/bin/check-version 3; echo $?
```
Algo como:
```
versión mínima inválida: '3' (formato MAYOR.MENOR, p. ej. 3.4)
2
```

### Paso 4 — TODO 4: comparar

Con `(( ))` bash compara números: cumple si
`major > min_major || (major == min_major && minor >= min_minor)`. Imprime
`"$output >= $min: ok"` o, por stderr y con `exit 1`,
`"$output < $min: actualiza tmux (docs/setup-entorno.md)"`. **Borra** las dos
últimas líneas del starter (`echo "check-version: sin implementar ..."` y
`exit 99`). Prueba todos los casos:

```bash
for v in 3.4 3.5a next-3.9 3.2a; do
  FAKE_TMUX_VERSION=$v TMUX_BIN=tests/fake-tmux starter/bin/check-version; echo "rc=$?"
done
FAKE_TMUX_VERSION=3.9 TMUX_BIN=tests/fake-tmux starter/bin/check-version 3.10; echo "rc=$?"
starter/bin/check-version; echo "rc=$?"
```
```
tmux 3.4 >= 3.4: ok
rc=0
tmux 3.5a >= 3.4: ok
rc=0
tmux next-3.9 >= 3.4: ok
rc=0
tmux 3.2a < 3.4: actualiza tmux (docs/setup-entorno.md)
rc=1
tmux 3.9 < 3.10: actualiza tmux (docs/setup-entorno.md)
rc=1
tmux 3.4 >= 3.4: ok
rc=0
```
La última línea muestra tu tmux real (`3.4` o superior). Los mensajes de
rechazo salen por stderr: con `2>/dev/null` desaparecen, pero el código 1 sigue.

### Paso 5 — `kit-tree`, TODO 1: sin servidor, salir con 1

Abre `starter/bin/kit-tree`. Guarda los ids con
`if ! sessions=$(tmx list-sessions -F '#{session_id}' 2>/dev/null); then`,
avisa por stderr y `exit 1`. **Borra** las tres últimas líneas del starter
(`echo "kit-tree: sin implementar"`, `tmx -V >/dev/null` y `exit 99`).

```bash
TMUX_SOCKET=kit starter/bin/kit-tree; echo $?
tmux -L kit ls
```
Algo como:
```
no hay servidor tmux en ese socket
1
error connecting to /tmp/tmux-1000/kit (No such file or directory)
```
La última línea la da tmux (o `no server running on /tmp/tmux-1000/kit` si
el archivo del socket existe de antes): tu script no arrancó ningún servidor.

### Paso 6 — Un servidor de prueba

Crea el servidor `kit` con la forma del ejemplo del punto 9:

```bash
tmux -L kit -f /dev/null new -d -s api -n editor
tmux -L kit split-window -t api:editor
tmux -L kit new-window -d -t api: -n logs
tmux -L kit new -d -s notas
```
(sin salida). Déjalo vivo hasta el paso 9.

### Paso 7 — TODO 2: la ruta del socket

`display-message -p` imprime un formato. Dale como target el primer id de
sesión, `"$(head -n1 <<<"$sessions")"`, y el formato
`'socket: #{socket_path}'`.

```bash
TMUX_SOCKET=kit starter/bin/kit-tree
```
```
socket: /tmp/tmux-1000/kit
```

### Paso 8 — TODO 3: una línea por sesión

Recorre `"$sessions"` con `while IFS= read -r session; do ... done <<<"$sessions"`
y, por cada una, `tmx display-message -p -t "$session"` con el formato
`'sesion #{session_name} ventanas=#{session_windows} clientes=#{session_attached}'`.

```bash
TMUX_SOCKET=kit starter/bin/kit-tree
```
```
socket: /tmp/tmux-1000/kit
sesion api ventanas=2 clientes=0
sesion notas ventanas=1 clientes=0
```

### Paso 9 — TODO 4: ventanas y paneles

Dentro del bucle de sesiones, un segundo bucle sobre las ventanas:
`while IFS= read -r window; do ... done < <(tmx list-windows -t "$session" -F '#{window_id}')`.
Por cada ventana:

- `tmx display-message -p -t "$window"` con
  `'  ventana #{window_index}:#{window_name} paneles=#{window_panes}'`
  (`#{window_panes}` es el número de paneles de la ventana).
- `tmx list-panes -t "$window" -F` con
  `'    panel #{pane_index} #{pane_id} #{pane_current_command}'`
  (`#{pane_current_command}` es el programa que corre en el panel).

```bash
TMUX_SOCKET=kit starter/bin/kit-tree
tmux -L kit kill-server
```
Imprime el árbol completo del punto 9 (con `zsh` en vez de `bash` si esa es
tu shell). `kill-server` no imprime nada.

### Paso 10 — Calidad, README y commit

```bash
shellcheck starter/bin/*; echo $?
grep -n TODO starter/bin/*
```
```
0
```
`shellcheck` sin avisos y `grep` sin resultados. Completa los `TODO` de
`starter/README.md` (punto 11) y haz commit desde tu copia del repositorio:

```bash
git add starter
git commit -m "feat(week-01): tmux-kit con check-version y kit-tree"
```

### Paso 11 — Autograding

```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 01
```
Se ejecuta dentro del laboratorio Docker (tmux 3.4), así que necesitas Docker
en marcha; sin Docker, añade `--host` para usar tu tmux. Con todo hecho:
```
Semana 01 — Primeros pasos y modelo cliente-servidor

  ✅ check-version acepta tmux 3.4
  ✅ check-version acepta tmux 3.8
  ...
  ✅ Los scripts de bin/ no tienen TODOs y pasan shellcheck

16/16 comprobaciones superadas.
```
Cada ❌ trae una pista con el paso donde se arregla.

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 01` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] check-version acepta tmux 3.4
- [ ] check-version acepta tmux 3.8
- [ ] check-version acepta versiones con letra de parche como 3.5a
- [ ] check-version acepta versiones de desarrollo como next-3.9
- [ ] check-version compara números y no texto: 3.9 es menor que 3.10
- [ ] check-version sale con 1 ante tmux 3.2a
- [ ] Al rechazar una versión, check-version muestra la encontrada y la mínima
- [ ] check-version sale con 2 si tmux no está instalado
- [ ] check-version acepta el tmux instalado
- [ ] Sin servidor, kit-tree sale con 1 y no arranca ninguno
- [ ] kit-tree empieza con la ruta del socket del servidor
- [ ] kit-tree muestra una línea por sesión
- [ ] La línea de sesión dice cuántas ventanas y clientes tiene
- [ ] Cada ventana aparece bajo su sesión con índice, nombre y paneles
- [ ] Cada panel aparece bajo su ventana con índice e id
- [ ] Los scripts de bin/ no tienen TODOs y pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- `shellcheck starter/bin/*` sin avisos y ningún `TODO` pendiente.
- Mensajes de error por stderr que dicen qué pasó y qué hacer.
- Comentarios que explican el porqué, no el qué.
- Todas las llamadas a tmux de `kit-tree` pasan por `tmx`.
- El kit está en git (paso 10).

## Entrega

Commit con el mensaje `feat(week-01): tmux-kit con check-version y kit-tree`
que incluya `starter/README.md`, `starter/bin/check-version` y
`starter/bin/kit-tree`.
