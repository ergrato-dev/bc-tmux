# Lab 05 — Sockets y la variable TMUX

⏱ Duración estimada: ~60 min

## Objetivo

Elegir dónde vive el socket de un servidor, leer de `$TMUX` a qué servidor pertenece un panel y recuperar un socket borrado sin perder las sesiones.

## Contexto

- `-L nombre` crea el socket en el directorio por defecto (`/tmp/tmux-UID/`, o `$TMUX_TMPDIR/tmux-UID/`); `-S ruta` lo pone exactamente donde digas.
- Dentro de cada panel, tmux define `$TMUX` (`socket,pid,sesión`) y `$TMUX_PANE` (`%N`). Con ellos un script sabe a qué servidor y a qué panel pertenece.
- El socket es solo la puerta. Si se borra, el servidor y sus sesiones siguen vivos, pero nadie puede entrar hasta que se recree.

## Instrucciones

1. **`-L` frente a `-S`.**
   ```bash
   tmux -L lab new -d -s a
   tmux -S /tmp/mi-socket new -d -s b
   tmux -L lab display -p '#{socket_path}'
   tmux -S /tmp/mi-socket display -p '#{socket_path}'
   ls -la /tmp/tmux-$(id -u)/ /tmp/mi-socket
   ```
   Fíjate en los permisos: el directorio `tmux-UID` es `drwx------`. Con `-S`
   en `/tmp` no hay directorio que te proteja: los permisos del socket son lo
   único que hay (semana 12).

2. **`TMUX_TMPDIR`.** Cambia el directorio base de todos los `-L`:
   ```bash
   mkdir -p /tmp/sockets-lab
   TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro new -d -s c
   TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro display -p '#{socket_path}'
   tmux -L otro ls      # sin la variable no lo encuentra
   ```

3. **La variable `TMUX`.** Conéctate a `a` y en su panel:
   ```bash
   echo "$TMUX"        # /tmp/tmux-1000/lab,1234,0
   echo "$TMUX_PANE"   # %0
   ```
   Tres campos: la ruta del socket, el pid del servidor y el índice de la
   sesión. Con el primero hablas con **tu** servidor sin saber su nombre:
   ```bash
   tmux -S "${TMUX%%,*}" display -p '#{session_name}'
   ```
   Desconéctate (`prefix` `d`).

4. **Socket borrado.** Guarda el pid, borra el socket y pregunta:
   ```bash
   pid=$(tmux -L lab display -p '#{pid}')
   rm /tmp/tmux-$(id -u)/lab
   tmux -L lab ls             # error connecting to ... (No such file or directory)
   ps -p "$pid" -o pid,args   # el servidor sigue vivo
   kill -USR1 "$pid"          # pide al servidor que recree su socket
   tmux -L lab ls             # la sesión a sigue ahí
   ```
   Pasa en la vida real cuando algo limpia `/tmp` mientras trabajas.

5. Completa `starter/quien-soy.sh`: dentro de tmux dice a qué servidor,
   sesión y panel pertenece la shell que lo ejecuta; fuera, lo dice y sale
   con 1. No usa `-L`: saca el socket de `$TMUX`.
   ```bash
   ./starter/quien-soy.sh; echo $?
   tmux -L lab attach -t =a      # y dentro del panel:
   ./starter/quien-soy.sh
   ```
   ```
   no estás dentro de tmux
   1
   servidor: /tmp/tmux-1000/lab (pid 1234)
   sesión: a
   panel: %0
   ```

6. Limpia: `tmux -L lab kill-server; tmux -S /tmp/mi-socket kill-server; TMUX_TMPDIR=/tmp/sockets-lab tmux -L otro kill-server`.

## Criterios de éxito

- [ ] Muestras dónde queda el socket con `-L`, con `-S` y con `TMUX_TMPDIR`
- [ ] Explicas los tres campos de `$TMUX` y usas el primero con `-S`
- [ ] Recuperaste un socket borrado con `kill -USR1` sin perder la sesión
- [ ] `quien-soy.sh` da las salidas del paso 5 dentro y fuera de tmux

## Reto extra

Ejecuta `quien-soy.sh` dentro de una sesión del servidor `/tmp/mi-socket`.
¿Funciona sin cambiar nada? ¿Por qué un script con `-L lab` fijo no lo haría?
