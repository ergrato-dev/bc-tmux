# Lab 05 — Servidores y sockets

⏱ Duración estimada: ~60 min

## Objetivo

Levantar varios servidores de tmux, encontrar sus sockets en disco, distinguir los comandos que arrancan un servidor de los que solo preguntan, y entender por qué tmux se niega a anidarse.

## Contexto

- Cada servidor de tmux escucha en un **socket**: un archivo especial en `/tmp/tmux-<UID>/`. Los clientes y los comandos hablan con el servidor a través de él.
- `-L nombre` elige un socket con ese nombre dentro de ese directorio; `-S ruta` elige una ruta completa. Sin ninguno de los dos se usa `default`.
- Dos servidores no comparten nada: sesiones, opciones y atajos son de cada uno.

## Instrucciones

1. Levanta dos servidores, cada uno con una sesión en segundo plano:
   ```bash
   tmux -L alfa new -d -s uno
   tmux -L beta new -d -s dos
   tmux -L alfa ls      # solo "uno"
   tmux -L beta ls      # solo "dos"
   ```

2. Encuentra los sockets:
   ```bash
   ls -la "/tmp/tmux-$(id -u)/"
   tmux -L alfa display-message -p -t uno '#{socket_path} pid=#{pid}'
   ```
   El directorio tiene permisos `drwx------`: solo tú puedes entrar. Quien
   puede escribir en un socket de tmux puede ejecutar comandos como tú, por
   eso esos permisos importan. `#{socket_path}` es justo lo que imprime la
   primera línea de `kit-tree`.

3. Mata **solo** uno de los dos:
   ```bash
   tmux -L alfa kill-server
   tmux -L beta ls      # "dos" sigue viva
   ```
   Escribe siempre `kill-server` con `-L`. Sin él, matas el servidor
   `default`: el de tus sesiones de verdad.

4. **Qué comandos arrancan un servidor.** Con `alfa` ya muerto:
   ```bash
   tmux -L alfa ls; echo "rc=$?"
   ls "/tmp/tmux-$(id -u)/"
   ```
   ```
   no server running on /tmp/tmux-1000/alfa
   rc=1
   ```
   `ls` (`list-sessions`) solo pregunta: si no hay servidor, falla y **no
   arranca ninguno**. `new-session` sí lo arranca. Por eso `kit-tree` usa
   `list-sessions` para comprobar si hay servidor: no debe crear uno solo por
   mirar.

5. **El error de anidado (a propósito).** Entra a la sesión de `beta` e
   intenta abrir otra sesión del mismo servidor desde dentro:
   ```bash
   tmux -L beta attach -t dos
   # ya dentro de tmux:
   tmux -L beta new -s tres
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   ```
   tmux ve que `$TMUX` apunta a este mismo servidor y se niega: estarías
   metiendo un cliente de tmux dentro de un panel del mismo tmux. Lo que sí
   funciona desde dentro es crear sin conectarte (`tmux -L beta new -d -s
   tres`) o cambiar de sesión (`tmux -L beta switch-client -t tres`). El tmux
   anidado de verdad (uno local y otro por SSH) es tema de la semana 12. Sal
   con `prefix` `d`.

6. **Un socket huérfano.** Mata el servidor de `beta` sin dejarle limpiar:
   ```bash
   kill -9 "$(tmux -L beta display-message -p -t dos '#{pid}')"
   ls "/tmp/tmux-$(id -u)/"     # el archivo beta sigue ahí
   tmux -L beta ls; echo "rc=$?"
   ```
   El archivo existe pero nadie escucha: tmux responde `no server running` (o
   `error connecting`). Un socket así se borra a mano sin peligro.

7. Completa `starter/servidores.sh`: por cada socket del directorio, imprime
   su nombre y cuántas sesiones tiene, o `sin servidor` si nadie responde.
   Pruébalo con un servidor vivo y el socket huérfano del paso 6:
   ```bash
   tmux -L gamma new -d -s a
   tmux -L gamma new -d -s b
   ./starter/servidores.sh
   ```
   ```
   beta: sin servidor
   gamma: 2 sesiones
   ```
   (Si tienes tmux abierto en tu equipo, también verás `default`.)

8. Limpia: `tmux -L gamma kill-server; rm -f "/tmp/tmux-$(id -u)/beta"`.

## Criterios de éxito

- [ ] Dos servidores con sesiones distintas conviven y `kill-server -L` mata solo uno
- [ ] Puedes nombrar un comando que arranca un servidor y uno que no
- [ ] Reprodujiste el mensaje `sessions should be nested with care` y sabes por qué aparece
- [ ] `./starter/servidores.sh` distingue un socket vivo de uno huérfano

## Reto extra

`TMUX_TMPDIR` cambia el directorio de los sockets. Ejecuta
`TMUX_TMPDIR=/tmp/otro tmux -L alfa new -d -s x` y busca dónde quedó el
socket. ¿Lo encuentra tu `servidores.sh`? Haz que respete `TMUX_TMPDIR`.
