# Semana 02 — Ventanas y paneles

## Descripción

Repartirás una ventana en paneles, los moverás entre ventanas sin cerrar sus programas y usarás layouts para ordenarlos. Lo importante no son los atajos sino los comandos que hay detrás: con ellos y con los ids de panel, tu ventana de trabajo se monta con un solo script.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Partir paneles, moverte entre ellos y abrirlos en el directorio que elijas
- Cambiar el tamaño de un panel con teclas y con medidas exactas, y usar el zoom
- Aplicar los cinco layouts y fijar el tamaño del panel principal en porcentaje
- Guardar un layout como texto y restaurarlo con `select-layout`
- Mover paneles entre ventanas con `break-pane` y `join-pane` sin reiniciar sus programas
- Enviar el mismo comando a varios paneles de forma segura
- Construir paneles desde un script con ids, nunca con índices

## Prerrequisitos

- [Semana 01](../week-01-primeros_pasos_y_modelo_cliente_servidor/README.md) completada: servidor, sesiones, ids y `tmux-kit` con `check-version` y `kit-tree`
- Laboratorio Docker construido (`docker compose build`)
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-ventanas-y-paneles.md](1-teoria/01-ventanas-y-paneles.md) · [02-layouts-y-reorganizacion.md](1-teoria/02-layouts-y-reorganizacion.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-split-y-navegacion](2-practicas/lab-01-split-y-navegacion/) | 60 min |
| 2 | Lab | [lab-02-resize-y-zoom](2-practicas/lab-02-resize-y-zoom/) | 60 min |
| 3 | Lab | [lab-03-layouts](2-practicas/lab-03-layouts/) | 60 min |
| 4 | Lab | [lab-04-mover-paneles-y-ventanas](2-practicas/lab-04-mover-paneles-y-ventanas/) | 60 min |
| 5 | Lab | [lab-05-sincronizar-paneles](2-practicas/lab-05-sincronizar-paneles/) | 60 min |
| 6 | Lab | [lab-06-ventana-rota](2-practicas/lab-06-ventana-rota/) | 60 min |
| — | Proyecto | [tmux-kit: kit-layout](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (ventanas y paneles + layouts y reorganización)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Partir, moverte, directorio y títulos
[60 min] lab-02 — Tamaño en celdas y porcentajes, y zoom
[60 min] lab-03 — Los cinco layouts y un layout propio guardado
[60 min] lab-04 — break-pane, join-pane, swap y rotate
[60 min] lab-05 — synchronize-panes y send-keys seguro
[60 min] lab-06 — Depurar un script que monta mal una ventana
[3 h]    Proyecto: kit-layout con la ventana de trabajo y layouts guardados
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 02
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los 16 requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y esto debe funcionar en tu equipo:

```bash
TMUX_SOCKET=kit 3-proyecto/starter/bin/kit-layout new prueba /tmp
tmux -L kit attach -t prueba
tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 01 — Primeros pasos y modelo cliente-servidor](../week-01-primeros_pasos_y_modelo_cliente_servidor/README.md) | **Semana 02 — Ventanas y paneles** | Semana 03 — Sesiones, targets y sockets |

[← Volver al índice del bootcamp](../README.md)
