# Lab 05 — Navegación consciente

⏱ Duración estimada: ~60 min

## Objetivo

Moverte entre paneles con `C-h` `C-j` `C-k` `C-l` sin prefix, dejando esas teclas al programa del panel cuando usa la pantalla alternativa, y medir lo que la shell pierde.

## Contexto

- Un binding en `root` se queda la tecla para **todos** los programas. `if -F '#{alternate_on}'` la devuelve cuando el panel está en la pantalla alternativa: la que usan `less`, `watch` o un editor y que desaparece al salir.
- `#{pane_current_command}` parece más cómodo ("si es `less`..."), pero en una tubería dice `bash` y por SSH dice `ssh`. Lo compruebas en el paso 2.
- No requiere ningún plugin ni que el editor colabore. A cambio, dentro de un programa a pantalla completa te mueves con `prefix` + flecha.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-06-key_bindings_tablas_y_navegacion/2-practicas/lab-05-navegacion-consciente
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **Qué es `C-h` para tu shell.** Arranca con el starter (todavía no hace
   nada) y parte la ventana a los lados (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab split-window -h
   tmux -L lab list-keys -T root C-h
   ```
   ```
   unknown key: C-h
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t lab
   ```
   Estás en el panel de la derecha. Escribe `echo holax` (sin `Enter`) y
   pulsa `C-h`: se borra la `x`. Para bash, `C-h` es otro borrar. Vacía la
   línea con `C-u`. ¿Qué envía tu tecla `Backspace`? Pulsa `C-v` y después
   `Backspace`, un espacio, `C-v` y `C-h` (`C-v` hace que bash escriba la
   siguiente tecla tal cual). Detrás del prompt aparece algo como:
   ```
   ^? ^H
   ```
   Si tu `Backspace` sale como `^?`, es distinto de `C-h` (`^H`) y podrás
   seguir borrando con él cuando tmux se quede `C-h`. Si sale `^H`, tu
   terminal manda lo mismo para las dos teclas: cámbialo en sus
   preferencias (opción "Backspace envía ^?" o similar) antes de seguir.
   Vacía la línea con `C-u`. Lo mismo desde la shell:
   ```bash
   stty -a | grep -ow 'erase = [^;]*'
   ```
   ```
   erase = ^?
   ```

2. **`alternate_on` frente a `pane_current_command`.** En la B, en el
   panel de la derecha, ejecuta cada programa; mientras está abierto, mira
   en la terminal A, y sal antes del siguiente:
   ```bash
   tmux -L lab display -p -t lab:0.1 '#{alternate_on} #{pane_current_command}'
   ```

   | En la B | Salida en A | Salir |
   |---|---|---|
   | `seq 100 \| less` | `1 bash` | `q` |
   | `less /etc/os-release` | `1 less` | `q` |
   | `top` | `0 top` | `q` |
   | `watch -n1 date` | `1 watch` | `C-c` |
   | (la shell, sin nada) | `0 bash` | |

   - Con la tubería, `pane_current_command` dice `bash`: no sirve para
     saber si hay un `less` delante.
   - `top` **no** usa la pantalla alternativa (al salir, su última
     pantalla se queda en el panel). Para tmux es como la shell: ahí
     `C-h`/`C-j`/`C-k`/`C-l` cambiarán de panel. `top` no las usa, así que
     no pierdes nada.

3. **Los TODOs del starter.** Cada uno se prueba recargando con
   `source-file` en la terminal A y pulsando en la B.

   1. **TODO 1: la versión ingenua.** Debajo del comentario `TODO 1`:
      ```tmux
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R
      ```
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T root C-j
      ```
      ```
      0
      bind-key -T root C-j select-pane -D
      ```
      En la B: `C-h` (al panel izquierdo), `C-l` (al derecho), `C-l` otra
      vez (al izquierdo: al llegar al borde, da la vuelta) y `C-l` (al
      derecho). En el derecho, ejecuta `seq 100 | less` y pulsa `C-j`, que
      en `less` baja una línea. En A:
      ```bash
      tmux -L lab capture-pane -p -t lab:0.1 | head -1
      ```
      ```
      1
      ```
      `less` no bajó: tmux se quedó la tecla (no hay panel debajo, no pasó
      nada). Y `C-h` te saca de `less` al panel izquierdo. Vuelve con
      `C-l`; deja `less` abierto.
   2. **TODO 2: con `if -F`.** **Borra** las cuatro líneas del TODO 1 y
      pon en su lugar:
      ```tmux
      bind -n C-h if -F '#{alternate_on}' 'send-keys C-h' 'select-pane -L'
      bind -n C-j if -F '#{alternate_on}' 'send-keys C-j' 'select-pane -D'
      bind -n C-k if -F '#{alternate_on}' 'send-keys C-k' 'select-pane -U'
      bind -n C-l if -F '#{alternate_on}' 'send-keys C-l' 'select-pane -R'
      ```
      Recargar sustituye las cuatro teclas (es la misma tecla en la misma
      tabla):
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab list-keys -T root C-h
      tmux -L lab list-keys -T root | grep -c alternate_on
      ```
      ```
      0
      bind-key -T root C-h if-shell -F "#{alternate_on}" "send-keys C-h" "select-pane -L"
      4
      ```
      En la B, dentro de `less`: `C-j` `C-j` (baja dos líneas) y `C-k`
      (sube una). En A:
      ```bash
      tmux -L lab capture-pane -p -t lab:0.1 | head -1
      ```
      ```
      2
      ```
      `C-h` dentro de `less` ya no te saca: es de `less`. Para salir del
      panel, `C-b` `←`. Desde la shell del panel izquierdo, `C-l` te lleva
      al de `less`. Comprueba en A tras cada tecla:
      ```bash
      tmux -L lab display -p '#{pane_index}'
      ```
      Tras `C-h` en `less`: `1`. Tras `C-b` `←`: `0`. Tras `C-l`: `1`.
      Sal de `less` con `q`. Ahora `top` en el panel derecho y `C-h`: te
      mueves al izquierdo (paso 2: `alternate_on` es 0). Vuelve con `C-l` y
      sal de `top` con `q`.

4. **Lo que pierde la shell.** En la B, en el panel derecho:
   - Ejecuta `clear; seq 3` y pulsa `C-l`. No se limpia: vas al panel
     izquierdo. En A:
     ```bash
     tmux -L lab capture-pane -p -t lab:0.1 | grep -c .
     ```
     ```
     4
     ```
     (`1`, `2`, `3` y el prompt.) Vuelve con `C-l`.
   - Escribe `echo holax` y `C-h`: la `x` sigue ahí y estás en el panel
     izquierdo. Para borrar, `Backspace`. Vuelve con `C-l` y vacía la línea
     con `C-u`.
   - `C-k` (borrar hasta el final de la línea) y `C-j` (otro `Enter`)
     también dejan de llegar a bash.

   **TODO 3: `C-b` `C-l` limpia.** Pista: `bind C-l send-keys C-l`. En la
   tabla `prefix` no choca con la de `root`.
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab list-keys -T prefix C-l
   ```
   ```
   0
   bind-key -T prefix C-l send-keys C-l
   ```
   En la B, en el panel derecho, `C-b` `C-l`: la pantalla se limpia. En A:
   ```bash
   tmux -L lab capture-pane -p -t lab:0.1 | grep -c .
   ```
   ```
   1
   ```
   Sal de la B con `C-b` `d`:
   ```
   [detached (from session lab)]
   ```

5. **Limpia** (terminal A). Si la B seguía conectada, imprime
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Sabes qué envía tu `Backspace` (`^?` o `^H`) y por qué importa (paso 1)
- [ ] Explicas con la tabla del paso 2 por qué la condición es `alternate_on` y no `pane_current_command`
- [ ] Con el TODO 1, `C-j` no llega a `less`; con el TODO 2, sí (`capture-pane ... | head -1` imprime `2`) (pasos 3.1 y 3.2)
- [ ] `tmux -L lab list-keys -T root | grep -c alternate_on` imprime `4` (paso 3.2)
- [ ] `C-b` `C-l` limpia la shell: `capture-pane ... | grep -c .` imprime `1` (paso 4)

## Reto extra

Haz que `C-h`/`C-j`/`C-k`/`C-l` no den la vuelta en los bordes: en el panel
de más a la izquierda, `C-h` no hace nada. Pista: `#{pane_at_left}`,
`#{pane_at_right}`, `#{pane_at_top}` y `#{pane_at_bottom}` valen 1 en el
borde; anida un segundo `if -F`. ¿Qué haces con la tecla en el borde: la
pierdes o se la mandas a la shell?
