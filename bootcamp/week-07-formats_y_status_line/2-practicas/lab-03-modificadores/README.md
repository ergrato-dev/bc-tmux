# Lab 03 — Modificadores

⏱ Duración estimada: ~60 min

## Objetivo

Transformar valores de formats (recortar, rellenar, sustituir, sacar el nombre de una ruta, dar formato a una fecha, citar para la shell y calcular) para que quepan y se lean en la barra.

## Contexto

- Un modificador va delante de la variable, separado por `:`: `#{b:pane_current_path}` es el nombre de la carpeta, no la ruta entera. Funciona con variables y con opciones (`#{b:@lab-path}`).
- La barra tiene sitio limitado: `#{=N:...}` corta por la izquierda, `#{=-N:...}` por la derecha y `#{=/N/…:...}` añade una marca de corte.
- `#{E:opción}` expande el format guardado en una opción y `#{e|op|:a,b}` calcula. `e|` no resuelve nombres: sus argumentos se escriben `#{...}`.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-03-modificadores
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**.

1. **Arranca con el starter.** Ya define `@lab-path` con una ruta de
   ejemplo (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   ```
   ```
   0
   ```

2. **Recortar, rellenar y medir.**
   ```bash
   tmux -L lab display -p '#{=4:@lab-path} | #{=-7:@lab-path} | #{=/10/…:@lab-path} | #{=/-10/…:@lab-path}'
   tmux -L lab display -p '[#{p6:session_name}] [#{p-6:session_name}] #{n:@lab-path}'
   ```
   ```
   /hom | main.go | /home/alum… | …pi/main.go
   [api   ] [   api] 28
   ```
   `p6` rellena a 6 por la derecha y `p-6` por la izquierda: sirve para que
   la barra no "baile" cuando un valor cambia de longitud. `n:` es la
   longitud.

3. **Rutas y sustituciones.**
   ```bash
   tmux -L lab display -p '#{b:@lab-path} | #{d:@lab-path}'
   tmux -L lab display -p '#{s/alumno/tu/:@lab-path} | #{s/[aeiou]//:session_name}'
   ```
   ```
   main.go | /home/alumno/src/api
   /home/tu/src/api/main.go | p
   ```
   `s/patrón/texto/` usa una expresión regular y cambia **todas** las
   coincidencias: de `api` solo queda la `p`.

4. **Fechas.** `start_time` es la hora a la que arrancó el servidor, en
   segundos:
   ```bash
   tmux -L lab display -p '#{t:start_time}'
   tmux -L lab display -p '#{t/p:start_time} | %H:%M | #{t/f/%%H#:%%M:start_time}'
   tmux -L lab display -p '#{t/f/%H:%M:start_time}|'
   ```
   Algo como (cambian la fecha y la hora):
   ```
   Tue Nov  3 01:59:07 2026
   01:59 | 01:59 | 01:59
   |
   ```
   `t:` da la fecha larga y `t/p` una corta. `%H:%M` sin `#{}` es la hora
   **actual** (strftime, como en `date`). `t/f/...` acepta un formato
   propio, pero tiene dos trampas: el `:` corta el modificador (se escribe
   `#:`) y tmux pasa strftime a todo el texto antes, así que `%H` se
   escribe `%%H`. Sin escapar, la tercera línea sale vacía.

5. **Literal, citado y aritmética.**
   ```bash
   tmux -L lab display -p '#{l:#{session_name}} vale #{session_name}'
   tmux -L lab set -g @lab-sp 'mi repo; $(touch PWNED)'
   tmux -L lab display -p '#{@lab-sp} -> #{q:@lab-sp}'
   tmux -L lab display -p '#{e|+|:2,3} #{e|-|:#{window_width},40} #{e|/|:7,2} #{e|/|f|2:7,2} #{e|%|:7,2}'
   tmux -L lab display -p '[#{e|-|:window_width,40}] [#{e|*|:#{window_panes},10}]'
   ```
   ```
   #{session_name} vale api
   mi repo; $(touch PWNED) -> mi\ repo\;\ \$\(touch\ PWNED\)
   5 40 3 3.50 1
   [] [10]
   ```
   `q:` escapa espacios, `;`, `$` y paréntesis: es lo que usarás en el
   lab-05 antes de pasar una ruta a la shell. `e|/|` divide enteros; con
   `f|2` da dos decimales. `window_width` sin `#{}` dentro de `e|` da
   vacío, sin error.

6. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"` (sin salida).

   1. **TODO 1: nombre de sesión cortado.** Pista:
      `set -g status-left-length 30` y
      `set -g status-left '[#{=/8/…:session_name}] '`.
      ```bash
      tmux -L lab display -p '#{E:status-left}'
      tmux -L lab rename-session backend-de-pagos
      tmux -L lab display -p '#{E:status-left}'
      ```
      ```
      [api] 
      [backend-…] 
      ```
   2. **TODO 2: ventanas por carpeta.** Pista:
      `set -g window-status-format '#I:#{b:pane_current_path} '` y
      `set -g window-status-current-format '#I:#{b:pane_current_path}* '`.
      `#I` es el atajo de `#{window_index}`.
      ```bash
      tmux -L lab display -p '#{E:window-status-current-format}'
      tmux -L lab send-keys 'cd /tmp' Enter
      tmux -L lab display -p '#{E:window-status-current-format}'
      ```
      ```
      0:lab-03-modificadores* 
      0:tmp* 
      ```
      `send-keys` escribe `cd /tmp` en el panel; la ventana cambia de
      nombre en la barra sin que hagas nada más.
   3. **TODO 3: una etiqueta reutilizable.** Pista:
      `set -g @lab-label '#{session_name}@#{host_short}'` y
      `set -g status-right '#{E:@lab-label} %H:%M '`.
      ```bash
      tmux -L lab display -p '#{E:status-right}'
      ```
      Algo como (cambian el host y la hora):
      ```
      backend-de-pagos@bc-tmux-lab 01:59 
      ```
   4. **TODO 4: aritmética.** Pista:
      `set -g status-right '#{e|-|:#{window_width},40}c #{E:@lab-label} %H:%M '`.
      ```bash
      tmux -L lab display -p '#{E:status-right}'
      ```
      ```
      40c backend-de-pagos@bc-tmux-lab 01:59 
      ```
      Sin cliente, la ventana mide 80 columnas (`default-size`). Conéctate
      en la terminal B:
      ```bash
      tmux -L lab attach -t backend-de-pagos
      ```
      La barra, algo como (con una terminal de 90 columnas):
      ```
      [backend-…] 0:tmp*                           50c backend-de-pagos@bc-tmux-lab 01:59
      ```
      En la A, `tmux -L lab display -p '#{window_width}'` imprime el ancho
      de tu B (aquí `90`). Cambia el tamaño de la ventana de la B y vuelve a
      mirarla: el número sigue al ancho en el siguiente redibujado.

7. **Por qué el corte va en el format.** Con un `status-left-length` más
   corto que el texto, tmux corta el lado entero, sin marca (terminal A):
   ```bash
   tmux -L lab set -g status-left-length 5
   ```
   ```
   (sin salida)
   ```
   La B pasa a `[back0:tmp*`: se perdió el `]` y el espacio. Vuelve a tu
   config con `tmux -L lab source-file "$PWD/starter/tmux.conf"`.

8. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session backend-de-pagos)]
   ```
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `display -p '#{=/10/…:@lab-path}'` imprime `/home/alum…` y explicas la diferencia con `#{=4:...}` (paso 2)
- [ ] Explicas por qué `#{t/f/%H:%M:start_time}` sale vacío y cómo se escribe bien (paso 4)
- [ ] `display -p '#{q:@lab-sp}'` imprime la cadena escapada y explicas para qué sirve (paso 5)
- [ ] Con la sesión `backend-de-pagos`, `display -p '#{E:status-left}'` imprime `[backend-…] ` (paso 6.1)
- [ ] Tras `cd /tmp` en el panel, `display -p '#{E:window-status-current-format}'` imprime `0:tmp* ` (paso 6.2)
- [ ] La barra de la B muestra `ANCHOc sesión@host HH:MM` y el número cambia con el ancho (paso 6.4)

## Reto extra

Añade a la derecha, delante de la etiqueta, la ruta del panel cortada a sus
últimos 20 caracteres con marca de corte: `#{=/-20/…:pane_current_path}`.
Pruébala con `send-keys 'cd /usr/share/doc' Enter` y con `cd /tmp`: ¿cuándo
aparece la `…`? Rellénala con `p20` para que la hora no se mueva al cambiar
de carpeta.
