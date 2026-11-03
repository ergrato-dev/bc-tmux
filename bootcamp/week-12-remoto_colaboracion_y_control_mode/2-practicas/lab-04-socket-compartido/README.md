# Lab 04 — Socket compartido

⏱ Duración estimada: ~60 min

## Objetivo

Compartir una sesión con otro usuario de la misma máquina mediante un socket `-S` de grupo y `server-access`, y comprobar qué puede hacer el invitado en solo lectura y en escritura.

## Contexto

- Para conectarse, el invitado necesita dos cosas: llegar al socket (permisos de archivo: directorio y socket) y que el servidor lo acepte (`server-access`, tmux 3.3+). Lo primero lo decide el sistema; lo segundo, tmux.
- `-L nombre` vive en `/tmp/tmux-UID/`, un directorio `0700`: nadie más entra. Para compartir se usa `-S ruta` en un directorio propio.
- `server-access -a usuario` da **escritura**; `-a -r`, solo lectura. El dueño del servidor siempre tiene escritura.

## Instrucciones

0. **Dónde y quién.** Dos terminales dentro del laboratorio, cada una con
   un usuario ([Antes de cada lab](../README.md#antes-de-cada-lab)). Desde
   la raíz del repositorio, en tu equipo:
   ```bash
   docker compose up -d lab
   docker compose exec lab bash               # terminal A (alumno)
   docker compose exec -u invitado lab bash   # terminal B (invitado), en otra ventana
   ```
   Las dos fuera de tmux (`echo "$TMUX"` vacío). En la terminal A:
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-04-socket-compartido
   S=/tmp/lab-pair/pair
   id
   ```
   ```
   uid=1000(alumno) gid=1000(alumno) groups=1000(alumno),4(adm),20(dialout),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),1001(pair)
   ```
   En la terminal B:
   ```bash
   S=/tmp/lab-pair/pair
   id
   ```
   ```
   uid=1001(invitado) gid=1002(invitado) groups=1002(invitado),1001(pair)
   ```
   Los dos están en el grupo `pair`. El prefix es `C-b`: `starter/tmux.conf`
   no lo cambia.

1. **Por qué `-L` no sirve.** Terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s lab
   ls -ld /tmp/tmux-1000
   ```
   Algo como (cambia la fecha):
   ```
   drwx------ 2 alumno alumno 4096 Nov  3 21:52 /tmp/tmux-1000
   ```
   Terminal B:
   ```bash
   tmux -S /tmp/tmux-1000/lab ls; echo $?
   ```
   ```
   error connecting to /tmp/tmux-1000/lab (Permission denied)
   1
   ```
   Da igual cómo esté el socket: el invitado no atraviesa el directorio.
   Terminal A: `tmux -L lab kill-server` (sin salida).

2. **TODO 1 — el directorio.** En `starter/share.sh`, `chgrp pair "$dir"` y
   `chmod 0710 "$dir"`. Terminal A:
   ```bash
   ./starter/share.sh invitado; echo $?
   ls -ld /tmp/lab-pair
   ```
   ```
   share.sh: compartiendo pair con invitado
   0
   drwx--x--- 2 alumno pair 4096 Nov  3 21:52 /tmp/lab-pair
   ```
   Terminal B:
   ```bash
   ls /tmp/lab-pair; echo $?
   ```
   ```
   ls: cannot open directory '/tmp/lab-pair': Permission denied
   2
   ```
   La `x` del grupo deja pasar a quien conoce la ruta exacta; sin `r`, el
   invitado no ve qué hay dentro.

3. **TODO 2 — el servidor.** Copia el `if ! tmx has-session ...` del TODO 2
   quitando los `#`. Terminal A:
   ```bash
   ./starter/share.sh invitado
   ls -l "$S"
   ```
   Algo como:
   ```
   share.sh: compartiendo pair con invitado
   srw------- 1 alumno alumno 0 Nov  3 21:52 /tmp/lab-pair/pair
   ```
   Terminal B:
   ```bash
   tmux -S "$S" ls; echo $?
   ```
   ```
   error connecting to /tmp/lab-pair/pair (Permission denied)
   1
   ```
   tmux crea el socket solo para su dueño.

4. **TODO 3 — el socket.** `chgrp pair "$sock"` y `chmod g+rw,o= "$sock"`.
   Terminal A:
   ```bash
   ./starter/share.sh invitado
   ls -l "$S"
   ```
   ```
   share.sh: compartiendo pair con invitado
   srw-rw---- 1 alumno pair 0 Nov  3 21:52 /tmp/lab-pair/pair
   ```
   Terminal B:
   ```bash
   tmux -S "$S" ls; echo $?
   ```
   ```
   access not allowed
   0
   ```
   Ya llega al servidor y es tmux quien lo rechaza. Ojo: sale con **0**.
   Un script que solo mire `$?` creería que funcionó.

5. **TODO 4 — server-access.** Las dos líneas del TODO 4. Lánzalo dos
   veces para ver que repetirlo no cambia nada. Terminal A:
   ```bash
   ./starter/share.sh invitado; echo $?
   ./starter/share.sh invitado; echo $?
   ```
   ```
   share.sh: compartiendo pair con invitado
   alumno (W)
   invitado (R)
   0
   share.sh: compartiendo pair con invitado
   alumno (W)
   invitado (R)
   0
   ```
   La segunda vez `-a` falla (`user invitado is already added`, que el
   `2>/dev/null` oculta) y `-r` deja el modo como estaba.

6. **El invitado mira (terminal B).**
   ```bash
   tmux -S "$S" attach -t pair
   ```
   Ves la shell de alumno. Escribe algo: no aparece nada, tus teclas no
   llegan. En la terminal A:
   ```bash
   tmux -S "$S" list-clients -F '#{client_user} #{client_readonly} #{client_flags}'
   ls -l "$S"
   ```
   Algo como:
   ```
   invitado 1 attached,focused,read-only,UTF-8
   srwxrwx--- 1 alumno pair 0 Nov  3 21:52 /tmp/lab-pair/pair
   ```
   Con un cliente conectado tmux añadió la `x`: por eso el chmod del TODO 3
   es relativo. Sal de B con `C-b` `d`, que sí funciona en solo lectura:
   ```
   [detached (from session pair)]
   ```

7. **TODO 5 — que el invitado lo sepa.** En `starter/tmux.conf`, la
   `status-right` del TODO 5. Terminal A:
   ```bash
   tmux -S "$S" source-file "$PWD/starter/tmux.conf"
   tmux -S "$S" display -p '#{T:status-right}'
   ```
   ```
   0 clientes
   ```
   Desde tu shell no hay cliente que mire. Vuelve a conectar B
   (`tmux -S "$S" attach -t pair`): su barra empieza por ` SOLO LECTURA `
   en rojo. En A, pide el format en nombre de ese cliente:
   ```bash
   c=$(tmux -S "$S" list-clients -F '#{client_name}')
   tmux -S "$S" display -p -c "$c" '#{T:status-right}'
   ```
   ```
   #[bg=#f85149] SOLO LECTURA #[default] 1 clientes
   ```
   Sal de B con `C-b` `d`.

8. **Qué no puede.** Terminal B, sin conectarse:
   ```bash
   tmux -S "$S" send-keys -t pair 'echo hola-desde-invitado' Enter; echo $?
   tmux -S "$S" ls; echo $?
   ```
   ```
   client is read-only
   1
   client is read-only
   1
   ```
   (R) vale para todo lo que el invitado mande al servidor, conectado o no.
   Dale escritura desde A:
   ```bash
   tmux -S "$S" server-access -w invitado
   tmux -S "$S" server-access -l
   ```
   ```
   alumno (W)
   invitado (W)
   ```
   Repite en B el `send-keys`: sale `0`. En A:
   ```bash
   tmux -S "$S" capture-pane -p -t pair | grep '^hola'
   ```
   ```
   hola-desde-invitado
   ```
   El invitado ejecutó una orden en **tu** shell, como tú. Escritura es eso.

9. **Echarlo.** Conecta B otra vez (`tmux -S "$S" attach -t pair`) y en A:
   ```bash
   tmux -S "$S" server-access -d invitado; echo $?
   tmux -S "$S" list-clients | wc -l
   tmux -S "$S" server-access -l
   ```
   ```
   0
   0
   alumno (W)
   ```
   B vuelve a su shell con `[access not allowed]`: `-d` desconecta en el
   acto.

10. **Limpia** (terminal A). La lista de `server-access` vive en la memoria
    del servidor y se pierde con él:
    ```bash
    tmux -S "$S" kill-server
    rm -rf /tmp/lab-pair
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Con el socket `600`, el invitado recibe `Permission denied` (rc 1); con `660` y sin `server-access`, `access not allowed` (rc 0) (pasos 3 y 4)
- [ ] `./starter/share.sh invitado` dos veces seguidas imprime `invitado (R)` las dos (paso 5)
- [ ] `list-clients` muestra `invitado 1 attached,focused,read-only,UTF-8` (paso 6)
- [ ] `display -p -c "$c" '#{T:status-right}'` empieza por `#[bg=#f85149] SOLO LECTURA` (paso 7)
- [ ] En (R), el `send-keys` del invitado da `client is read-only`; en (W), su texto aparece en tu panel (paso 8)
- [ ] Tras `server-access -d invitado`, `list-clients | wc -l` imprime `0` (paso 9)

## Reto extra

En `/tmp` cualquiera puede crear `/tmp/lab-pair` antes que tú. Pruébalo:
como invitado, `mkdir -m 777 /tmp/lab-pair`; como alumno, lanza
`share.sh`. ¿Qué línea lo frena y con qué mensaje? Añade al principio una
comprobación explícita (`[[ -O "$dir" && ! -L "$dir" ]]`) que diga qué
pasa y cómo arreglarlo, como hace `kit-pair` en el proyecto.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Toggle de anidado](../lab-03-toggle-de-anidado/README.md) | [Lab 05 — Control mode](../lab-05-control-mode/README.md) → |

[↑ Semana 12](../../README.md)
