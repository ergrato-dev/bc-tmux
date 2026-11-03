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

Antes de cada lab:

- Igual que en la semana 01, todo va contra un servidor aparte, `tmux -L lab`,
  arrancado con `-f /dev/null` (sin config): el prefix es `C-b`.
- Casi todos los labs usan dos terminales **fuera de tmux**: la A, conectada a
  la sesión, y la B, para los comandos. En el laboratorio Docker:
  `docker compose up -d lab` y `docker compose exec lab bash` en cada una.
- Al terminar cada lab: `C-b` `d` en la terminal A y `tmux -L lab kill-server`
  en la B.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
