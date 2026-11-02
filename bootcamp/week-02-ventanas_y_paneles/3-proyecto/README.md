# Proyecto Semana 02 — tmux-kit: kit-layout

⏱ Duración estimada: ~3 h

## Contexto

Cada mañana abres tu proyecto y repites el mismo ritual: una ventana, partir a la derecha, partir abajo, ajustar el ancho, `cd` en cada panel. Diez atajos antes de escribir una línea de código. Tus compañeros hacen lo mismo con layouts distintos, y cuando alguien te enseña uno que te gusta no hay forma de copiarlo.

Añades a tu `tmux-kit` el script **`bin/kit-layout`**: construye la ventana de trabajo de un comando y guarda o carga cualquier layout como un archivo de texto que puedes versionar y compartir.

La ventana que construye es el layout `main-vertical` del [diagrama de layouts](../0-assets/01-cinco-layouts.svg): el editor a la izquierda y dos paneles apilados a la derecha.

## Estructura del proyecto

```
starter/                 ← tu tmux-kit de la semana 01 + lo nuevo
├── README.md            ← añade kit-layout y la bitácora de la semana 02
└── bin/
    ├── check-version    (semana 01)
    ├── kit-tree         (semana 01)
    └── kit-layout       ← TODOs
```

Si prefieres seguir con tu propio kit, copia en él `starter/bin/kit-layout` y trabaja ahí; el autograding solo mira el comportamiento.

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

## Verificación

```bash
export TMUX_SOCKET=kit                       # servidor aislado para probar
starter/bin/kit-layout new api /tmp          # ventana trabajo lista en la sesión api
starter/bin/kit-layout new api; echo $?      # 1: ya existe
TMUX_SOCKET=kit starter/bin/kit-tree         # mira la ventana trabajo y sus 3 paneles
tmux -L kit attach -t api                    # compruébalo a ojo; sal con prefix d

starter/bin/kit-layout save api:trabajo /tmp/trabajo.layout
tmux -L kit select-layout -t api:trabajo tiled
starter/bin/kit-layout load api:trabajo /tmp/trabajo.layout   # vuelve a su sitio
tmux -L kit kill-server; unset TMUX_SOCKET

./scripts/verificar-semana.sh 02             # desde la raíz del repositorio
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 02` desde la raíz del repositorio
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
- Un layout tuyo guardado en el kit (por ejemplo `layouts/trabajo.layout`) y documentado.

> **Si tu shell cambia el título del panel** (oh-my-zsh y algunos prompts lo
> hacen con una secuencia de escape), el título `editor` puede sustituirse por
> el nombre del directorio. En tmux 3.5+ lo evitas con
> `set -p allow-set-title off`; en 3.4 desactiva el título automático de tu
> prompt. El autograding corre en el laboratorio, con bash, y no se ve afectado.

## Entrega

Commit con el mensaje:
```
feat(week-02): kit-layout con ventana de trabajo y layouts guardados
```
