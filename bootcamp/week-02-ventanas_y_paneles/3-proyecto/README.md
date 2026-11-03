# Proyecto Semana 02 — tmux-kit: kit-layout

⏱ Duración estimada: ~3 h

## Contexto

Cada mañana abres tu proyecto y repites el mismo ritual: una ventana, partir a la derecha, partir abajo, ajustar el ancho, `cd` en cada panel. Diez atajos antes de escribir una línea de código. Tus compañeros hacen lo mismo con layouts distintos, y cuando alguien te enseña uno que te gusta no hay forma de copiarlo.

Añades a tu `tmux-kit` el script **`bin/kit-layout`**: construye la ventana de trabajo de un comando y guarda o carga cualquier layout como un archivo de texto que puedes versionar y compartir.

La ventana que construye es el layout `main-vertical` del [diagrama de layouts](../0-assets/01-cinco-layouts.svg): el editor a la izquierda y dos paneles apilados a la derecha.

## Estructura del proyecto

```
starter/                 ← el tmux-kit de la semana 01 + lo nuevo
├── README.md            ← añade kit-layout y la bitácora de la semana 02
├── layouts/             ← lo creas tú (paso 10)
│   └── trabajo.layout
└── bin/
    ├── check-version    (semana 01, terminado)
    ├── kit-tree         (semana 01, terminado)
    └── kit-layout       ← TODOs 1-8
```

`starter/` es el kit con el que terminó la semana 01 (`check-version` y
`kit-tree` ya funcionan) más `kit-layout` por hacer. Trabaja **dentro de
`starter/`**: es la carpeta que corrige `./scripts/verificar-semana.sh 02`.

## Lo que debes construir

### `kit-layout new SESION [DIR]`

1. Si la sesión `SESION` existe, añade en ella una ventana llamada `trabajo`. Si no existe, crea la sesión en segundo plano con esa ventana. En los dos casos no te conecta.
2. La ventana tiene **tres paneles**: `editor` en la columna izquierda con el 60 % del ancho (`main-pane-width 60%` + layout `main-vertical`), y a la derecha `shell` arriba y `logs` abajo. Los tres empiezan en `DIR` (por defecto, el directorio actual).
3. Si la sesión ya tiene una ventana `trabajo`, no crea otra: avisa y sale con **1**.
4. Trabaja con **ids de panel**: guarda el que devuelve cada `new-session`, `new-window` o `split-window` con `-P -F '#{pane_id}'`. Los índices se renumeran al partir; los ids no.
5. Cada panel lleva su título (`select-pane -T`) y, al terminar, el panel activo es `editor`.

### `kit-layout save VENTANA ARCHIVO` y `kit-layout load VENTANA ARCHIVO`

6. `save` escribe en `ARCHIVO` el layout de la ventana (`#{window_layout}`). Si la ventana no existe, sale con **1**. Cuidado: `display-message` no falla con un target inexistente; valida antes con `list-panes -t`.
7. `load` aplica el layout guardado con `select-layout`. Antes comprueba que el archivo tiene un layout de tmux y que describe **tantos paneles como tiene la ventana**; si no, sale con **1** sin tocar la ventana.

### Uso

8. Sin argumentos o con argumentos de más, `kit-layout` muestra el uso y sale con **2** (ya viene hecho en el starter).

### El kit

9. Añade `kit-layout` a la tabla de scripts del `README.md` con un ejemplo y escribe la bitácora de la semana.

## Paso a paso

Todo se hace en una terminal **fuera de tmux** (`echo "$TMUX"` imprime una
línea vacía), contra un servidor aparte `-L kit`: tu tmux de siempre no se
toca.

0. **Prepara el entorno.** Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/3-proyecto
   export TMUX_SOCKET=kit
   tmux -L kit -f /dev/null new -d -s base; echo $?
   ```
   ```
   0
   ```
   `TMUX_SOCKET=kit` hace que `kit-layout` (con su `tmx`) hable con el
   servidor `kit`. La sesión `base` lo arranca con `-f /dev/null`, sin tu
   config, igual que el autograding. Comprueba que el uso ya funciona y que
   `new` aún no:
   ```bash
   starter/bin/kit-layout; echo $?
   starter/bin/kit-layout new api; echo $?
   ```
   ```
   Uso: kit-layout new SESION [DIR]       crea la ventana "trabajo" (editor, shell, logs)
        kit-layout save VENTANA ARCHIVO   guarda el layout de una ventana
        kit-layout load VENTANA ARCHIVO   aplica un layout guardado
   2
   kit-layout new: sin implementar (api /ruta/a/tu/repo/bootcamp/week-02-ventanas_y_paneles/3-proyecto)
   99
   ```

1. **TODO 1, `count_panes`.** Escribe la función en tres líneas,
   `count_panes() {`, la línea de la pista y `}`. Cuenta las hojas del
   layout: `39x24,0,0,2` es un panel (cuatro números tras el tamaño);
   `40x24,40,0[` es un contenedor (dos números y después `{` o `[`). Pruébala
   sola, cargando solo esa función en una shell aparte:
   ```bash
   bash -c 'source <(sed -n "/^count_panes()/,/^}/p" starter/bin/kit-layout); count_panes "1e56,80x24,0,0{39x24,0,0,2,40x24,40,0[40x7,40,0,0,40x4,40,8,1,40x11,40,13,3]}"'
   ```
   ```
   4
   ```

2. **TODO 2, `require_window`.** Una línea: la de la pista, dentro de
   `require_window() { ... }`. La probarás con `save` en el paso 7.

3. **TODO 3, crear la ventana.** Borra la línea `echo "kit-layout new: sin implementar ..."; exit 99`
   de `cmd_new`. La pista tiene las tres ramas. El `=` de `-t "=$session"` pide
   el nombre exacto: sin él, `api` encontraría también `api2`. El `:` final de
   `-t "=$session:"` le dice a `new-window` "en esa sesión, en el primer índice
   libre". Prueba las tres ramas:
   ```bash
   starter/bin/kit-layout new api /tmp; echo $?
   tmux -L kit list-windows -t api -F '#{window_name} #{window_panes}'
   starter/bin/kit-layout new api /tmp; echo $?
   starter/bin/kit-layout new base; echo $?
   tmux -L kit list-windows -t base -F '#{window_index} #{window_name}'
   starter/bin/kit-layout new otra /no/existe; echo $?
   ```
   Algo como (`bash` es el nombre de la primera ventana de `base`; con zsh, `zsh`):
   ```
   0
   trabajo 1
   kit-layout: la sesión api ya tiene una ventana trabajo
   1
   0
   0 bash
   1 trabajo
   kit-layout: no existe el directorio: /no/existe
   1
   ```
   Antes de cada prueba siguiente, vuelve a empezar con el servidor limpio
   (el `sleep 1` da tiempo al servidor viejo a terminar de salir: un `new`
   inmediato choca con él con `server exited unexpectedly`):
   ```bash
   tmux -L kit kill-server; sleep 1; tmux -L kit -f /dev/null new -d -s base
   ```
   ```
   (sin salida)
   ```

4. **TODO 4, partir en tres.** Los dos `split-window` de la pista. Reinicia
   el servidor (bloque del final del paso 3) y prueba:
   ```bash
   starter/bin/kit-layout new api /tmp
   tmux -L kit list-panes -t api:trabajo -F '#{pane_id} #{pane_current_path}'
   ```
   ```
   %1 /tmp
   %2 /tmp
   %3 /tmp
   ```
   (`%0` es el panel de `base`.)

5. **TODO 5, títulos.** Tres `select-pane -T`, cada uno con su id. Reinicia y
   prueba:
   ```bash
   starter/bin/kit-layout new api /tmp
   tmux -L kit list-panes -t api:trabajo -F '#{pane_id} #{pane_title}'
   ```
   ```
   %1 editor
   %2 shell
   %3 logs
   ```

6. **TODO 6, layout y foco.** Primero la opción, después el layout (al revés
   no funciona: lab 06, error 4). Reinicia y prueba:
   ```bash
   starter/bin/kit-layout new api /tmp
   tmux -L kit list-panes -t api:trabajo -F '#{pane_title} #{pane_left} #{pane_top} #{pane_width} #{pane_active}'
   ```
   ```
   ventana trabajo lista en la sesión api
   editor 0 0 47 1
   shell 48 0 32 0
   logs 48 12 32 0
   ```
   Una sesión creada con `-d` mide 80x24: el 60 % son 48 columnas (47 y el
   borde). `editor` es el activo (el `1`).

7. **TODO 7, `save`.** Borra el `echo ... exit 99` de `cmd_save` y sigue la
   pista. Con la ventana del paso 6 viva:
   ```bash
   starter/bin/kit-layout save api:trabajo /tmp/trabajo.layout; echo $?
   cat /tmp/trabajo.layout
   starter/bin/kit-layout save base:9 /tmp/x.layout; echo $?
   ```
   ```
   layout de api:trabajo guardado en /tmp/trabajo.layout (3 paneles)
   0
   c9d9,80x24,0,0{47x24,0,0,1,32x24,48,0[32x11,48,0,2,32x12,48,12,3]}
   kit-layout: no existe la ventana: base:9
   1
   ```
   El autograding comprueba que el archivo empieza como un layout de tmux:
   `^[0-9a-f]{4},[0-9]+x[0-9]+,` (suma de control, coma, tamaño, coma).

8. **TODO 8, `load`.** Borra el `echo ... exit 99` de `cmd_load` y sigue la
   pista en orden: si validas la ventana antes que el archivo, un archivo
   roto daría un mensaje equivocado. Rompe el layout, restáuralo y prueba
   cada error:
   ```bash
   tmux -L kit select-layout -t api:trabajo tiled
   starter/bin/kit-layout load api:trabajo /tmp/trabajo.layout; echo $?
   tmux -L kit display-message -p -t api:trabajo '#{window_layout}'
   starter/bin/kit-layout load base:0 /tmp/trabajo.layout; echo $?
   echo hola > /tmp/malo.layout
   starter/bin/kit-layout load api:trabajo /tmp/malo.layout; echo $?
   starter/bin/kit-layout load api:trabajo /tmp/noexiste.layout; echo $?
   ```
   ```
   layout de /tmp/trabajo.layout aplicado a api:trabajo
   0
   c9d9,80x24,0,0{47x24,0,0,1,32x24,48,0[32x11,48,0,2,32x12,48,12,3]}
   kit-layout: el layout es para 3 paneles y base:0 tiene 1
   1
   kit-layout: /tmp/malo.layout no contiene un layout de tmux
   1
   kit-layout: no puedo leer el archivo: /tmp/noexiste.layout
   1
   ```
   La tercera línea es idéntica al `cat` del paso 7.

9. **Míralo con tus ojos.** `kit-tree` de la semana 01 ya ve la ventana:
   ```bash
   starter/bin/kit-tree
   ```
   Algo como (con zsh verás `zsh` en vez de `bash`):
   ```
   socket: /tmp/tmux-1000/kit
   sesion api ventanas=1 clientes=0
     ventana 0:trabajo paneles=3
       panel 0 %1 bash
       panel 1 %2 bash
       panel 2 %3 bash
   sesion base ventanas=1 clientes=0
     ventana 0:bash paneles=1
       panel 0 %0 bash
   ```
   Conéctate en **esta misma terminal, fuera de tmux** (dentro de tu tmux
   anidarías un tmux en otro y el prefix lo recibiría el de fuera):
   ```bash
   tmux -L kit attach -t api
   ```
   Ves el editor a la izquierda y `shell` sobre `logs` a la derecha. El
   servidor `kit` arrancó con `-f /dev/null`, así que el prefix es `C-b`.
   Sal con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   Para ver los títulos en el borde: `tmux -L kit set -w -t api:trabajo pane-border-status top`
   antes de conectarte.

   > **Si el título `editor` cambia solo** en tu servidor de siempre, tu
   > prompt envía una secuencia de escape que retitula el panel (lab 01,
   > paso 6). En tmux 3.4 se arregla en el prompt: con oh-my-zsh,
   > `DISABLE_AUTO_TITLE="true"` en `~/.zshrc`; con bash, quita la secuencia
   > `\e]0;` de tu `PS1` o `PROMPT_COMMAND`. En tmux 3.5+ basta
   > `set -p allow-set-title off`. El autograding corre en el laboratorio,
   > con bash, y no se ve afectado.

10. **Tu layout en el kit.** Ajusta a mano el reparto que te guste (conéctate
    como en el paso 9 y usa `C-b` `Ctrl`+flechas), desconéctate y guárdalo
    dentro del kit:
    ```bash
    mkdir -p starter/layouts
    starter/bin/kit-layout save api:trabajo starter/layouts/trabajo.layout
    ```
    Algo como:
    ```
    layout de api:trabajo guardado en starter/layouts/trabajo.layout (3 paneles)
    ```

11. **El README del kit.** En `starter/README.md`, sustituye los dos
    `<!-- TODO -->` de la fila de `kit-layout` por qué hace y un ejemplo
    (`bin/kit-layout new api ~/src/api`), y el de la bitácora por lo que
    añadiste esta semana. Explica en dos líneas cómo cargar
    `layouts/trabajo.layout`.

12. **Calidad.** Instala `shellcheck` si no lo tienes (`sudo apt install shellcheck`
    o `brew install shellcheck`; en el laboratorio ya está) y comprueba que no
    queda ningún TODO:
    ```bash
    shellcheck starter/bin/*; echo $?
    grep -n TODO starter/bin/*; echo $?
    ```
    ```
    0
    1
    ```
    `grep` sale con 1 cuando no encuentra nada: es lo que quieres.

13. **Limpia y verifica.**
    ```bash
    tmux -L kit kill-server; unset TMUX_SOCKET; rm -f /tmp/trabajo.layout /tmp/malo.layout
    cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 02
    ```
    Antes del informe, `docker compose` imprime un par de líneas
    `Container ... Creating/Created`. Después:
    ```
    Semana 02 — Ventanas y paneles

      ✅ kit-layout new crea la sesión si no existe
      ✅ La ventana trabajo tiene tres paneles
      ✅ Los paneles se titulan editor, shell y logs
      ✅ El editor ocupa la columna izquierda con un 55-65 % del ancho
      ✅ shell y logs se apilan a la derecha, shell arriba
      ✅ El panel activo al terminar es el editor
      ✅ Los tres paneles empiezan en el directorio indicado
      ✅ En una sesión existente, añade la ventana sin tocar las demás
      ✅ Si la ventana trabajo ya existe, kit-layout new sale con 1
      ✅ Tras dos ejecuciones sigue habiendo una sola ventana trabajo
      ✅ kit-layout save escribe un layout de tmux válido
      ✅ kit-layout load devuelve la ventana al layout guardado
      ✅ kit-layout load sale con 1 si el número de paneles no coincide
      ✅ kit-layout save sale con 1 si la ventana no existe
      ✅ kit-layout sin argumentos sale con 2
      ✅ Los scripts de bin/ no tienen TODOs y pasan shellcheck

      16/16 comprobaciones superadas.
    ```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 02` desde la raíz del repositorio (paso 13)
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] kit-layout new crea la sesión si no existe
- [ ] La ventana trabajo tiene tres paneles
- [ ] Los paneles se titulan editor, shell y logs
- [ ] El editor ocupa la columna izquierda con un 55-65 % del ancho
- [ ] shell y logs se apilan a la derecha, shell arriba
- [ ] El panel activo al terminar es el editor
- [ ] Los tres paneles empiezan en el directorio indicado
- [ ] En una sesión existente, añade la ventana sin tocar las demás
- [ ] Si la ventana trabajo ya existe, kit-layout new sale con 1
- [ ] Tras dos ejecuciones sigue habiendo una sola ventana trabajo
- [ ] kit-layout save escribe un layout de tmux válido
- [ ] kit-layout load devuelve la ventana al layout guardado
- [ ] kit-layout load sale con 1 si el número de paneles no coincide
- [ ] kit-layout save sale con 1 si la ventana no existe
- [ ] kit-layout sin argumentos sale con 2
- [ ] Los scripts de bin/ no tienen TODOs y pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Ningún `-t` con índices de panel (`api:trabajo.1`) después de partir: solo ids.
- Mensajes de error por stderr que dicen qué pasó y cómo seguir.
- Comentarios que explican el porqué (ids, `-d`, validación con `list-panes`).
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- Un layout tuyo guardado en el kit (`layouts/trabajo.layout`, paso 10) y documentado en el `README.md`.

## Entrega

Commit con el mensaje:
```
feat(week-02): kit-layout con ventana de trabajo y layouts guardados
```

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — La ventana rota](../2-practicas/lab-06-ventana-rota/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 02](../README.md)
