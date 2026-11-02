# Proyecto Semana 01 — tmux-kit: check-version y kit-tree

⏱ Duración estimada: ~3 h

## Contexto

Entras en un equipo de plataforma que mantiene una flota de servidores Linux. Todo el mundo trabaja por SSH dentro de tmux, pero cada persona tiene una versión distinta: unos con 3.2a, otros con 3.4, alguno con una versión compilada a mano. Los scripts del equipo fallan de forma rara en las versiones viejas y nadie sabe qué sesiones quedaron abiertas en cada máquina.

Empiezas tu **`tmux-kit`**, el kit personal que irás ampliando todo el bootcamp ([docs/proyecto-hilo-conductor.md](../../../docs/proyecto-hilo-conductor.md)), con dos herramientas que el equipo necesita hoy:

- **`bin/check-version`**: dice si el tmux de la máquina cumple la versión mínima, con un código de salida que otros scripts puedan usar.
- **`bin/kit-tree`**: dibuja qué hay en un servidor de tmux (sesiones, ventanas, paneles) **sin tocar nada**.

## Estructura del proyecto

```
starter/                 ← aquí trabajas: es tu tmux-kit
├── README.md            ← documentación del kit (TODOs)
└── bin/
    ├── check-version    ← TODOs
    └── kit-tree         ← TODOs
tests/
└── fake-tmux            ← lo usa el autograding para simular versiones; no lo toques
```

## Lo que debes construir

### `bin/check-version [MINIMA]`

1. Lee la versión con `"${TMUX_BIN:-tmux}" -V`. La mínima por defecto es `3.4`; si te pasan un argumento, esa es la mínima.
2. Si la versión cumple, imprime `tmux 3.4 >= 3.4: ok` y sale con **0**. Si es más vieja, sale con **1**.
3. Acepta los formatos reales de `tmux -V`: `tmux 3.4`, `tmux 3.5a` (la letra es un parche: cuenta como 3.5) y `tmux next-3.9` (versión de desarrollo: cuenta como 3.9).
4. Compara **mayor y menor como números**, por separado. `3.10` es mayor que `3.9`.
5. Al rechazar, el mensaje dice la versión encontrada y la mínima, y qué hacer: `tmux 3.2a < 3.4: actualiza tmux (docs/setup-entorno.md)`.
6. Si tmux no está instalado (o `TMUX_BIN` apunta a algo que no existe), avisa y sale con **2**. También con 2 si la salida de `-V` no se entiende.

Pruébalo con versiones que no tienes:

```bash
FAKE_TMUX_VERSION=3.2a TMUX_BIN=tests/fake-tmux starter/bin/check-version; echo $?
```

### `bin/kit-tree`

7. Habla con tmux solo a través de la función `tmx` del starter, que respeta `TMUX_BIN` y `TMUX_SOCKET` (equivale a `tmux -L "$TMUX_SOCKET"`).
8. Si no hay servidor, avisa por stderr y sale con **1**. **Nunca arranca un servidor**: usa `list-sessions`, no `new-session`.
9. Imprime el árbol con este formato exacto (dos espacios por nivel):

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

11. Completa `README.md`: qué es el kit, la versión mínima, cada script con un ejemplo y la bitácora de la semana.
12. Convierte `starter/` en un repositorio git (o copia su contenido a tu propio repositorio `tmux-kit`) y haz el primer commit.

## Verificación

```bash
# Versión
starter/bin/check-version                 # tmux 3.4 >= 3.4: ok
starter/bin/check-version 9.0; echo $?    # 1

# Árbol de un servidor aislado
tmux -L kit new -d -s api -n editor
tmux -L kit split-window -t api:editor
tmux -L kit new-window -d -t api: -n logs
tmux -L kit new -d -s notas
TMUX_SOCKET=kit starter/bin/kit-tree
tmux -L kit kill-server

# Sin servidor: sale con 1 y no crea ninguno
TMUX_SOCKET=kit starter/bin/kit-tree; echo $?   # 1
tmux -L kit ls                                  # no server running

# Autograding (desde la raíz del repositorio)
./scripts/verificar-semana.sh 01
```

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

- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- Mensajes de error por stderr que dicen qué pasó y qué hacer.
- Comentarios que explican el porqué, no el qué.
- Todas las llamadas a tmux pasan por `tmx`.
- El kit está en git.

## Entrega

Commit con el mensaje:
```
feat(week-01): tmux-kit con check-version y kit-tree
```

Archivos a entregar: `README.md`, `bin/check-version` y `bin/kit-tree` de tu kit.
