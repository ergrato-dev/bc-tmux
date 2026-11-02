# Lab 02 — Seleccionar y copiar

⏱ Duración estimada: ~60 min

## Objetivo

Seleccionar texto por caracteres, líneas y rectángulos en copy mode y enviarlo a un comando con `copy-pipe`, con teclas de vim y con el ratón.

## Contexto

- Las teclas de copy mode viven en la tabla `copy-mode-vi` y ejecutan órdenes del modo con `send -X`: `begin-selection`, `rectangle-toggle`, `copy-pipe-and-cancel`...
- `copy-pipe-and-cancel` sin argumento envía la selección a `copy-command`. En este lab ese comando escribe en `/tmp/lab-copia.txt`; en el lab 05 será tu portapapeles.
- Toda copia crea además un buffer de tmux (lab 03).

## Instrucciones

1. Arranca el servidor con el starter y genera algo que copiar:
   ```bash
   tmux -L lab -f starter/tmux.conf
   ls -l /etc | head -15
   ```

2. **Las teclas por defecto.** `prefix` `[`, lleva el cursor al principio de
   un nombre de archivo, pulsa `Space` (empezar), `e` (fin de palabra) y
   `Enter` (copiar y salir). Desde otra terminal:
   ```bash
   tmux -L lab list-buffers
   cat /tmp/lab-copia.txt
   ```
   El buffer y el archivo tienen el mismo texto: `Enter` hace
   `copy-pipe-and-cancel`. Pégalo en el panel con `prefix` `]`.

3. **Líneas enteras.** En copy mode, `V` selecciona la línea; `j` `j` amplía
   a tres; `o` salta al otro extremo, y `k` amplía hacia arriba. `Enter`.
   ```bash
   tmux -L lab show-buffer | wc -l      # 4 líneas
   ```

4. **La trampa de `v`.** En copy mode pulsa `v` como en vim: no empieza
   ninguna selección. Por defecto, `v` alterna el **modo rectángulo**. Úsalo
   para copiar solo la columna de permisos: cursor en la primera `-` o `d`,
   `Space`, `v`, `9` `l` (diez caracteres), `5` `j`, `Enter`.
   ```bash
   cat /tmp/lab-copia.txt
   ```
   ```
   -rw-r--r--
   drwxr-xr-x
   ...
   ```
   (Seis líneas de diez caracteres; los permisos dependen de tu `/etc`.)

5. Resuelve los `TODO 1`, `2` y `3` para que copy mode se maneje como vim, y
   recarga:
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab list-keys -T copy-mode-vi | grep -E ' (v|C-v|y) '
   ```
   ```
   bind-key -T copy-mode-vi C-v               send-keys -X rectangle-toggle
   bind-key -T copy-mode-vi v                 send-keys -X begin-selection
   bind-key -T copy-mode-vi y                 send-keys -X copy-pipe-and-cancel
   ```
   `C-v` ya hacía eso por defecto: escribirlo deja la config completa aunque
   cambien los valores por defecto.
   Repite el paso 4 con `v` `C-v` en lugar de `Space` `v`, y copia con `y`.

6. **El ratón.** Resuelve el `TODO 4` y recarga. Arrastra sobre una palabra
   con el botón izquierdo: tmux entra en copy mode, selecciona y, al soltar,
   copia con `copy-command`. Doble clic copia una palabra.
   ```bash
   cat /tmp/lab-copia.txt
   ```
   Con `mouse on` tu terminal ya no selecciona: lo hace tmux. Para usar la
   selección propia de la terminal, mantén `Shift` (en macOS, `Option`)
   mientras arrastras. Esa selección no sabe de paneles: copia también lo que
   hay en el panel de al lado.

7. Limpia: `tmux -L lab kill-server; rm -f /tmp/lab-copia.txt`.

## Criterios de éxito

- [ ] `tmux -L lab list-keys -T copy-mode-vi v` muestra `begin-selection`
- [ ] `tmux -L lab list-keys -T copy-mode-vi y` muestra `copy-pipe-and-cancel` sin comando
- [ ] Copias la columna de permisos con `v` `C-v` `y` y `/tmp/lab-copia.txt` tiene seis líneas de diez caracteres
- [ ] Arrastrar con el ratón escribe la selección en `/tmp/lab-copia.txt`
- [ ] Explicas por qué basta cambiar `copy-command` para que `y`, `Enter` y el ratón copien al mismo sitio

## Reto extra

Haz que `Y` copie la selección **sin** salir de copy mode (`copy-pipe`, sin
`-and-cancel`). ¿En qué situación prefieres seguir dentro?
