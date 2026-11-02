# Lab 02 — Detach y attach

⏱ Duración estimada: ~60 min

## Objetivo

Desconectarte de una sesión que sigue trabajando, volver a ella y conectar dos clientes a la vez a la misma sesión.

## Contexto

- **Detach** (`prefix` `d`) desconecta tu terminal de la sesión. El servidor y los programas siguen corriendo.
- **Attach** (`tmux attach -t nombre`) vuelve a conectar una terminal: un **cliente** nuevo.
- Varios clientes pueden mirar la misma sesión. Ven lo mismo y escriben en el mismo sitio: así funciona el pair programming con tmux.

## Instrucciones

1. Abre una sesión y arranca el contador incluido en `starter/`:
   ```bash
   tmux -L lab new -s trabajo
   ./starter/contador.sh
   ```
   Imprime un número por segundo.

2. Desconéctate con `prefix` `d`. El prefix por defecto es `C-b`: pulsa
   **Ctrl+b**, suelta, y pulsa **d**. Vuelves a tu shell con:
   ```
   [detached (from session trabajo)]
   ```

3. Espera unos 10 segundos y mira el estado del servidor:
   ```bash
   tmux -L lab ls
   ```
   ```
   trabajo: 1 windows (created ...)
   ```
   Sin `(attached)` al final: nadie la está mirando, pero sigue viva.

4. Vuelve: `tmux -L lab attach -t trabajo`. El contador **no se detuvo**:
   siguió contando mientras no estabas.

5. Abre **otra terminal** y conecta un segundo cliente a la misma sesión:
   ```bash
   tmux -L lab attach -t trabajo
   ```
   Escribe en una terminal y míralo aparecer en la otra. Desde una tercera
   terminal:
   ```bash
   tmux -L lab list-clients
   ```
   Hay dos líneas, una por cliente. Si tus terminales tienen tamaños
   distintos, tmux ajusta la ventana al cliente que usaste por última vez
   (opción `window-size latest`) y la otra terminal rellena el sobrante con
   puntos. Escribe en una y en otra y mira cómo cambia.

6. Completa `starter/estado.sh`: por cada sesión, una línea con su nombre y
   cuántos clientes tiene conectados. Con los dos clientes del paso 5:
   ```bash
   ./starter/estado.sh
   ```
   ```
   trabajo: 2 clientes
   ```
   Desconecta uno con `prefix` `d` y vuelve a ejecutarlo: `trabajo: 1 clientes`.
   Es el mismo dato que mostrará tu `kit-tree` en el proyecto (`clientes=N`).

7. Prueba `prefix` `D` (mayúscula) en una de las terminales: abre una lista de
   los clientes conectados. Elige el otro y pulsa **Enter** para
   desconectarlo desde aquí.

8. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Tras un detach de 10 s, el contador muestra que siguió corriendo
- [ ] `tmux -L lab list-clients` muestra dos clientes en el paso 5
- [ ] `./starter/estado.sh` imprime `trabajo: 2 clientes` con dos clientes y `trabajo: 0 clientes` sin ninguno
- [ ] Puedes explicar la diferencia entre cerrar una sesión (`exit`) y desconectarte de ella (`prefix` `d`)

## Reto extra

`tmux -L lab attach -d -t trabajo` conecta tu terminal **y desconecta a todos
los demás clientes**. ¿En qué situación real lo usarías?
