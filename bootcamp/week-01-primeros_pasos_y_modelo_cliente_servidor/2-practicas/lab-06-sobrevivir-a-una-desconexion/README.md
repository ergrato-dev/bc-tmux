# Lab 06 — Sobrevivir a una desconexión

⏱ Duración estimada: ~60 min

## Objetivo

Demostrar con un log que un trabajo largo muere al cerrar la terminal fuera de tmux y sobrevive dentro de tmux, y lanzar ese trabajo en segundo plano con un script.

## Contexto

- Cuando cierras una terminal o se cae una conexión SSH, la shell recibe **SIGHUP** y lo reenvía a sus trabajos: todos mueren.
- Dentro de tmux, el programa es hijo del **servidor**, no de tu terminal. Lo que muere al desconectarte es el **cliente**; el servidor y sus paneles siguen.
- `detach-client -P` desconecta un cliente **y manda SIGHUP a la shell que lo lanzó**: es la forma de simular, sin cerrar ventanas, una terminal que se cierra o un SSH que se cae.

Necesitas dos terminales: **A** (la que vas a "perder") y **B** (fuera de
tmux, desde donde miras). En el laboratorio Docker, desde la raíz del
repositorio en tu equipo: `docker compose up -d lab` una vez, y
`docker compose exec lab bash` en cada terminal; entras en `/bc-tmux`, que es
la raíz del repositorio montada dentro del contenedor. El servidor `lab`
arranca con `-f /dev/null`: el prefix es `C-b`.

## Instrucciones

0. **Prepara las dos terminales.** En A y en B, fuera de tmux y desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-01-primeros_pasos_y_modelo_cliente_servidor/2-practicas/lab-06-sobrevivir-a-una-desconexion
   echo "$TMUX"
   ```
   `echo` imprime una línea vacía. Solo en B, borra restos anteriores:
   ```bash
   tmux -L lab kill-server 2>/dev/null
   rm -f /tmp/sin-tmux.log /tmp/con-tmux.log /tmp/lanzada.log /tmp/corta.log
   ```
   (sin salida)

1. **Sin tmux.** **Terminal A:** anota el pid de la shell y lanza la tarea:
   ```bash
   echo $$
   ./starter/long-task.sh /tmp/sin-tmux.log
   ```
   Algo como (cambian el pid y la hora):
   ```
   4242
   23:48:20  paso 1
   23:48:21  paso 2
   ```
   **Terminal B:** simula que A se cierra, con el pid que imprimió A:
   ```bash
   kill -HUP 4242
   ```
   (sin salida en B). La terminal A imprime `Hangup` y su shell termina: la
   ventana se cierra o tu emulador avisa de que el proceso acabó (en el
   laboratorio Docker, A vuelve a la shell de tu equipo). **Terminal B:**
   ```bash
   sleep 3; tail -n 2 /tmp/sin-tmux.log
   sleep 3; tail -n 2 /tmp/sin-tmux.log
   ```
   Las dos veces, las mismas líneas, algo como:
   ```
   23:48:21  paso 2
   23:48:22  paso 3
   ```
   No avanza: la tarea murió con la shell.

2. **Con tmux.** Abre una terminal A nueva (en Docker,
   `docker compose exec lab bash`), haz el `cd` del paso 0 y:
   ```bash
   tmux -L lab -f /dev/null new -s larga
   ```
   Ya dentro de tmux:
   ```bash
   ./starter/long-task.sh /tmp/con-tmux.log
   ```
   **Terminal B:** desconecta el cliente de A **y mata la shell que lo lanzó**:
   ```bash
   tmux -L lab detach-client -P -s larga
   ```
   (sin salida en B). La terminal A muestra
   `[detached and SIGHUP (from session larga)]`, luego `Hangup`, y se cierra
   como en el paso 1. **Terminal B:**
   ```bash
   sleep 3; tail -n 2 /tmp/con-tmux.log
   sleep 3; tail -n 2 /tmp/con-tmux.log
   ```
   Algo como:
   ```
   23:48:32  paso 4
   23:48:33  paso 5
   23:48:35  paso 7
   23:48:36  paso 8
   ```
   Sigue avanzando: la terminal se perdió, pero la tarea no.

3. **Recupera la sesión.** Abre otra terminal A nueva, haz el `cd` del paso 0 y:
   ```bash
   tmux -L lab attach -t larga
   ```
   La tarea sigue ahí, en primer plano, imprimiendo pasos. No la pares.

4. **Detach no es kill.** **Terminal B:**
   ```bash
   tmux -L lab detach-client -s larga
   ```
   (sin salida en B). Esta vez sin `-P`: la terminal A recibe
   `[detached (from session larga)]` y **sigue abierta**. **Terminal B:**
   ```bash
   tmux -L lab ls
   tail -n 1 /tmp/con-tmux.log; sleep 2; tail -n 1 /tmp/con-tmux.log
   ```
   Algo como:
   ```
   larga: 1 windows (created Mon Nov  2 23:48:28 2026)
   23:48:41  paso 10
   23:48:43  paso 12
   ```
   La sesión vive y el log avanza. Ahora **mata** la sesión:
   ```bash
   tmux -L lab kill-session -t larga
   tmux -L lab ls; echo $?
   tail -n 1 /tmp/con-tmux.log; sleep 2; tail -n 1 /tmp/con-tmux.log
   ```
   ```
   no server running on /tmp/tmux-1000/lab
   1
   23:48:43  paso 12
   23:48:43  paso 12
   ```
   `kill-session` cierra sus paneles y, con ellos, la tarea: el log se para.
   Era la última sesión, así que el servidor también terminó.

5. **TODO 1 de `starter/launch.sh`: lanzar la tarea sin shell ni cliente.**
   Abre el archivo. Debajo del comentario `TODO 1` escribe:
   ```bash
   tmx new-session -d -s larga "$task" "$log" "$seconds"
   ```
   Lo que va después de las opciones es el programa de la ventana. Con varios
   argumentos separados, tmux lo ejecuta tal cual, sin pasar por una shell:
   una ruta con espacios no se rompe. **Borra** también las dos últimas
   líneas del archivo (`echo "launch.sh: sin implementar ..."` y `exit 1`).
   **Terminal B:**
   ```bash
   ./starter/launch.sh /tmp/lanzada.log
   tmux -L lab ls
   sleep 3; tail -n 1 /tmp/lanzada.log
   ```
   Algo como:
   ```
   larga: 1 windows (created Mon Nov  2 23:48:46 2026)
   23:48:48  paso 3
   ```
   El script no imprime nada (falta el TODO 2) y `ls` no dice `(attached)`:
   nadie mira la sesión, pero la tarea corre. Borra el servidor antes de
   seguir: `tmux -L lab kill-server` (sin salida).

6. **TODO 2: decir cómo volver.** Debajo de `TODO 2` escribe:
   ```bash
   echo "tarea lanzada en la sesión \"larga\"; vuelve con: tmux -L lab attach -t larga"
   ```
   **Terminal B:**
   ```bash
   ./starter/launch.sh /tmp/lanzada.log
   ```
   ```
   tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
   ```
   Si quieres, conéctate desde A con ese comando y sal con `C-b` `d`.
   Después borra el servidor, desde B:
   ```bash
   tmux -L lab kill-server
   ```
   (sin salida)

7. **Cuando el programa termina.** `long-task.sh` acepta un segundo
   argumento con los segundos que dura. **Terminal B:**
   ```bash
   ./starter/launch.sh /tmp/corta.log 3
   sleep 5; tmux -L lab ls; echo $?
   ```
   ```
   tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
   no server running on /tmp/tmux-1000/lab
   1
   ```
   Al terminar el programa se cierra el panel; sin paneles se cierra la
   ventana; sin ventanas, la sesión; sin sesiones, el servidor. Es la misma
   cadena que viste con `exit` en el lab 01.

8. Limpia, desde B:
   ```bash
   tmux -L lab kill-server 2>/dev/null
   rm -f /tmp/sin-tmux.log /tmp/con-tmux.log /tmp/lanzada.log /tmp/corta.log
   ```
   (sin salida). En Docker, al terminar: `docker compose down` desde la raíz
   del repositorio en tu equipo.

## Criterios de éxito

- [ ] El log de `sin-tmux` se detiene tras el SIGHUP (paso 1) y el de `con-tmux` sigue avanzando (paso 2)
- [ ] Recuperaste la sesión `larga` con `attach` después de que su terminal se cerrara (paso 3)
- [ ] `detach-client` deja el log avanzando y `kill-session` lo para (paso 4)
- [ ] `./starter/launch.sh` deja una sesión `larga` sin clientes y el log avanza (pasos 5 y 6)
- [ ] Puedes explicar quién es el proceso padre de la tarea dentro y fuera de tmux

## Reto extra

Repite el paso 2 sin desconectar y, desde B, mira el árbol de procesos:
```bash
ps -o pid,ppid,comm -p "$(pgrep -f long-task.sh | head -n1)"
tmux -L lab display-message -p '#{pid}'
```
El `PPID` de la tarea es la shell del panel; sigue con `ps -o pid,ppid,comm -p <ese PPID>`
hasta llegar al pid del servidor. ¿Y en el paso 1? ¿Y con `launch.sh`?
