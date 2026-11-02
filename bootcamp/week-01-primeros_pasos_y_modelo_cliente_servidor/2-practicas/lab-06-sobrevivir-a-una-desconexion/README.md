# Lab 06 — Sobrevivir a una desconexión

⏱ Duración estimada: ~60 min

## Objetivo

Demostrar con un log que un trabajo largo muere al cerrar la terminal fuera de tmux y sobrevive dentro de tmux, y lanzar ese trabajo en segundo plano con un script.

## Contexto

- Cuando cierras una terminal o se cae una conexión SSH, la shell recibe **SIGHUP** y lo reenvía a sus trabajos: todos mueren.
- Dentro de tmux, el programa es hijo del **servidor**, no de tu terminal. Lo que muere al desconectarte es el **cliente**; el servidor y sus paneles siguen.
- `detach-client -P` desconecta un cliente **y manda SIGHUP a la shell que lo lanzó**: es la forma de simular, sin cerrar ventanas, una terminal que se cierra o un SSH que se cae.

Necesitas dos terminales (A y B). En el laboratorio: `docker compose up -d lab`
y luego `docker compose exec lab bash` en cada una.

## Instrucciones

1. **Sin tmux.** En la terminal A anota el pid de la shell y lanza la tarea:
   ```bash
   echo $$                                   # p. ej. 4242
   ./starter/tarea-larga.sh /tmp/sin-tmux.log
   ```
   En la terminal B, simula que A se cierra y mira el log:
   ```bash
   kill -HUP 4242                            # el pid del paso anterior
   sleep 3; tail -n 2 /tmp/sin-tmux.log
   sleep 3; tail -n 2 /tmp/sin-tmux.log      # no avanza: la tarea murió con la shell
   ```

2. **Con tmux.** En una terminal A nueva:
   ```bash
   tmux -L lab new -s larga
   ./starter/tarea-larga.sh /tmp/con-tmux.log
   ```
   En B, desconecta el cliente de A **y mata la shell que lo lanzó**:
   ```bash
   tmux -L lab detach-client -P -s larga
   sleep 3; tail -n 2 /tmp/con-tmux.log
   sleep 3; tail -n 2 /tmp/con-tmux.log      # sigue avanzando
   ```
   La terminal A se cerró (o su shell terminó), pero la tarea sigue escribiendo.

3. Recupera la sesión desde cualquier terminal:
   ```bash
   tmux -L lab attach -t larga
   ```
   La tarea sigue ahí, en primer plano, como la dejaste. Párala con `Ctrl+c`.

4. **Detach no es kill.** Compara las dos cosas con la sesión todavía viva:
   ```bash
   tmux -L lab detach-client -s larga        # la sesión sigue: tmux -L lab ls
   tmux -L lab kill-session -t larga         # la sesión y su tarea desaparecen
   tmux -L lab ls                            # no server running: era la última
   ```

5. Completa `starter/lanzar.sh`: lanza la tarea **directamente como programa
   de la ventana** de una sesión en segundo plano, sin abrir una shell y sin
   conectarte. Ejecútalo y comprueba el log:
   ```bash
   ./starter/lanzar.sh /tmp/lanzada.log
   ```
   ```
   tarea lanzada en la sesión "larga"; vuelve con: tmux -L lab attach -t larga
   ```
   ```bash
   sleep 3; tail -n 1 /tmp/lanzada.log
   ```

6. Mira qué pasa cuando el programa de la ventana termina: `tarea-larga.sh`
   acepta un segundo argumento con los segundos que dura.
   ```bash
   tmux -L lab kill-server
   ./starter/lanzar.sh /tmp/corta.log 3
   sleep 5; tmux -L lab ls
   ```
   Al terminar el programa se cierra el panel; sin paneles se cierra la
   ventana; sin ventanas, la sesión; sin sesiones, el servidor. Es la misma
   cadena que viste con `exit` en el lab 01.

7. Limpia: `tmux -L lab kill-server; rm -f /tmp/*-tmux.log /tmp/lanzada.log /tmp/corta.log`.

## Criterios de éxito

- [ ] El log de `sin-tmux` se detiene tras el SIGHUP y el de `con-tmux` sigue avanzando
- [ ] Recuperaste la sesión `larga` con `attach` después de que su terminal se cerrara
- [ ] `./starter/lanzar.sh` deja una sesión `larga` sin clientes (`tmux -L lab ls` no dice `attached`) y el log avanza
- [ ] Puedes explicar quién es el proceso padre de la tarea dentro y fuera de tmux

## Reto extra

Comprueba el árbol de procesos con `ps -o pid,ppid,comm -p "$(pgrep -f tarea-larga)"`
dentro y fuera de tmux. ¿Quién es el padre en cada caso? Busca el pid del
servidor con `tmux -L lab display-message -p '#{pid}'`.
