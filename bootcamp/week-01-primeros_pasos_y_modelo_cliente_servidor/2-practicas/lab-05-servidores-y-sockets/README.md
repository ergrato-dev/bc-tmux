# Lab 05 — Servidores y sockets

⏱ Duración estimada: ~60 min

## Objetivo

Levantar varios servidores de tmux, encontrar sus sockets en disco, distinguir los comandos que arrancan un servidor de los que solo preguntan, y entender por qué tmux se niega a anidarse.

## Contexto

- Cada servidor de tmux escucha en un **socket**: un archivo especial en `/tmp/tmux-<UID>/`. Los clientes y los comandos hablan con el servidor a través de él.
- `-L nombre` elige un socket con ese nombre dentro de ese directorio; `-S ruta` elige una ruta completa. Sin ninguno de los dos se usa `default`.
- Dos servidores no comparten nada: sesiones, opciones y atajos son de cada uno.

Este lab usa los servidores `alfa` y `beta`, arrancados con `-f /dev/null`
(prefix `C-b`). Las salidas muestran `1000` como UID: el tuyo es `id -u`.

## Instrucciones

0. **Prepara la terminal.** Fuera de tmux y desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-05-servidores-y-sockets
   echo "$TMUX"
   for s in alfa beta lab; do tmux -L "$s" kill-server 2>/dev/null; done
   rm -f "/tmp/tmux-$(id -u)/alfa" "/tmp/tmux-$(id -u)/beta" "/tmp/tmux-$(id -u)/lab"
   ```
   `echo` imprime una línea vacía; el resto, nada. Así empiezas sin
   servidores ni sockets de intentos anteriores (los labs 01-04 dejaron el
   socket `lab`; en el paso 4 verás por qué).

1. Levanta dos servidores, cada uno con una sesión en segundo plano:
   ```bash
   tmux -L alfa -f /dev/null new -d -s uno
   tmux -L beta -f /dev/null new -d -s dos
   tmux -L alfa ls
   tmux -L beta ls
   ```
   Algo como (cambia la fecha):
   ```
   uno: 1 windows (created Mon Nov  2 23:47:54 2026)
   dos: 1 windows (created Mon Nov  2 23:47:54 2026)
   ```
   Cada servidor solo conoce su sesión.

2. Encuentra los sockets:
   ```bash
   ls -la "/tmp/tmux-$(id -u)/"
   tmux -L alfa display-message -p -t uno '#{socket_path} pid=#{pid}'
   ```
   Algo como (cambian fechas y pid; si usas tmux a diario verás también
   `default`):
   ```
   total 8
   drwx------ 2 alumno alumno 4096 Nov  2 23:47 .
   drwxrwxrwt 1 root   root   4096 Nov  2 23:47 ..
   srw-rw---- 1 alumno alumno    0 Nov  2 23:47 alfa
   srw-rw---- 1 alumno alumno    0 Nov  2 23:47 beta
   /tmp/tmux-1000/alfa pid=11
   ```
   La `s` inicial marca un socket. El directorio tiene permisos `drwx------`:
   solo tú puedes entrar. Quien puede escribir en un socket de tmux puede
   ejecutar comandos como tú, por eso esos permisos importan.
   `#{socket_path}` es justo lo que imprime la primera línea de `kit-tree`.

3. Mata **solo** uno de los dos:
   ```bash
   tmux -L alfa kill-server
   tmux -L beta ls
   ```
   ```
   dos: 1 windows (created Mon Nov  2 23:47:54 2026)
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
   alfa
   beta
   ```
   `ls` (`list-sessions`) solo pregunta: si no hay servidor, falla y **no
   arranca ninguno**. `new-session` sí lo arranca. Por eso `kit-tree` usa
   `list-sessions` para comprobar si hay servidor: no debe crear uno solo por
   mirar.

   Fíjate en que el archivo `alfa` **sigue ahí**: `kill-server` no lo borra.
   Es un socket sin nadie escuchando, y tmux lo reutiliza si vuelves a
   arrancar `alfa`. El mensaje cambia según exista o no el archivo:
   `no server running on ...` (existe, nadie escucha) o
   `error connecting to ... (No such file or directory)` (no existe).

5. **El error de anidado (a propósito).** Conéctate a la sesión de `beta`:
   ```bash
   tmux -L beta attach -t dos
   ```
   Ya dentro de tmux (status line `[dos]`), intenta abrir otra sesión del
   mismo servidor:
   ```bash
   tmux -L beta new -s tres; echo "rc=$?"
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   rc=1
   ```
   tmux comprueba si la terminal desde la que lo llamas es uno de **sus
   propios paneles** (lo sabe por `$TMUX` y por el nombre de la terminal). Si
   lo es, conectarte sería meter un cliente de tmux dentro de un panel del
   mismo tmux, que se dibuja a sí mismo: se niega. Lo que sí funciona desde
   dentro es crear sin conectarte y cambiar de sesión:
   ```bash
   tmux -L beta new -d -s tres
   tmux -L beta switch-client -t tres
   ```
   (sin salida). La status line pasa a `[tres]`: tu cliente ahora mira la
   sesión `tres`. El orden importa: `switch-client` necesita que `tres` ya
   exista. El tmux anidado a propósito (uno local y otro por SSH) es tema de
   la semana 12. Sal con `C-b` `d`:
   `[detached (from session tres)]`.

6. **TODO de `starter/servers.sh`: qué servidores están vivos.** Ahora
   mismo hay un socket sin servidor (`alfa`) y otro vivo con dos sesiones
   (`beta`). Ejecuta el starter sin tocarlo:
   ```bash
   ./starter/servers.sh
   ```
   ```
   alfa: TODO
   beta: TODO
   ```
   Abre el archivo. Dentro del `for`, **borra** la línea
   `echo "$name: TODO"` y escribe en su lugar:
   ```bash
   if sessions=$(tmux -S "$socket" list-sessions 2>/dev/null); then
     echo "$name: $(wc -l <<<"$sessions") sesiones"
   else
     echo "$name: sin servidor"
   fi
   ```
   - `-S "$socket"` habla con ese archivo exacto.
   - El `if` mira el código de salida de `list-sessions`: con `set -e`, un
     fallo fuera de un `if` cortaría el script en el primer socket muerto.
   - `2>/dev/null` calla el `no server running on ...` que tmux escribe por
     stderr; sin él, se mezcla con tu salida.
   - `wc -l <<<"$sessions"` cuenta las líneas: una por sesión.

   Pruébalo:
   ```bash
   ./starter/servers.sh
   ```
   ```
   alfa: sin servidor
   beta: 2 sesiones
   ```
   (Si usas tmux a diario, verás también `default`.)

7. Limpia:
   ```bash
   tmux -L beta kill-server
   rm -f "/tmp/tmux-$(id -u)/alfa" "/tmp/tmux-$(id -u)/beta"
   ```
   (sin salida)

## Criterios de éxito

- [ ] Dos servidores con sesiones distintas conviven y `kill-server` con `-L` mata solo uno (pasos 1 y 3)
- [ ] Puedes nombrar un comando que arranca un servidor y uno que no (paso 4)
- [ ] Reprodujiste el mensaje `sessions should be nested with care` y saliste del paso con `switch-client` (paso 5)
- [ ] `./starter/servers.sh` imprime `alfa: sin servidor` y `beta: 2 sesiones` (paso 6)

## Reto extra

`TMUX_TMPDIR` cambia el directorio de los sockets. Ejecuta:
```bash
mkdir -p /tmp/otro
TMUX_TMPDIR=/tmp/otro tmux -L alfa -f /dev/null new -d -s x
TMUX_TMPDIR=/tmp/otro tmux -L alfa display-message -p '#{socket_path}'
```
Imprime `/tmp/otro/tmux-1000/alfa` (sin el `mkdir`, tmux vuelve en silencio a
`/tmp`). ¿Lo encuentra tu `servers.sh`? Haz que respete `TMUX_TMPDIR` y
limpia con `TMUX_TMPDIR=/tmp/otro tmux -L alfa kill-server`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — Sesión, ventana y panel](../lab-04-sesion-ventana-panel/README.md) | [Lab 06 — Sobrevivir a una desconexión](../lab-06-sobrevivir-a-una-desconexion/README.md) → |

[↑ Semana 01](../../README.md)
