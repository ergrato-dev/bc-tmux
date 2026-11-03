# Labs — Semana 04: Copy mode, buffers y portapapeles

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-moverte-por-el-historial](lab-01-moverte-por-el-historial/) | Recorrer, buscar y limpiar el historial con copy mode, fijando `mode-keys` y `history-limit` | ~60 min |
| 2 | [lab-02-seleccionar-y-copiar](lab-02-seleccionar-y-copiar/) | Seleccionar por caracteres, líneas y rectángulos, y copiar con `copy-pipe` y el ratón | ~60 min |
| 3 | [lab-03-buffers](lab-03-buffers/) | Crear, pegar, guardar y cargar buffers, y volcarlos a archivos con un script | ~60 min |
| 4 | [lab-04-capture-pane](lab-04-capture-pane/) | Volcar el historial de otro panel con `capture-pane` y un script que valida el target | ~60 min |
| 5 | [lab-05-portapapeles-del-sistema](lab-05-portapapeles-del-sistema/) | Copiar al portapapeles de macOS, WSL, Wayland o X11 desde `copy-command` | ~60 min |
| 6 | [lab-06-portapapeles-roto](lab-06-portapapeles-roto/) | Depurar una config que copia con OSC 52 (4 errores reales) | ~60 min |

**Total labs: 6 horas**

Todo va contra un servidor aparte: `tmux -L lab`. Cada lab empieza con un
paso 0 que dice cuántas terminales abrir (siempre **fuera de tmux**: `echo
"$TMUX"` imprime una línea vacía) y a qué carpeta entrar. En el laboratorio,
para varias terminales: `docker compose up -d lab` una vez y
`docker compose exec lab bash` en cada una. Al terminar cada lab:
`tmux -L lab kill-server`.

Los labs 05 y 06 tocan tu portapapeles real: los pasos 1 y 2 del 05 se hacen
en tu máquina (el contenedor no tiene portapapeles; el resto se prueba con
herramientas falsas); el 06 funciona también en el laboratorio, porque OSC 52
llega a tu terminal.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
