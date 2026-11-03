# Lab 06 — Colaboración rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los cinco fallos de un compañero que comparte su tmux "en solo lectura" y trabaja con un tmux dentro de otro, sin que nada dé error al arrancar.

## Contexto

- `starter/` está roto a propósito: `share.sh` comparte una sesión por `-S` y `fuera.conf` es el tmux de fuera de un anidado por SSH. Todo arranca con 0 y `shellcheck` no protesta: los fallos son de diseño.
- Cada paso da un síntoma, cómo observarlo y una pista. Arregla solo ese fallo, comprueba y sigue.
- Repasa los labs 02 a 04: `send-prefix`, la tabla `off`, `server-access` y los permisos del socket.

## Instrucciones

0. **Dónde y quién.** Necesitas `sshd` y la clave del [lab 01](../lab-01-ssh-y-sesion-persistente/README.md),
   paso 0. Desde la raíz del repositorio, en tu equipo, abre dos
   terminales dentro del laboratorio:
   ```bash
   docker compose exec lab bash               # terminal A (alumno)
   docker compose exec -u invitado lab bash   # terminal B (invitado)
   ```
   Las dos fuera de tmux (`echo "$TMUX"` vacío). En las dos:
   ```bash
   S=/tmp/lab-roto/pair
   ```
   En la terminal A, además:
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-06-colaboracion-rota
   ./starter/share.sh invitado; echo $?
   ```
   ```
   alumno (W)
   invitado (W)
   invitado: tmux -S /tmp/lab-roto/pair attach -r -t pair
   0
   ```
   El servidor compartido arranca con `-f /dev/null`: prefix `C-b`.

1. **Fallo 1 — entra cualquiera.** Terminal A:
   ```bash
   ls -ld /tmp/lab-roto; ls -l "$S"
   ```
   Algo como:
   ```
   drwxrwxrwx 2 alumno alumno 4096 Nov  3 21:56 /tmp/lab-roto
   srwxrwxrwx 1 alumno alumno 0 Nov  3 21:56 /tmp/lab-roto/pair
   ```
   Prueba con un usuario que no está en `pair`, `nobody`. En una tercera
   terminal de tu equipo, desde la raíz del repositorio:
   ```bash
   docker compose exec -u nobody lab tmux -S /tmp/lab-roto/pair ls; echo $?
   ```
   ```
   access not allowed
   0
   ```
   `nobody` llegó hasta el servidor: ya solo lo para `server-access`, y
   cualquier error en esa lista lo deja dentro. **Pista:** lab 04, pasos 2
   a 4. Arregla `starter/share.sh` (directorio y socket) y vuelve a lanzarlo
   en A sobre un servidor nuevo:
   ```bash
   tmux -S "$S" kill-server
   ./starter/share.sh invitado
   ls -ld /tmp/lab-roto; ls -l "$S"
   ```
   Algo como:
   ```
   alumno (W)
   invitado (W)
   invitado: tmux -S /tmp/lab-roto/pair attach -r -t pair
   drwx--x--- 2 alumno pair 4096 Nov  3 21:56 /tmp/lab-roto
   srw-rw---- 1 alumno pair 0 Nov  3 21:56 /tmp/lab-roto/pair
   ```
   Repite la orden de `nobody`:
   ```
   error connecting to /tmp/lab-roto/pair (Permission denied)
   1
   ```

2. **Fallo 2 — "solo lectura".** El script dice al invitado que use
   `attach -r`. En la terminal B, sin conectarte siquiera:
   ```bash
   tmux -S "$S" send-keys -t pair 'echo INYECTADO' Enter; echo $?
   ```
   ```
   0
   ```
   En A:
   ```bash
   tmux -S "$S" capture-pane -p -t pair | grep '^INYECTADO'
   ```
   ```
   INYECTADO
   ```
   El invitado ejecutó una orden en tu shell. Y si se conectara con
   `attach -r`, podría quitárselo desde otra shell suya con
   `switch-client -r`: el `-r` lo pide el cliente, no lo impone el
   servidor. **Pista:** `server-access -l` dice `invitado (W)`. Arregla la
   línea de `server-access` y haz que el mensaje final ya no hable de `-r`.
   En A:
   ```bash
   ./starter/share.sh invitado
   ```
   ```
   alumno (W)
   invitado (R)
   invitado: tmux -S /tmp/lab-roto/pair attach -t pair
   ```
   Repite el `send-keys` en B:
   ```
   client is read-only
   1
   ```
   Cierra el servidor compartido en A: `tmux -S "$S" kill-server` (sin
   salida). La terminal B ya no hace falta.

3. **Arranca el anidado** (terminal A). El tmux de fuera con la config del
   compañero, un panel que entra por SSH en otro tmux (`-f /dev/null`,
   prefix `C-b`) y una segunda ventana. Como en el lab 03, un cliente de
   control mode recibe las teclas:
   ```bash
   C="$PWD/starter/fuera.conf"
   n() { echo "fuera=$(tmux -L fuera list-windows | wc -l) dentro=$(tmux -L dentro list-windows | wc -l)"; }
   tmux -L fuera -f "$C" new -d -s fuera "ssh -t localhost tmux -L dentro -f /dev/null new -A -s dentro"; echo $?
   sleep 2
   ( sleep 900 | tmux -L fuera -C attach -t fuera ) >/dev/null 2>&1 &
   sleep 0.5
   c=$(tmux -L fuera list-clients -F '#{client_name}')
   tmux -L fuera new-window; tmux -L fuera select-window -t fuera:0
   n
   ```
   ```
   0
   fuera=2 dentro=1
   ```
   (bash imprime además `[1] PID`.) `fuera.conf` no cambia el prefix:
   `C-b` en los dos.

4. **Fallo 3 — el toggle no vuelve.** Pulsa `F12` dos veces:
   ```bash
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera show -v key-table
   tmux -L fuera list-keys -T off; echo $?
   ```
   ```
   off
   0
   ```
   Con un cliente de verdad te quedarías sin teclas en esta sesión.
   Rescate: `tmux -L fuera set -u -t fuera prefix \; set -u -t fuera key-table`
   (sin salida). **Pista:** ¿en qué tabla acabó el segundo `bind F12`?
   `tmux -L fuera list-keys | grep F12`. Arréglalo, recarga y repite:
   ```bash
   tmux -L fuera source-file "$C"
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera show -v key-table; echo $?
   ```
   ```
   0
   ```
   Sin valor propio en la sesión: encendido otra vez. (Queda además un
   `F12` viejo en la tabla `prefix`: la recarga no lo borra. Sobra, pero
   no molesta; se va al reiniciar el servidor.)

5. **Fallo 4 — el prefix de dentro nunca llega.** Prefix doble (lab 02,
   paso 3):
   ```bash
   tmux -L fuera send-keys -K -c "$c" C-b C-b
   tmux -L fuera display -p 'ventana=#{window_index}'
   n
   ```
   ```
   ventana=1
   fuera=2 dentro=1
   ```
   `C-b` `C-b` cambió de ventana en el de fuera, en vez de mandar `C-b` al
   de dentro. Vuelve: `tmux -L fuera select-window -t fuera:0`. **Pista:**
   `tmux -L fuera list-keys -T prefix C-b`. Prueba primero a borrar la
   línea `bind C-b last-window` y recargar:
   ```bash
   tmux -L fuera source-file "$C"
   tmux -L fuera list-keys -T prefix C-b
   ```
   ```
   bind-key -T prefix C-b last-window
   ```
   No basta: la recarga no devuelve los bindings por defecto. Pon `C-b` otra vez en `send-prefix` y lleva `last-window` a otra tecla
   (por ejemplo `Tab`). Recarga y comprueba: `send-keys -K` dispara el
   `send-prefix`, y la `c`, que el de fuera no tiene en espera de prefix,
   se la mandas al panel con un `send-keys` normal:
   ```bash
   tmux -L fuera source-file "$C"
   tmux -L fuera list-keys -T prefix C-b
   tmux -L fuera send-keys -K -c "$c" C-b C-b; tmux -L fuera send-keys -t fuera: c
   sleep 0.5; n
   ```
   ```
   bind-key -T prefix C-b send-prefix
   fuera=2 dentro=2
   ```

6. **Fallo 5 — `TERM` dentro del anidado.**
   ```bash
   tmux -L dentro list-clients -F '#{client_termname}'
   tmux -L fuera show -gv default-terminal
   ```
   ```
   xterm-256color
   xterm-256color
   ```
   El tmux de dentro cree que habla con un xterm, y es el de fuera.
   **Pista:** semana 08: dentro de tmux, siempre `tmux-256color`. Arréglalo y recarga: no cambia nada, porque
   `default-terminal` se aplica a los paneles **nuevos** y el SSH ya
   arrancó con `TERM=xterm-256color`. Reinicia los dos:
   ```bash
   tmux -L fuera kill-server; sleep 0.5
   tmux -L dentro kill-server; sleep 0.5
   tmux -L fuera -f "$C" new -d -s fuera "ssh -t localhost tmux -L dentro -f /dev/null new -A -s dentro"
   sleep 2
   tmux -L dentro list-clients -F '#{client_termname}'
   ```
   ```
   tmux-256color
   ```
   `kill-server` cerró también el cliente de control mode del paso 3.

7. **Compara y limpia** (terminal A). Tu arreglo frente a la solución de
   referencia:
   ```bash
   diff starter/share.sh solucion/share.sh
   diff starter/fuera.conf solucion/fuera.conf
   tmux -L fuera kill-server; sleep 0.5
   tmux -L dentro kill-server
   rm -rf /tmp/lab-roto
   ```
   Las diferencias que queden deberían ser solo comentarios. Para repetir
   el lab: `git checkout starter/`.

## Criterios de éxito

- [ ] `nobody` recibe `Permission denied` con rc 1 (paso 1)
- [ ] `./starter/share.sh invitado` imprime `invitado (R)` y el `send-keys` del invitado da `client is read-only` (paso 2)
- [ ] Tras `F12` `F12`, `tmux -L fuera show -v key-table` no imprime nada (paso 4)
- [ ] `tmux -L fuera list-keys -T prefix C-b` muestra `send-prefix` y el prefix doble deja `fuera=2 dentro=2` (paso 5)
- [ ] Tras reiniciar, `tmux -L dentro list-clients -F '#{client_termname}'` imprime `tmux-256color` (paso 6)
- [ ] Explicas por qué `attach -r` no protege nada si el invitado tiene `(W)` (paso 2)

## Reto extra

El compañero quiere dar escritura un rato y volver a solo lectura sin
desconectar al invitado. Añade a `share.sh` un segundo argumento opcional
`-w` y comprueba, con el invitado conectado, que
`list-clients -F '#{client_user} #{client_readonly}'` pasa de `invitado 1`
a `invitado 0` y vuelve. ¿Hace falta que el invitado se reconecte?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — Control mode](../lab-05-control-mode/README.md) | [Proyecto — tmux-kit: toggle de anidado, barra remota y sesión compartida](../../3-proyecto/README.md) → |

[↑ Semana 12](../../README.md)
