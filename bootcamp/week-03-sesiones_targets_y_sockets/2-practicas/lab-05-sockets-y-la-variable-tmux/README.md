# Lab 05 — Sockets y la variable TMUX

⏱ Duración estimada: ~60 min

## Objetivo

Elegir dónde vive el socket de un servidor, leer de `$TMUX` a qué servidor pertenece un panel y recuperar un socket borrado sin perder las sesiones.

## Contexto

- `-L nombre` crea el socket en el directorio por defecto (`/tmp/tmux-UID/`, o `$TMUX_TMPDIR/tmux-UID/`); `-S ruta` lo pone exactamente donde digas.
- Dentro de cada panel, tmux define `$TMUX` (`socket,pid,id de sesión`) y `$TMUX_PANE` (`%N`). Con ellos un script sabe a qué servidor y a qué panel pertenece.
- El socket es solo la puerta. Si se borra, el servidor y sus sesiones siguen vivos, pero nadie puede entrar hasta que se recree.

## Instrucciones

0. Abre dos terminales **fuera de tmux**. En las dos, entra en la carpeta del
   lab y comprueba que ni `TMUX` ni `TMUX_TMPDIR` están definidas:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-05-sockets-y-la-variable-tmux
   echo "TMUX=[$TMUX] TMUX_TMPDIR=[$TMUX_TMPDIR]"
   ```
   ```
   TMUX=[] TMUX_TMPDIR=[]
   ```
   La **terminal A** es la que conectarás; la **terminal B** se queda fuera.
   Los servidores del lab arrancan con `-f /dev/null`: el prefix es `C-b`.

1. **`-L` frente a `-S`.** En la terminal B:
   ```bash
   tmux -L lab -f /dev/null new -d -s a
   tmux -S /tmp/mi-socket -f /dev/null new -d -s b
   tmux -L lab display -p '#{socket_path}'
   tmux -S /tmp/mi-socket display -p '#{socket_path}'
   ls -ld /tmp/tmux-$(id -u)/
   ls -l /tmp/tmux-$(id -u)/lab /tmp/mi-socket
   ```
   ```
   /tmp/tmux-1000/lab
   /tmp/mi-socket
   drwx------ 2 alumno alumno 4096 Nov  2 23:48 /tmp/tmux-1000/
   srw------- 1 alumno alumno 0 Nov  2 23:48 /tmp/mi-socket
   srw-rw---- 1 alumno alumno 0 Nov  2 23:48 /tmp/tmux-1000/lab
   ```
   (Algo como: cambian el uid, el usuario y las fechas.) La `s` inicial marca
   un socket. El directorio `tmux-UID` es `drwx------`: solo tú entras, así que
   protege a todos los sockets de dentro. Con `-S` en `/tmp` no hay directorio
   que te proteja: los permisos del socket son lo único que hay (semana 12).

2. **`TMUX_TMPDIR`.** Cambia el directorio base de todos los `-L`. En la
   terminal B:
   ```bash
   mkdir -p /tmp/sockets-lab
   TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro -f /dev/null new -d -s c
   TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro display -p '#{socket_path}'
   tmux -L otro ls; echo $?
   ```
   ```
   /tmp/sockets-lab/tmux-1000/otro
   error connecting to /tmp/tmux-1000/otro (No such file or directory)
   1
   ```
   Sin la variable, `-L otro` busca en `/tmp/tmux-1000/` y no lo encuentra.

3. **La variable `TMUX`.** En la terminal A, conéctate a `a`:
   ```bash
   tmux -L lab attach -t =a
   ```
   Y en su panel:
   ```bash
   echo "$TMUX"
   echo "$TMUX_PANE"
   tmux -S "${TMUX%%,*}" display -p '#{session_name}'
   ```
   ```
   /tmp/tmux-1000/lab,9,0
   %0
   a
   ```
   (Algo como: el pid del servidor, `9` aquí, será otro.) Tres campos: la
   ruta del socket, el pid del servidor y el **id de la sesión sin el `$`**.
   Compruébalo en la terminal B:
   ```bash
   tmux -L lab list-sessions -F '#{session_name} #{session_id}'
   ```
   ```
   a $0
   ```
   `${TMUX%%,*}` borra desde la primera coma hasta el final: deja la ruta del
   socket. Con ella hablas con **tu** servidor sin saber cómo se arrancó (`-L`,
   `-S` o `TMUX_TMPDIR`). En la terminal A, desconéctate con `C-b` `d`:
   ```
   [detached (from session a)]
   ```

4. **Socket borrado.** En la terminal B, guarda el pid, borra el socket y
   pregunta:
   ```bash
   pid=$(tmux -L lab display -p '#{pid}'); echo "$pid"
   rm /tmp/tmux-$(id -u)/lab
   tmux -L lab ls; echo $?
   ps -p "$pid" -o pid,args
   ```
   ```
   9
   error connecting to /tmp/tmux-1000/lab (No such file or directory)
   1
       PID COMMAND
         9 tmux -L lab -f /dev/null new -d -s a
   ```
   (Algo como: cambia el pid.) Nadie puede entrar, pero el servidor sigue
   vivo. La señal `USR1` le pide que recree su socket:
   ```bash
   kill -USR1 "$pid"; echo $?
   tmux -L lab ls
   ```
   ```
   0
   a: 1 windows (created Mon Nov  2 23:48:41 2026)
   ```
   Pasa en la vida real cuando algo limpia `/tmp` mientras trabajas.

5. **El escenario de `starter/whoami.sh`.** Dentro de tmux, el script dice
   a qué servidor, sesión y panel pertenece la shell que lo ejecuta; fuera, lo
   dice y sale con 1. No usa `-L`: saca el socket de `$TMUX`. En la terminal B:
   ```bash
   ./starter/whoami.sh; echo $?
   ```
   ```
   whoami.sh: sin implementar
   0
   ```
   Abre `starter/whoami.sh` con tu editor y borra la línea
   `echo "whoami.sh: sin implementar"`.

6. **TODO 1: fuera de tmux.** Pista: `if [[ -z "${TMUX:-}" ]]; then`, con
   `echo "no estás dentro de tmux" >&2` y `exit 1` dentro (`${TMUX:-}` evita
   que `set -u` aborte si la variable no existe). Prueba en la terminal B:
   ```bash
   ./starter/whoami.sh; echo $?
   ```
   ```
   no estás dentro de tmux
   1
   ```

7. **TODO 2: el socket.** Guarda en una variable lo que va antes de la
   primera coma, y de momento imprímelo:
   ```bash
   socket="${TMUX%%,*}"
   echo "$socket"    # temporal: lo quitas en el TODO 3
   ```
   Prueba en la terminal A (conéctate con `tmux -L lab attach -t =a`; el panel
   está en la carpeta del lab porque la sesión se creó desde ella):
   ```bash
   ./starter/whoami.sh
   ```
   ```
   /tmp/tmux-1000/lab
   ```

8. **TODO 3: preguntar al servidor.** Quita el `echo "$socket"` y pregunta
   con `tmux -S "$socket" display-message -p -t "$TMUX_PANE" '...'`. El
   `-t "$TMUX_PANE"` hace que conteste por **este** panel y no por la sesión
   usada más recientemente. Las variables de formato que necesitas:
   `#{socket_path}`, `#{pid}`, `#{session_name}` y `#{pane_id}`. Un salto de
   línea dentro de las comillas simples sale tal cual:
   ```bash
   tmux -S "$socket" display-message -p -t "$TMUX_PANE" \
     'servidor: #{socket_path} (pid #{pid})
   sesión: #{session_name}
   panel: #{pane_id}'
   ```
   Prueba en la terminal A, dentro de `a`:
   ```bash
   ./starter/whoami.sh
   ```
   ```
   servidor: /tmp/tmux-1000/lab (pid 9)
   sesión: a
   panel: %0
   ```
   (Algo como: cambian el uid y el pid.) Desconéctate con `C-b` `d`
   (`[detached (from session a)]`) y ejecútalo otra vez, ya fuera:
   ```bash
   ./starter/whoami.sh; echo $?
   ```
   ```
   no estás dentro de tmux
   1
   ```

9. Limpia, en la terminal B:
   ```bash
   tmux -L lab kill-server; tmux -S /tmp/mi-socket kill-server; TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro kill-server
   rm -rf /tmp/mi-socket /tmp/sockets-lab
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Mostraste dónde queda el socket con `-L`, con `-S` (paso 1) y con `TMUX_TMPDIR` (paso 2)
- [ ] Explicas los tres campos de `$TMUX` y usaste el primero con `-S` (paso 3)
- [ ] Recuperaste un socket borrado con `kill -USR1` sin perder la sesión (paso 4)
- [ ] `whoami.sh` da las salidas del paso 8 dentro y fuera de tmux

## Reto extra

Antes de limpiar, conéctate a `tmux -S /tmp/mi-socket attach -t =b` y ejecuta
`whoami.sh` en su panel. ¿Funciona sin cambiar nada? ¿Por qué un script con
`-L lab` fijo no lo haría?
