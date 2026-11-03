# Labs — Semana 01: Primeros pasos y modelo cliente-servidor

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-primera-sesion](lab-01-primera-sesion/) | Comprobar tu versión de tmux, abrir y cerrar sesiones y crear una sin conectarte | ~60 min |
| 2 | [lab-02-detach-y-attach](lab-02-detach-y-attach/) | Desconectarte de una sesión que sigue trabajando y volver a ella desde uno o dos clientes | ~60 min |
| 3 | [lab-03-prefix-y-linea-de-comandos](lab-03-prefix-y-linea-de-comandos/) | Comprobar que cada atajo es un comando de tmux y ejecutarlos desde el prompt y desde fuera | ~60 min |
| 4 | [lab-04-sesion-ventana-panel](lab-04-sesion-ventana-panel/) | Construir una sesión con ventanas y paneles, a mano y con un script, e identificar cada objeto por su id | ~60 min |
| 5 | [lab-05-servidores-y-sockets](lab-05-servidores-y-sockets/) | Levantar varios servidores, encontrar sus sockets y entender por qué tmux se niega a anidarse | ~60 min |
| 6 | [lab-06-sobrevivir-a-una-desconexion](lab-06-sobrevivir-a-una-desconexion/) | Demostrar que un trabajo largo dentro de tmux sobrevive al cierre de la terminal | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

- Todos los labs usan un servidor aparte (`tmux -L lab`, o `alfa`/`beta` en el
  lab 05) arrancado con `-f /dev/null`: no toca tus sesiones de verdad ni
  carga ninguna configuración, así que el prefix es el de fábrica, `C-b`.
- Cada lab empieza con un **paso 0**: `cd` a su carpeta desde la raíz del
  repositorio, en una terminal **fuera de tmux** (`echo "$TMUX"` imprime una
  línea vacía).
- Puedes hacerlos en tu equipo o en el laboratorio Docker (tmux 3.4). Desde
  la raíz del repositorio en tu equipo:

  ```bash
  docker compose run --rm lab     # una sola terminal
  ```

  Los labs 02, 03, 04 y 06 piden **dos terminales**. Deja el contenedor
  corriendo y entra desde cada una:

  ```bash
  docker compose up -d lab        # una vez
  docker compose exec lab bash    # en cada terminal: entras en /bc-tmux, la raíz del repositorio
  docker compose down             # al terminar
  ```

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
