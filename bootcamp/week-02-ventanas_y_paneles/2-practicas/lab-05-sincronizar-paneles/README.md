# Lab 05 — Escribir en varios paneles a la vez

⏱ Duración estimada: ~60 min

## Objetivo

Enviar el mismo texto a todos los paneles de una ventana, primero con `synchronize-panes` y después con un script que usa `send-keys` de forma segura.

## Contexto

- Con la opción de ventana `synchronize-panes` activada, **lo que escribes en un panel llega a todos** los de esa ventana. Es útil para repetir un comando en varios servidores a la vez y peligrosa si se te olvida que está activa.
- `send-keys` escribe en un panel como si pulsaras las teclas. Cada argumento que sea **exactamente** un nombre de tecla (`Enter`, `C-c`) se envía como esa tecla; el resto, como texto. Con `-l`, todo es **texto literal**.
- Si el texto viene de fuera (un argumento, un archivo), envíalo siempre con `-l` y la tecla `Enter` aparte. Así un texto como `C-c` no se convierte en un Ctrl+c.

## Instrucciones

- **Terminal A**: conectada a la sesión del lab; ahí pulsas las teclas.
- **Terminal B**: otra pestaña, fuera de tmux, para los comandos y el script.

0. En **las dos** terminales, fuera de tmux (`echo "$TMUX"` imprime una línea
   vacía), entra en la carpeta del lab desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-02-ventanas_y_paneles/2-practicas/lab-05-sincronizar-paneles
   ```
   ```
   (sin salida)
   ```
   El servidor del lab (`-L lab`) arranca con `-f /dev/null`: el prefix es
   **`C-b`**.

1. En la **terminal A**, simula tres servidores con tres paneles en tres
   directorios:
   ```bash
   mkdir -p /tmp/srv-{a,b,c}
   tmux -L lab -f /dev/null new -s flota -c /tmp/srv-a \; split-window -h -c /tmp/srv-b \; split-window -h -c /tmp/srv-c \; select-layout even-horizontal
   ```
   Ves tres columnas iguales. En la **terminal B**:
   ```bash
   tmux -L lab list-panes -t flota -F '#{pane_index} #{pane_id} #{pane_current_path}'
   ```
   ```
   0 %0 /tmp/srv-a
   1 %1 /tmp/srv-b
   2 %2 /tmp/srv-c
   ```

2. **Activa la sincronización** en la terminal A: `C-b` `:`, escribe
   `setw synchronize-panes on` y Enter. Escribe `pwd` y Enter: el comando
   aparece y se ejecuta en los tres paneles, cada uno con su directorio
   (`/tmp/srv-a`, `/tmp/srv-b`, `/tmp/srv-c`). Escribe `date > hora.txt` y
   Enter. En la terminal B:
   ```bash
   ls /tmp/srv-*/hora.txt
   tmux -L lab show -w -t flota:0 synchronize-panes
   tmux -L lab list-panes -t flota -F '#{pane_id} #{pane_synchronized}'
   ```
   ```
   /tmp/srv-a/hora.txt
   /tmp/srv-b/hora.txt
   /tmp/srv-c/hora.txt
   synchronize-panes on
   %0 1
   %1 1
   %2 1
   ```
   `flota:0` es la ventana 0 de la sesión `flota`: la opción es de ventana.

3. **La opción es por ventana.** En la terminal A, `C-b` `c` crea la ventana
   1 en la misma sesión. En la terminal B:
   ```bash
   tmux -L lab display-message -p -t flota:0 '#{synchronize-panes}'
   tmux -L lab display-message -p -t flota:1 '#{synchronize-panes}'
   ```
   ```
   1
   0
   ```
   Vuelve a la ventana `flota:0` con `C-b` `0` y piensa qué pasaría con un
   `rm -rf build/` escrito creyendo que estabas en un solo panel. En la
   semana 07 harás que la status line te avise cuando está activa.
   Desactívala desde la terminal B:
   ```bash
   tmux -L lab setw -t flota:0 synchronize-panes off
   tmux -L lab list-panes -t flota:0 -F '#{pane_id} #{pane_synchronized}'
   ```
   ```
   %0 0
   %1 0
   %2 0
   ```

4. **Por qué `-l`.** En la terminal B envía `C-c` a dos paneles, sin y con `-l`:
   ```bash
   tmux -L lab send-keys -t flota:0.1 C-c Enter
   tmux -L lab send-keys -t flota:0.0 -l C-c
   tmux -L lab send-keys -t flota:0.0 Enter
   ```
   ```
   (sin salida)
   ```
   En la terminal A, el panel del centro (`srv-b`) recibió la **tecla** Ctrl+c:
   muestra `^C` y un prompt nuevo. El de la izquierda (`srv-a`) recibió el
   **texto**. Algo como:
   ```
   alumno@bc-tmux-lab:/tmp/srv-a$ C-c
   -bash: C-c: command not found
   ```
   (El prompt y el mensaje dependen de tu shell; con zsh,
   `zsh: command not found: C-c`.) Ojo: `send-keys 'echo C-c Enter'` no convierte
   nada, porque el argumento entero no es un nombre de tecla. El peligro es
   un argumento que **sea** exactamente `C-c`, `C-d` o `Enter`, como el que
   un script recibe de fuera.

5. **El script.** `starter/broadcast.sh` recibe una ventana y un comando y lo
   envía a cada panel por id, siempre con `-l`. Ejecútalo en la terminal B
   (fuera de tmux) con la sesión `flota` viva; el resultado se ve en la
   terminal A.

   1. **TODO 1**: guarda los ids con la línea de la pista. Borra también la
      última línea, `echo "broadcast.sh: sin implementar ..."`. Como no
      imprime nada, pruébalo con `bash -x`:
      ```bash
      bash -x ./starter/broadcast.sh flota:0 pwd 2>&1 | grep -A2 '^+ panes='
      ```
      ```
      + panes='%0
      %1
      %2'
      ```
   2. **TODO 2**: el bucle de la pista. `<<<"$panes"` le da al `while` la
      variable línea a línea.
      ```bash
      ./starter/broadcast.sh flota:0 'ls hora.txt && echo "ok en $PWD"'
      ```
      ```
      (sin salida)
      ```
      En la terminal A, cada panel imprime `hora.txt` y su línea:
      `ok en /tmp/srv-a`, `ok en /tmp/srv-b`, `ok en /tmp/srv-c`. Las comillas
      simples impiden que tu shell expanda `$PWD`: lo expande la shell de
      **cada panel**.
   3. **TODO 3**: el `echo` de resumen.
      ```bash
      ./starter/broadcast.sh flota:0 'C-c'
      ```
      ```
      enviado a 3 paneles de flota:0
      ```
      En la terminal A, los tres paneles muestran `-bash: C-c: command not found` (o el mensaje de tu shell):
      el texto llegó como texto, nunca como Ctrl+c.

6. Limpia. En la terminal A, `C-b` `d`:
   ```
   [detached (from session flota)]
   ```
   En la terminal B:
   ```bash
   tmux -L lab kill-server; rm -rf /tmp/srv-{a,b,c}
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Con `synchronize-panes on`, `date > hora.txt` crea los tres `hora.txt` (paso 2)
- [ ] `#{pane_synchronized}` vale 1 en cada panel mientras está activa y 0 al desactivarla (pasos 2 y 3)
- [ ] `./starter/broadcast.sh flota:0 'C-c'` imprime `command not found` en los tres paneles, no un `^C` (paso 5.3)
- [ ] Explicas por qué un script nunca debe pasar texto externo a `send-keys` sin `-l` (paso 4)

## Reto extra

Haz que `broadcast.sh` acepte `-x PANEL` para saltarse un panel (por ejemplo,
el servidor de producción). ¿Por qué es mejor excluir por id que por índice?
