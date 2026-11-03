# Lab 02 — Seleccionar y copiar

⏱ Duración estimada: ~60 min

## Objetivo

Seleccionar texto por caracteres, líneas y rectángulos en copy mode y enviarlo a un comando con `copy-pipe`, con el teclado y con el ratón.

## Contexto

- Las teclas de copy mode viven en la tabla `copy-mode-vi` y ejecutan órdenes del modo con `send -X`: `begin-selection`, `rectangle-toggle`, `copy-pipe-and-cancel`...
- `copy-pipe-and-cancel` sin argumento envía la selección a `copy-command`. En este lab ese comando escribe en `/tmp/lab-copia.txt`; en el lab 05 será tu portapapeles.
- Toda copia crea además un buffer de tmux (lab 03).

## Instrucciones

0. Abre **dos terminales fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía): la **A** se conectará al lab, la **B** se queda fuera. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-02-seleccionar-y-copiar
   ```
   Servidor aparte: `-L lab`.

1. En la terminal B, arranca el servidor con el starter:
   ```bash
   tmux -L lab -f starter/tmux.conf new -d; echo $?
   ```
   ```
   0
   ```
   En la terminal A, conéctate (`tmux -L lab attach`). El prefix es `C-b`: el
   starter no define otro. Genera algo que copiar:
   ```bash
   ls -l /etc | head -7
   ```
   Algo como (los nombres, fechas y tamaños dependen de tu `/etc`):
   ```
   total 328
   -rw-r--r-- 1 root root    3444 Jul  5  2023 adduser.conf
   drwxr-xr-x 1 root root    4096 Nov  2 03:04 alternatives
   drwxr-xr-x 8 root root    4096 Sep 11 02:03 apt
   -rw-r--r-- 1 root root    2319 Mar 31  2024 bash.bashrc
   drwxr-xr-x 2 root root    4096 Nov  2 03:04 bash_completion.d
   -rw-r--r-- 1 root root     367 Aug  2  2022 bindresvport.blacklist
   ```
   Todos los pasos empiezan igual para que el cursor caiga siempre en el
   mismo sitio: `C-b` `[` (copy mode), `?` `total` `Enter` (el cursor va a la
   `t` de `total`) y `j` (baja a la primera línea de archivo, columna 0).

2. **Las teclas por defecto: una palabra.** En la terminal A: `C-b` `[`, `?`
   `total` `Enter`, `j`, `$` (fin de línea), `B` (principio del nombre de
   archivo), `Space` (empieza la selección), `E` (hasta el siguiente
   espacio) y `Enter` (copia y sale). En la terminal B:
   ```bash
   tmux -L lab list-buffers
   cat /tmp/lab-copia.txt; echo
   ```
   ```
   buffer0: 12 bytes: "adduser.conf"
   adduser.conf
   ```
   El buffer y el archivo tienen el mismo texto: `Enter` hace
   `copy-pipe-and-cancel`. En la terminal A, pega con `C-b` `]`: el nombre
   aparece en tu prompt. Bórralo con `C-u` sin ejecutarlo.

3. **Líneas enteras.** En la terminal A: `C-b` `[`, `?` `total` `Enter`, `j`,
   `V` (selecciona la línea), `j` `j` (amplía a tres), `o` (el cursor salta al
   otro extremo, la primera), `k` (amplía hacia arriba hasta `total`) y
   `Enter`. En la terminal B:
   ```bash
   tmux -L lab show-buffer | wc -l
   cat /tmp/lab-copia.txt
   ```
   ```
   4
   total 328
   -rw-r--r-- 1 root root    3444 Jul  5  2023 adduser.conf
   drwxr-xr-x 1 root root    4096 Nov  2 03:04 alternatives
   drwxr-xr-x 8 root root    4096 Sep 11 02:03 apt
   ```

4. **La trampa de `v`.** En la terminal A: `C-b` `[` y `v`. No empieza
   ninguna selección: por defecto, `v` alterna el **modo rectángulo**. Sal con
   `q`. Úsalo para copiar solo la columna de permisos: `C-b` `[`, `?` `total`
   `Enter`, `j`, `0` (principio de línea), `Space` (empieza), `v`
   (rectángulo), `E` (fin de los permisos), `j` `j` `j` `j` `j` (cinco líneas
   más) y `Enter`. En la terminal B:
   ```bash
   cat /tmp/lab-copia.txt; echo
   awk '{print length}' /tmp/lab-copia.txt | sort -u
   ```
   ```
   -rw-r--r--
   drwxr-xr-x
   drwxr-xr-x
   -rw-r--r--
   drwxr-xr-x
   -rw-r--r--
   10
   ```
   Seis líneas, todas de diez caracteres.

5. **TODO 1** de `starter/tmux.conf`: que `v` empiece la selección. Pista:
   `bind -T copy-mode-vi v send -X begin-selection`. En la terminal B:
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab list-keys -T copy-mode-vi v
   ```
   ```
   bind-key -T copy-mode-vi v send-keys -X begin-selection
   ```

6. **TODO 2**: `C-v` alterna el rectángulo. Pista: la misma forma con
   `C-v` y `rectangle-toggle`.
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab list-keys -T copy-mode-vi C-v
   ```
   ```
   bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
   ```
   `C-v` ya hacía eso por defecto, así que esta salida no cambia: escribirlo
   deja la config completa aunque cambien los valores por defecto.

7. **TODO 3**: `y` copia y sale. Pista: `send -X copy-pipe-and-cancel`, sin
   nada detrás.
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab list-keys -T copy-mode-vi y
   ```
   ```
   bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
   ```
   Repite el rectángulo con las teclas nuevas, en la terminal A: `C-b` `[`,
   `?` `total` `Enter`, `j`, `0`, `v` (empieza), `C-v` (rectángulo), `E`,
   `j` `j` `j` `j` `j` e `y`. En la terminal B,
   `awk '{print length}' /tmp/lab-copia.txt | sort -u` vuelve a imprimir `10`.

8. **TODO 4**: el ratón. Pista: `set -g mouse on`.
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab show -gv mouse
   ```
   ```
   on
   ```
   En la terminal A, arrastra con el botón izquierdo sobre `alternatives`:
   tmux entra en copy mode, selecciona y, al soltar, copia con
   `copy-command` y sale. Un doble clic copia una palabra. En la terminal B,
   `cat /tmp/lab-copia.txt; echo` muestra lo que seleccionaste.
   Con `mouse on` tu terminal ya no selecciona: lo hace tmux. Para usar la
   selección propia de la terminal, mantén `Shift` (en iTerm2, `Option`)
   mientras arrastras. Esa selección no sabe de paneles: copia también lo que
   hay en el panel de al lado.

9. Limpia, en la terminal B:
   ```bash
   tmux -L lab kill-server; rm -f /tmp/lab-copia.txt
   ```
   La terminal A muestra `[server exited]`.

## Criterios de éxito

- [ ] Paso 4: copias la columna de permisos con `Space` `v` y `/tmp/lab-copia.txt` tiene seis líneas de diez caracteres
- [ ] Paso 5: `tmux -L lab list-keys -T copy-mode-vi v` muestra `begin-selection`
- [ ] Paso 7: `tmux -L lab list-keys -T copy-mode-vi y` muestra `copy-pipe-and-cancel` sin comando, y el rectángulo con `v` `C-v` `y` da otra vez `10`
- [ ] Paso 8: arrastrar con el ratón escribe la selección en `/tmp/lab-copia.txt`
- [ ] Explicas por qué basta cambiar `copy-command` para que `y`, `Enter` y el ratón copien al mismo sitio

## Reto extra

Haz que `Y` copie la selección **sin** salir de copy mode (`copy-pipe`, sin
`-and-cancel`). ¿En qué situación prefieres seguir dentro?
