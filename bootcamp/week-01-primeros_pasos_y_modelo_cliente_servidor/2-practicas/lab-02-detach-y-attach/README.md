# Lab 02 — Detach y attach

⏱ Duración estimada: ~60 min

## Objetivo

Desconectarte de una sesión que sigue trabajando, volver a ella y conectar dos clientes a la vez a la misma sesión.

## Contexto

- **Detach** (`prefix` `d`) desconecta tu terminal de la sesión. El servidor y los programas siguen corriendo.
- **Attach** (`tmux attach -t nombre`) vuelve a conectar una terminal: un **cliente** nuevo.
- Varios clientes pueden mirar la misma sesión. Ven lo mismo y escriben en el mismo sitio: así funciona el pair programming con tmux.

Necesitas dos terminales, **A** y **B**. El servidor `lab` arranca con
`-f /dev/null` (sin configuración): el prefix es `C-b`, es decir, pulsa
**Ctrl+b**, suelta, y pulsa la tecla siguiente.

## Instrucciones

0. **Prepara la terminal A.** Fuera de tmux y desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-02-detach-y-attach
   echo "$TMUX"
   tmux -L lab kill-server
   ```
   `echo` imprime una línea vacía (no estás en tmux). `kill-server` borra
   restos de un intento anterior; si no había servidor imprime
   `no server running on /tmp/tmux-1000/lab` o
   `error connecting to /tmp/tmux-1000/lab (No such file or directory)`: es
   normal.

1. **Terminal A.** Abre una sesión y arranca el contador incluido en el lab:
   ```bash
   tmux -L lab -f /dev/null new -s trabajo
   ```
   Ya dentro de tmux (status line verde con `[trabajo]`):
   ```bash
   ./starter/counter.sh
   ```
   Algo como (cambia la hora):
   ```
   23:44:24  segundo 1
   23:44:25  segundo 2
   23:44:26  segundo 3
   ```
   Déjalo corriendo en primer plano.

2. **Terminal A.** Desconéctate con `C-b` `d`. Esas teclas las recoge tmux,
   no el contador. Vuelves a tu shell con:
   ```
   [detached (from session trabajo)]
   ```

3. **Terminal A.** Espera unos 10 segundos y mira el servidor:
   ```bash
   tmux -L lab ls
   ```
   ```
   trabajo: 1 windows (created Mon Nov  2 23:44:23 2026)
   ```
   Sin `(attached)` al final: nadie la mira, pero sigue viva.

4. **Terminal A.** Vuelve:
   ```bash
   tmux -L lab attach -t trabajo
   ```
   El contador va por `segundo 15` o más: **no se detuvo** mientras no
   estabas. Quédate conectado.

5. **Terminal B.** Abre una segunda terminal, fuera de tmux, y conecta un
   segundo cliente a la misma sesión:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-02-detach-y-attach
   tty
   tmux -L lab attach -t trabajo
   ```
   `tty` imprime algo como `/dev/pts/2`: es el nombre de la terminal B,
   anótalo para el paso 8. B muestra el mismo contador que A.

   **Terminal A.** Para el contador con `Ctrl+c` (`^C` aparece en las dos
   terminales) y escribe:
   ```bash
   tmux -L lab list-clients
   ```
   Algo como (cambian los `pts`, los tamaños y el `TERM` de tu terminal):
   ```
   /dev/pts/0: trabajo [80x24 xterm-256color] (attached,focused,UTF-8)
   /dev/pts/2: trabajo [100x30 xterm-256color] (attached,focused,UTF-8)
   ```
   Una línea por cliente, y la salida aparece también en B: escriben en el
   mismo panel. Si las terminales tienen tamaños distintos, tmux ajusta la
   ventana a la última que usaste (opción `window-size latest`) y la otra
   rellena el sobrante con puntos.

6. **TODO de `starter/status.sh`: clientes por sesión.** Abre el archivo y,
   debajo del comentario `TODO`, escribe:
   ```bash
   tmx list-sessions -F '#{session_name}: #{session_attached} clientes'
   ```
   `-F` cambia el formato de cada línea; `#{session_attached}` es el número
   de clientes conectados a la sesión. **Terminal A** (dentro de tmux):
   ```bash
   ./starter/status.sh
   ```
   ```
   trabajo: 2 clientes
   ```

7. **Terminal B.** Desconéctate con `C-b` `d`:
   ```
   [detached (from session trabajo)]
   ```
   **Terminal A:**
   ```bash
   ./starter/status.sh
   ```
   ```
   trabajo: 1 clientes
   ```
   Es el mismo dato que mostrará tu `kit-tree` en el proyecto (`clientes=N`).

8. **Desconectar a otro cliente.** **Terminal B:** vuelve a conectarte con
   `tmux -L lab attach -t trabajo`. **Terminal A:** pulsa `C-b` `D`
   (mayúscula). Se abre una lista de clientes, algo como:
   ```
   (0) /dev/pts/0: 23:46: session trabajo
   (1) /dev/pts/2: 23:46: session trabajo
   ```
   Muévete con `↑`/`↓` hasta la línea de la terminal B (el `tty` del paso 5)
   y pulsa **Enter**. La terminal B recibe
   `[detached (from session trabajo)]`. Para salir de la lista sin elegir a
   nadie, pulsa `q`.

9. **Terminal A.** Desconéctate con `C-b` `d`. Ya no queda ningún cliente:
   ```bash
   ./starter/status.sh
   ```
   ```
   trabajo: 0 clientes
   ```

10. Limpia, desde la terminal A:
    ```bash
    tmux -L lab kill-server
    ```
    (sin salida)

## Criterios de éxito

- [ ] Tras un detach de 10 s, el contador muestra que siguió corriendo (paso 4)
- [ ] `tmux -L lab list-clients` muestra dos clientes (paso 5)
- [ ] `./starter/status.sh` imprime `trabajo: 2 clientes`, `1 clientes` y `0 clientes` según quién esté conectado (pasos 6, 7 y 9)
- [ ] Desconectaste la terminal B desde la A con `C-b` `D` (paso 8)
- [ ] Puedes explicar la diferencia entre cerrar una sesión (`exit`) y desconectarte de ella (`prefix` `d`)

## Reto extra

`tmux -L lab attach -d -t trabajo` conecta tu terminal **y desconecta a todos
los demás clientes**. Pruébalo con A y B conectadas. ¿En qué situación real lo
usarías?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Tu primera sesión](../lab-01-primera-sesion/README.md) | [Lab 03 — El prefix y la línea de comandos](../lab-03-prefix-y-linea-de-comandos/README.md) → |

[↑ Semana 01](../../README.md)
