# Lab 06 — El portapapeles roto

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de una config que copia con OSC 52, usando `show-options`, `show-messages -T` y la propia secuencia.

## Contexto

Un compañero preparó `starter/tmux.conf` y `starter/osc52.sh` para trabajar
por SSH: nada de `xclip` ni `pbcopy`, todo con OSC 52, que atraviesa la
conexión hasta tu terminal. "En mi máquina funcionaba". Tú copias con `y` y
`Ctrl+V` no pega nada. Hay **cuatro errores reales**.

Necesitas una terminal que soporte OSC 52: Windows Terminal, iTerm2 (activa
*Applications in terminal may access clipboard*), kitty, WezTerm, Alacritty o
foot. Terminal.app de macOS no lo soporta. El laboratorio sirve: el OSC 52
sale del contenedor hacia tu terminal igual que por SSH.

## Instrucciones

1. Arranca con la config rota y copia algo:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf"
   echo copiame
   ```
   `prefix` `[`, `?` `copiame` `Enter`, `v`, `e`, `y`. Pega con `Ctrl+V` (o
   `Cmd+V`) en el navegador: nada, o lo que tuvieras antes. El texto sí está
   en tmux: `prefix` `#` lo muestra.

2. Desde aquí, trabaja en una **segunda terminal** (`docker compose exec lab
   bash` si usas el laboratorio) y recarga con
   `tmux -L lab source-file "$PWD/starter/tmux.conf"` después de cada cambio
   (ruta absoluta, como en el lab 05: `@lab-dir` sale de ella).

3. **¿Envía tmux algo?**
   ```bash
   tmux -L lab show -sv set-clipboard
   ```
   ```
   off
   ```
   El comentario dice "que los programas no toquen mi portapapeles", pero
   `off` apaga **también** el OSC 52 que envía tmux al copiar. **Error 1.**
   Ponlo en `on`: tmux envía el OSC 52 al copiar y acepta el de los programas
   del panel (nvim por SSH). Con `external`, solo el de tmux.

4. Recarga y copia otra vez: sigue sin pegar. ¿Sabe tmux cómo enviar OSC 52
   a tu terminal? Esa receta es la capacidad `Ms` de terminfo:
   ```bash
   tmux -L lab show-messages -T | grep ' Ms:'
   ```
   ```
    193: Ms: [missing]
   ```
   (El número puede cambiar.) Tu terminfo sí la tiene: `infocmp -x | grep -o
   'Ms=[^,]*'`. La quita la línea `set -ga terminal-overrides ',*:Ms@'`: `@`
   borra una capacidad, y `*` lo hace para cualquier terminal. Era el apaño
   para una terminal vieja que imprimía basura. **Error 2.** Bórrala. Las
   capacidades se calculan al conectar el cliente: recarga, sal con `prefix`
   `d` y vuelve a entrar (`tmux -L lab attach`).
   ```bash
   tmux -L lab show-messages -T | grep ' Ms:'
   ```
   ```
    193: Ms: (string) \033]52;%p1%s;%p2%s\a
   ```
   Copia con `y` y pega fuera de tmux: funciona.

5. **`prefix` `Y`.** El atajo debería mandar el último buffer al
   portapapeles. Pulsa `prefix` `Y`:
   ```
   .../osc52.sh: line 8: /dev/tty: No such device or address
   'tmux save-buffer - | ...' returned 1
   ```
   `run-shell` ejecuta el comando sin terminal: no hay `/dev/tty` donde
   escribir. **Error 3.** Dentro de tmux, el script debe pedirle a tmux que
   envíe él la secuencia:
   ```bash
   if [[ -n "${TMUX:-}" ]]; then
     exec tmux load-buffer -w -
   fi
   ```
   `load-buffer -w` guarda el texto en un buffer y lo envía con OSC 52 a la
   terminal exterior, respetando `set-clipboard` y `terminal-features`.
   Comprueba: `tmux -L lab set-buffer desde-Y`, `prefix` `Y` y `Ctrl+V`
   fuera.

6. **Textos largos.** Fuera de tmux, en tu terminal, copia algo corto y algo
   largo:
   ```bash
   printf corto | ./starter/osc52.sh             # pega "corto"
   seq 1 100 | ./starter/osc52.sh                # no pega, o pega basura
   seq 1 100 | OSC52_TTY=/tmp/osc ./starter/osc52.sh; wc -l < /tmp/osc
   ```
   ```
   5
   ```
   `base64` parte su salida cada 76 caracteres, y la secuencia OSC 52 debe ir
   en **una** línea. **Error 4.** Usa `base64 | tr -d '\n'` (`base64 -w0`
   no existe en macOS). Repite: `wc -l` da `0` y el texto largo se pega
   entero.

7. Limpia: `tmux -L lab kill-server; rm -f /tmp/osc`.

## Criterios de éxito

- [ ] Los cuatro errores identificados, con una línea por cada uno explicando el síntoma y la causa
- [ ] `tmux -L lab show -sv set-clipboard` imprime `on`
- [ ] `tmux -L lab show-messages -T | grep ' Ms:'` muestra la secuencia, no `[missing]`
- [ ] `prefix` `Y` copia el último buffer sin errores
- [ ] `seq 1 100 | OSC52_TTY=/tmp/osc ./starter/osc52.sh; wc -l < /tmp/osc` imprime `0`
- [ ] Copias en copy mode y pegas fuera de tmux con `Ctrl+V`

## Reto extra

Por SSH a otra máquina con tmux, ejecuta `printf remoto | ./osc52.sh` dentro
de un panel y pega en local. ¿Qué piezas tienen que estar bien en el tmux
**remoto** y cuáles en el local, si también usas tmux en tu máquina?
