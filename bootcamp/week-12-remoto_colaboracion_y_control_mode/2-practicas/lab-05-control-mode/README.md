# Lab 05 — Control mode

⏱ Duración estimada: ~60 min

## Objetivo

Hablar con tmux en control mode (`tmux -C`), leer sus respuestas `%begin`/`%end` y sus eventos, y escribir un script que traduce esos eventos sin quedarse colgado.

## Contexto

- En control mode el cliente no dibuja nada: lee comandos por la entrada, una línea cada uno, y escribe texto plano. Cada respuesta va entre `%begin` y `%end` (o `%error`); además, el servidor avisa de lo que pasa con líneas sueltas: `%window-add`, `%output`, `%session-renamed`…
- Es lo que usa iTerm2 con `tmux -CC` para mostrar ventanas de tmux como pestañas nativas, y lo que puede usar un script para reaccionar a cambios sin preguntar cada segundo.
- Una línea vacía o el fin de la entrada desconectan al cliente. Por eso un script debe mantener la entrada abierta mientras escucha, y ponerle un límite con `timeout`.

## Instrucciones

0. **Dónde.** Terminal A dentro del laboratorio (`docker compose exec lab bash`),
   fuera de tmux (`echo "$TMUX"` vacío). Un servidor sin config (prefix
   `C-b`, aunque aquí no pulsas ninguna tecla de tmux):
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-05-control-mode
   tmux -L cm -f /dev/null new -d -s cm; echo $?
   ```
   ```
   0
   ```

1. **A mano.** Conéctate en control mode en la terminal A:
   ```bash
   timeout 120 tmux -L cm -C attach -t cm
   ```
   No hay barra ni prompt: escribe estas tres líneas, una cada vez, con
   `Enter` al final de cada una:
   ```
   list-windows -F "#{window_index} #{window_name}"
   display -p nope-#{session_name}
   new-window -n w2
   ```
   Y después pulsa `Enter` en una línea vacía para salir. Algo como (cambian
   los números de `%begin`; tus líneas se ven mezcladas con las respuestas):
   ```
   %begin 1793742860 269 0
   %end 1793742860 269 0
   %session-changed $0 cm
   %begin 1793742860 274 1
   0 bash
   %end 1793742860 274 1
   %begin 1793742860 275 1
   parse error: syntax error
   %error 1793742860 275 1
   %begin 1793742860 276 1
   %end 1793742860 276 1
   %session-window-changed $0 @1
   %window-add @1
   %exit
   ```
   - `%begin HORA NÚMERO FLAGS`: el número empareja cada `%begin` con su
     `%end`; flags `1` es un comando tuyo, `0` el `attach` del principio.
   - El segundo comando falla porque `#` sin comillas empieza un
     comentario: cita siempre los formats.
   - `new-window` no imprime nada (`%begin` y `%end` seguidos), pero el
     servidor avisa: `%window-add @1`.
   - `timeout 120` es el seguro por si olvidas salir.

2. **`%output`.** Lo que escribe cada panel llega como `%output %PANEL texto`,
   con los no imprimibles en octal. Esta vez los comandos van por una
   tubería, y `sleep 1` mantiene la entrada abierta un segundo para que
   llegue la salida:
   ```bash
   ( echo 'send-keys -t cm:0 "echo hola" Enter'; sleep 1 ) | timeout 5 tmux -L cm -C attach -t cm | grep '^%output' | head -2 | cut -c1-40
   ```
   ```
   %output %0 echo hola\015\012\033[?2004l\
   %output %0 \033[?2004h\033[01;32malumno@
   ```
   `\015\012` es el fin de línea de la terminal (CR LF) y `\033[...` son
   los colores del prompt. Al cerrarse la entrada, el cliente se desconectó
   solo.

3. **TODO 1 — conectar sin colgarse.** El starter funciona, pero no escucha
   nada:
   ```bash
   TMUX_SOCKET=cm ./starter/events.sh cm 2; echo $?
   TMUX_SOCKET=cm ./starter/events.sh nada 2; echo $?
   ```
   ```
   0
   events.sh: no existe la sesión nada
   1
   ```
   En `starter/events.sh` borra la línea `echo "sin implementar ($secs s)" |` y pon
   en su lugar las dos líneas del TODO 1, sin el `#`. Pruébalo con un
   cambio que todavía no traduce nadie:
   ```bash
   time TMUX_SOCKET=cm ./starter/events.sh cm 2
   ```
   Algo como (los tiempos varían un poco):
   ```
   real	0m2.012s
   user	0m0.004s
   sys	0m0.006s
   ```
   Termina a los 2 segundos: cuando acaba `sleep`, tmux recibe el fin de
   la entrada y se desconecta. Sin `sleep` saldría al instante; sin la
   tubería, esperaría a que tú escribieras.

4. **TODO 2 — ventanas.** Añade los tres casos del TODO 2 al `case`. Lanza
   el script en segundo plano y cambia ventanas mientras escucha:
   ```bash
   TMUX_SOCKET=cm ./starter/events.sh cm 3 & sleep 0.5
   tmux -L cm new-window -n logs
   tmux -L cm rename-window -t cm:logs registros
   tmux -L cm kill-window -t cm:registros
   wait
   ```
   Algo como (cambia el `@N` y bash imprime `[1] PID` y `[1]+ Done`):
   ```
   ventana nueva: @2
   ventana @2 renombrada: registros
   ventana cerrada: @2
   ```
   `new-window -n` no da `%window-renamed`: el nombre viene desde el
   principio. Los eventos traen ids (`@2`), no nombres: un id no cambia
   aunque renombres la ventana.

5. **TODO 3 — sesión y fin.** Los dos casos del TODO 3:
   ```bash
   TMUX_SOCKET=cm ./starter/events.sh cm 3 & sleep 0.5
   tmux -L cm rename-session -t cm trabajo
   wait
   tmux -L cm rename-session -t trabajo cm
   ```
   ```
   sesión renombrada: trabajo
   fin del control mode
   ```
   El script se conectó con `-t "=cm"` y la sesión cambió de nombre debajo:
   el cliente sigue en ella, porque está conectado a la sesión, no al
   nombre.

6. **`-CC` necesita una terminal.** La variante de iTerm2 se niega sin
   terminal:
   ```bash
   tmux -L cm -CC attach -t cm </dev/null; echo $?
   ```
   ```
   tcgetattr failed: Inappropriate ioctl for device
   1
   ```
   Con una (aquí, la que crea `script`) empieza con una secuencia de escape
   que iTerm2 reconoce, `ESC P1000p`, y sigue igual que `-C`:
   ```bash
   sleep 1 | timeout 3 script -qc "tmux -L cm -CC attach -t cm" /dev/null | head -c 30 | cat -v; echo
   ```
   Algo como:
   ```
   ^[P1000p%begin 1793742872 269 0
   ```

7. **Limpia** (terminal A):
   ```bash
   tmux -L cm kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas qué empareja el número de `%begin`/`%end` y por qué `display -p nope-#{session_name}` da `%error` (paso 1)
- [ ] `time TMUX_SOCKET=cm ./starter/events.sh cm 2` termina en unos 2 segundos (paso 3)
- [ ] Crear, renombrar y cerrar una ventana imprime `ventana nueva: @N`, `ventana @N renombrada: registros` y `ventana cerrada: @N` (paso 4)
- [ ] Renombrar la sesión imprime `sesión renombrada: trabajo` y al final `fin del control mode` (paso 5)
- [ ] `shellcheck starter/events.sh` no imprime nada (instálalo con `sudo apt install shellcheck` o `brew install shellcheck` si trabajas fuera del laboratorio)

## Reto extra

Añade un modo `--once EVENTO`: el script sale con 0 en cuanto ve ese
evento (por ejemplo `%window-add`) y con 1 si se acaba el tiempo. Así un
script puede esperar a que algo pase en tmux sin preguntar en bucle.
Pista: `exit` dentro del `while` sale de la subshell de la tubería, no del
script; mira `PIPESTATUS` o cambia la tubería por `< <(...)`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — Socket compartido](../lab-04-socket-compartido/README.md) | [Lab 06 — Colaboración rota](../lab-06-colaboracion-rota/README.md) → |

[↑ Semana 12](../../README.md)
