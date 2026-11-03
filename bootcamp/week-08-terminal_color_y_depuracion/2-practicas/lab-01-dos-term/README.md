# Lab 01 — Dos TERM

⏱ Duración estimada: ~60 min

## Objetivo

Distinguir el `TERM` de fuera (el de tu terminal, que lee el cliente) del `TERM` de dentro (el que tmux da a los programas de los paneles) y comprobar qué se rompe si el de dentro miente.

## Contexto

- Fuera: tu terminal pone `TERM` (casi siempre `xterm-256color`) y tmux lo guarda por cliente en `#{client_termname}`. Si no existe su entrada terminfo, no te puedes conectar.
- Dentro: cada panel nace con `TERM` = `default-terminal`. En 3.4 ya vale `tmux-256color`: describe a tmux, no a tu terminal.
- Lo que cambia `default-terminal` solo lo ven los paneles **nuevos**: el entorno de un proceso se fija al arrancarlo.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-01-dos-term
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **El TERM de fuera.** En la terminal A:
   ```bash
   echo "$TERM"
   infocmp -1 "$TERM" | head -2
   ```
   En el laboratorio Docker:
   ```
   xterm-256color
   #	Reconstructed via infocmp from file: /usr/share/terminfo/x/xterm-256color
   xterm-256color|xterm with 256 colors,
   ```
   En tu equipo puede salir otro nombre (`xterm-kitty`, `alacritty`,
   `xterm-ghostty`...). `infocmp` dice de qué archivo leyó la descripción:
   si imprime `couldn't open terminfo file`, tu sistema no conoce ese
   `TERM` (lab-02).

2. **Arranca y mira el de dentro** (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab show -sv default-terminal
   tmux -L lab display -p 'fuera:[#{client_termname}] dentro:[#{default-terminal}]'
   ```
   ```
   0
   tmux-256color
   fuera:[] dentro:[tmux-256color]
   ```
   `fuera` sale vacío: todavía no hay ningún cliente, y el `TERM` de fuera
   es de cada cliente. Pregúntale al panel qué `TERM` tiene:
   ```bash
   tmux -L lab send-keys -t api 'echo "dentro: $TERM"' Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep '^dentro'
   ```
   ```
   dentro: tmux-256color
   ```

3. **Conéctate.** En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   Dentro de la B escribe `clear; echo "$TERM"`:
   ```
   tmux-256color
   ```
   En la A, el cliente sí tiene `TERM` de fuera:
   ```bash
   tmux -L lab list-clients -F '#{client_name} #{client_termname}'
   ```
   Algo como (cambia el número de `pts`):
   ```
   /dev/pts/1 xterm-256color
   ```
   Sal de la B con `C-b` `d`: imprime `[detached (from session api)]`.

4. **Otro TERM de fuera, el mismo de dentro.** En la B, conéctate
   diciendo que tu terminal es otra:
   ```bash
   TERM=screen-256color tmux -L lab attach -t api
   ```
   En la A:
   ```bash
   tmux -L lab list-clients -F '#{client_name} #{client_termname}'
   ```
   ```
   /dev/pts/1 screen-256color
   ```
   En la B, `clear; echo "$TERM"` sigue imprimiendo `tmux-256color`: el de
   dentro no depende del de fuera. Sal con `C-b` `d`.

5. **Un TERM de fuera que no existe.** En la B (fuera de tmux):
   ```bash
   TERM=noexiste-term tmux -L lab attach -t api; echo $?
   TERM=dumb tmux -L lab attach -t api; echo $?
   ```
   ```
   missing or unsuitable terminal: noexiste-term
   1
   open terminal failed: terminal does not support clear
   1
   ```
   tmux lee la descripción de tu terminal antes de dibujar nada. Sin ella
   (o con una que no sabe ni borrar la pantalla) no conecta. Es lo que pasa
   por SSH a un servidor sin la entrada de tu terminal (lab-02).

6. **Por qué no `xterm-256color` dentro.** Cada `TERM` dice qué bytes manda
   cada tecla. Compara Inicio y Fin (terminal A):
   ```bash
   for t in tmux-256color xterm-256color; do printf '%-15s Inicio=%s Fin=%s\n' "$t" "$(tput -T "$t" khome | cat -v)" "$(tput -T "$t" kend | cat -v)"; done
   ```
   ```
   tmux-256color   Inicio=^[[1~ Fin=^[[4~
   xterm-256color  Inicio=^[OH Fin=^[OF
   ```
   Y mira lo que tmux le manda de verdad a un panel:
   ```bash
   tmux -L lab send-keys -t api 'clear; cat -v' Enter
   sleep 0.5; tmux -L lab send-keys -t api Home End Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -1
   tmux -L lab send-keys -t api C-c
   ```
   ```
   ^[[1~^[[4~
   ```
   tmux manda lo que dice `tmux-256color`. Un programa al que le digas
   `xterm-256color` espera `^[OH` y no reconoce `^[[1~`: Inicio y Fin no
   hacen nada o escriben basura. Ahora haz la prueba que no debes hacer en
   tu config:
   ```bash
   tmux -L lab set -s default-terminal xterm-256color
   tmux -L lab new-window -t api
   sleep 0.5; tmux -L lab send-keys -t api:1 'echo "dentro: $TERM"' Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api:1 | grep '^dentro'
   tmux -L lab send-keys -t api:0 'clear; echo "dentro: $TERM"' Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api:0 | grep '^dentro'
   ```
   ```
   dentro: xterm-256color
   dentro: tmux-256color
   ```
   La ventana nueva ya miente; la vieja no cambió. Deshazlo (`-u` devuelve
   la opción a su valor por defecto):
   ```bash
   tmux -L lab kill-window -t api:1
   tmux -L lab set -su default-terminal; tmux -L lab show -sv default-terminal
   ```
   ```
   tmux-256color
   ```

7. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` (imprime
   `0`).

   1. **TODO 1: TERM de dentro explícito.** Pista:
      `set -s default-terminal tmux-256color`.
      ```bash
      tmux -L lab show -sv default-terminal
      ```
      ```
      tmux-256color
      ```
      El valor no cambia: ya era el defecto. Lo escribes para que una
      config de la distro o un `local.conf` viejo no te lo cambie sin que te
      enteres.
   2. **TODO 2: el TERM de fuera en la barra.** Pista:
      `set -g status-right 'fuera: #{client_termname} '`.
      ```bash
      tmux -L lab display -p '#{E:status-right}|'
      ```
      ```
      fuera:  |
      ```
      Vacío: `display -p` desde la A no es ningún cliente. Conéctate en la
      B con `tmux -L lab attach -t api`. La barra, algo como:
      ```
      [api] 0:bash*                                                       fuera: xterm-256color
      ```
   3. **TODO 3: `prefix` `T` con los dos.** Pista:
      `bind T display-message 'fuera: #{client_termname} · dentro: #{default-terminal}'`.
      `#{default-terminal}` lee la opción como si fuera una variable.
      ```bash
      tmux -L lab list-keys -T prefix T
      ```
      ```
      bind-key -T prefix T display-message "fuera: #{client_termname} · dentro: #{default-terminal}"
      ```
      En la B pulsa `C-b` `T`. La barra muestra un momento:
      ```
      fuera: xterm-256color · dentro: tmux-256color
      ```

8. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Sin cliente, `display -p '#{client_termname}'` sale vacío y explicas por qué (paso 2)
- [ ] Con `TERM=screen-256color` fuera, `list-clients` lo muestra y el panel sigue con `tmux-256color` (paso 4)
- [ ] Explicas qué significa `missing or unsuitable terminal` y cuándo aparece (paso 5)
- [ ] Explicas con `tput` y `cat -v` qué se rompe con `default-terminal xterm-256color` y por qué la ventana vieja no cambió (paso 6)
- [ ] `tmux -L lab show -sv default-terminal` imprime `tmux-256color` con tu config (paso 7.1)
- [ ] La barra de la B muestra `fuera: xterm-256color` y `C-b` `T` muestra los dos `TERM` (pasos 7.2 y 7.3)

## Reto extra

Conecta dos clientes a la vez a la misma sesión, uno normal y otro con
`TERM=screen-256color`. ¿Qué enseña la barra de cada uno? Explica por qué
`status-right` puede mostrar un valor distinto en cada cliente aunque la
opción sea una sola.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — terminfo](../lab-02-terminfo/README.md) → |

[↑ Semana 08](../../README.md)
