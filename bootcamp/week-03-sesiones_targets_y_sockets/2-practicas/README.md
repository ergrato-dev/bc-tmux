# Labs — Semana 03: Sesiones, targets y sockets

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-varias-sesiones](lab-01-varias-sesiones/) | Trabajar con varias sesiones: crearlas, verlas en `choose-tree`, renombrarlas y cerrarlas | ~60 min |
| 2 | [lab-02-targets](lab-02-targets/) | Apuntar a cualquier sesión, ventana o panel, y evitar las coincidencias por prefijo | ~60 min |
| 3 | [lab-03-moverte-entre-sesiones](lab-03-moverte-entre-sesiones/) | Saltar entre sesiones con teclas, filtros y `switch-client`, dentro y fuera de tmux | ~60 min |
| 4 | [lab-04-grupos-de-sesiones](lab-04-grupos-de-sesiones/) | Compartir ventanas entre dos sesiones con su propia ventana actual | ~60 min |
| 5 | [lab-05-sockets-y-la-variable-tmux](lab-05-sockets-y-la-variable-tmux/) | Elegir el socket, leer `$TMUX` y recuperar un socket borrado | ~60 min |
| 6 | [lab-06-sesion-rota](lab-06-sesion-rota/) | Depurar un script que abre la sesión de un proyecto (4 errores reales) | ~60 min |

**Total labs: 6 horas**

Todo va contra un servidor aparte: `tmux -L lab`. En el laboratorio, para
varias terminales: `docker compose up -d lab` y `docker compose exec lab bash`
en cada una. Al terminar cada lab: `tmux -L lab kill-server`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
