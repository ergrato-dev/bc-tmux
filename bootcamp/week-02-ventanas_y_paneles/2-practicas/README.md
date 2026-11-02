# Labs — Semana 02: Ventanas y paneles

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-split-y-navegacion](lab-01-split-y-navegacion/) | Partir paneles, moverte entre ellos, abrirlos en el directorio correcto y titularlos | ~60 min |
| 2 | [lab-02-resize-y-zoom](lab-02-resize-y-zoom/) | Cambiar el tamaño de un panel con teclas y con medidas exactas, y hacer zoom | ~60 min |
| 3 | [lab-03-layouts](lab-03-layouts/) | Recorrer los cinco layouts, ajustar el panel principal y guardar un layout propio | ~60 min |
| 4 | [lab-04-mover-paneles-y-ventanas](lab-04-mover-paneles-y-ventanas/) | Sacar un panel a su ventana, meterlo en otra e intercambiar paneles y ventanas | ~60 min |
| 5 | [lab-05-sincronizar-paneles](lab-05-sincronizar-paneles/) | Escribir en varios paneles a la vez, con `synchronize-panes` y con `send-keys` | ~60 min |
| 6 | [lab-06-ventana-rota](lab-06-ventana-rota/) | Depurar un script que monta mal una ventana (4 errores reales) | ~60 min |

**Total labs: 6 horas**

Igual que en la semana 01, todo va contra un servidor aparte: `tmux -L lab`.
En el laboratorio, para varias terminales: `docker compose up -d lab` y
`docker compose exec lab bash` en cada una. Al terminar cada lab:
`tmux -L lab kill-server`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
