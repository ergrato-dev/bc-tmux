# Lab 05 — Escribir en varios paneles a la vez

⏱ Duración estimada: ~60 min

## Objetivo

Enviar el mismo texto a todos los paneles de una ventana, primero con `synchronize-panes` y después con un script que usa `send-keys` de forma segura.

## Contexto

- Con la opción de ventana `synchronize-panes` activada, **lo que escribes en un panel llega a todos** los de esa ventana. Es útil para repetir un comando en varios servidores a la vez y peligrosa si se te olvida que está activa.
- `send-keys` escribe en un panel como si pulsaras las teclas. Interpreta nombres de tecla (`Enter`, `C-c`) salvo que le pases `-l`: con `-l` todo es **texto literal**.
- Si el texto viene de fuera (un argumento, un archivo), envíalo siempre con `-l` y la tecla `Enter` aparte. Así un texto como `C-c` no se convierte en un Ctrl+c.

## Instrucciones

1. Simula tres servidores con tres paneles en tres directorios:
   ```bash
   mkdir -p /tmp/srv-{a,b,c}
   tmux -L lab new -s flota -c /tmp/srv-a \; split-window -h -c /tmp/srv-b \; split-window -h -c /tmp/srv-c \; select-layout even-horizontal
   ```

2. Activa la sincronización desde el prompt (`prefix` `:`):
   ```
   setw synchronize-panes on
   ```
   Escribe `pwd` y Enter: el comando aparece y se ejecuta en los tres
   paneles. Escribe `date > hora.txt`: cada servidor tiene ahora su
   `hora.txt`.

3. Compruébalo desde fuera y desactívalo:
   ```bash
   tmux -L lab show -w -t flota:0 synchronize-panes
   tmux -L lab list-panes -t flota -F '#{pane_id} #{pane_synchronized}'
   tmux -L lab set -w -t flota:0 synchronize-panes off
   ```

4. **El peligro.** Vuelve a activarla y ve a otra ventana (`prefix` `c`). En la
   ventana nueva no está activa: la opción es **por ventana**. Vuelve a la
   ventana `flota` y piensa qué pasaría con un `rm -rf build/` escrito
   creyendo que estabas en un solo panel. En la semana 07 harás que la status
   line te avise cuando está activa. Desactívala.

5. **Con un script.** Completa `starter/difundir.sh`: recibe una ventana y un
   comando, y lo envía a cada panel de esa ventana con `send-keys -l` seguido
   de `Enter`, recorriendo los paneles por id.
   ```bash
   ./starter/difundir.sh flota:0 'ls hora.txt && echo "ok en $PWD"'
   ```
   Cada panel imprime `ok en /tmp/srv-a`, `ok en /tmp/srv-b`... El `$PWD` lo
   expande la shell de **cada panel**, no la tuya.

6. **Por qué `-l`.** Envía con tu script un texto que parece una tecla:
   ```bash
   ./starter/difundir.sh flota:0 'echo C-c Enter'
   ```
   Con `-l` cada panel imprime `C-c Enter`. Quita el `-l` de tu script, repite
   y mira la diferencia: `send-keys` convierte `C-c` y `Enter` en teclas.
   Vuelve a ponerlo.

7. Limpia: `tmux -L lab kill-server; rm -rf /tmp/srv-{a,b,c}`.

## Criterios de éxito

- [ ] Con `synchronize-panes on`, un comando se ejecuta en los tres paneles
- [ ] `#{pane_synchronized}` vale 1 en cada panel mientras está activa
- [ ] `./starter/difundir.sh flota:0 'echo C-c Enter'` imprime el texto literal en los tres paneles
- [ ] Explicas por qué un script nunca debe pasar texto externo a `send-keys` sin `-l`

## Reto extra

Haz que `difundir.sh` acepte `-x PANEL` para saltarse un panel (por ejemplo,
el servidor de producción). ¿Por qué es mejor excluir por id que por índice?
