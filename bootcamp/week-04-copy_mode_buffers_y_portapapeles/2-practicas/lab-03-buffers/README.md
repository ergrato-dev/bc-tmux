# Lab 03 — Buffers

⏱ Duración estimada: ~60 min

## Objetivo

Crear, listar, pegar, guardar y cargar buffers de tmux, con y sin nombre, y escribir un script que vuelca todos los buffers a archivos.

## Contexto

- Cada copia crea un buffer automático (`buffer0`, `buffer1`...) encima de una pila. Cuando hay más de `buffer-limit` (50 por defecto), tmux borra los más viejos.
- Un buffer con nombre (`set-buffer -b url ...`) no cuenta para ese límite: se queda hasta que lo borres.
- `paste-buffer` escribe el buffer en un panel como si lo teclearas; con `-p` lo envuelve en *bracketed paste* y la shell no ejecuta nada hasta que pulses `Enter`.

## Instrucciones

0. Abre **dos terminales fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía): la **A** se conectará al lab, la **B** se queda fuera. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-03-buffers
   ```
   Servidor aparte: `-L lab`, sin config (`-f /dev/null`).

1. En la terminal B, crea tres buffers sin copy mode:
   ```bash
   tmux -L lab -f /dev/null new -d
   for p in uno dos tres; do tmux -L lab set-buffer "texto $p"; done
   tmux -L lab list-buffers
   ```
   ```
   buffer2: 10 bytes: "texto tres"
   buffer1: 9 bytes: "texto dos"
   buffer0: 9 bytes: "texto uno"
   ```
   El más reciente arriba: es el que pega `prefix` `]`.

2. **Con nombre y con límite.** En la terminal B, baja el límite a 3, crea un
   buffer con nombre y dos automáticos más:
   ```bash
   tmux -L lab set -s buffer-limit 3
   tmux -L lab set-buffer -b url 'https://github.com/tmux/tmux/wiki'
   for p in cuatro cinco; do tmux -L lab set-buffer "texto $p"; done
   tmux -L lab list-buffers -F '#{buffer_name} #{buffer_size}'
   ```
   ```
   buffer4 11
   buffer3 12
   url 33
   buffer2 10
   ```
   `buffer0` y `buffer1` desaparecieron; `url` sigue. Devuelve el límite a 50:
   ```bash
   tmux -L lab set -s buffer-limit 50
   ```
   ```
   (sin salida)
   ```

3. **Pegar.** En la terminal A, conéctate con `tmux -L lab attach`. El prefix
   es `C-b`: el servidor arrancó con `-f /dev/null`. Prueba, en orden:

   1. `C-b` `]`: en tu prompt aparece `texto cinco`, sin ejecutarse. Bórralo
      con `C-u`.
   2. `C-b` `#`: la lista de buffers, con el mismo formato que
      `list-buffers`, en modo vista. Sal con `q`.
   3. `C-b` `-`: borra el buffer más reciente **sin pedir confirmación**. En
      la terminal B:
      ```bash
      tmux -L lab list-buffers -F '#{buffer_name}'
      ```
      ```
      buffer3
      url
      buffer2
      ```
   4. `C-b` `:` abre la línea de comandos en la barra de estado. Escribe
      `paste-buffer -b url` y `Enter`: la URL aparece en tu prompt. `C-u`.
   5. `C-b` `=`: elige de una lista. `↑`/`↓` mueven, `Enter` pega el buffer
      marcado, `d` lo borra, `t` lo marca para borrar varios con `D`. Sal sin
      hacer nada con `q`.

4. **Bracketed paste.** En la terminal B, crea un buffer con dos órdenes y
   pégalo de las dos formas en el panel de la terminal A (sin `-t`, llega al
   panel activo):
   ```bash
   tmux -L lab set-buffer -b dos-lineas $'echo uno\necho dos\n'
   tmux -L lab paste-buffer -b dos-lineas
   ```
   En la terminal A, las dos órdenes se ejecutan al llegar (algo como, con tu
   prompt en lugar de `$`):
   ```
   $ echo uno
   uno
   $ echo dos
   dos
   ```
   Ahora con `-p`, en la terminal B:
   ```bash
   tmux -L lab paste-buffer -p -b dos-lineas
   ```
   En la terminal A, el texto queda en el prompt **sin ejecutarse** (algo como):
   ```
   $ echo uno
   echo dos
   ```
   Pulsa `Enter` en la terminal A: ahora sí imprime `uno` y `dos`. `prefix`
   `]` pega con `-p` (`tmux -L lab list-keys -T prefix ]` lo muestra), y es
   lo que te salva de pegar un `rm` que no querías. bash 5.1+ y zsh activan
   el bracketed paste por defecto (`echo "$SHELL"` te dice cuál usas); en el
   bash 3.2 de macOS, no, y el pegado se ejecuta igual con `-p`.

5. **Archivos.** En la terminal B, carga un archivo en un buffer y guárdalo
   en otro sitio:
   ```bash
   tmux -L lab load-buffer -b hosts /etc/hosts
   tmux -L lab save-buffer -b hosts /tmp/hosts.copia
   diff /etc/hosts /tmp/hosts.copia && echo iguales
   ```
   ```
   iguales
   ```
   Con `-a`, `save-buffer` añade al final en vez de sobrescribir. Las rutas
   relativas se resuelven desde el directorio en el que ejecutas `tmux`.

6. **El script** `starter/guardar-buffers.sh`: guarda cada buffer en
   `DIR/NOMBRE.txt`. En la terminal B, crea antes un buffer con `/` en el
   nombre, que no puede ser nombre de archivo:
   ```bash
   tmux -L lab set-buffer -b a/b 'con barra'
   ```
   ```
   (sin salida)
   ```

   1. **TODO 1**: lee la lista y falla si no hay nada (la pista exacta está
      en el starter). Pruébalo con un socket donde no hay servidor
      (`TMUX_SOCKET` cambia el `-L` del script):
      ```bash
      TMUX_SOCKET=nadie ./starter/guardar-buffers.sh /tmp/buffers; echo $?
      ```
      ```
      guardar-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)
      1
      ```
   2. **TODO 2**: borra las dos líneas `sin implementar` del final, crea el
      directorio y guarda cada buffer con `save-buffer -b`, cambiando `/` por
      `_` en el nombre del archivo.
      ```bash
      ./starter/guardar-buffers.sh /tmp/buffers; echo $?
      ls /tmp/buffers
      ```
      ```
      0
      a_b.txt
      buffer2.txt
      buffer3.txt
      dos-lineas.txt
      hosts.txt
      url.txt
      ```
   3. **TODO 3**: una línea por buffer guardado.
      ```bash
      ./starter/guardar-buffers.sh /tmp/buffers
      ```
      Algo como (el tamaño de `hosts` depende de tu `/etc/hosts`):
      ```
      guardado: a/b (9 bytes)
      guardado: hosts (173 bytes)
      guardado: dos-lineas (18 bytes)
      guardado: buffer3 (12 bytes)
      guardado: url (33 bytes)
      guardado: buffer2 (10 bytes)
      ```
      Comprueba que el contenido es el mismo que el del buffer:
      ```bash
      tmux -L lab show-buffer -b hosts | diff - /tmp/buffers/hosts.txt && echo iguales
      cat /tmp/buffers/a_b.txt; echo
      ```
      ```
      iguales
      con barra
      ```
   4. Sin avisos de `shellcheck` (instálalo si no lo tienes:
      `sudo apt install shellcheck` o `brew install shellcheck`):
      ```bash
      shellcheck starter/guardar-buffers.sh; echo $?
      ```
      ```
      0
      ```

7. Limpia, en la terminal B (la terminal A muestra `[server exited]`):
   ```bash
   tmux -L lab kill-server; rm -rf /tmp/buffers /tmp/hosts.copia
   ```
   Con el servidor parado, el script avisa igual que en el TODO 1:
   ```bash
   ./starter/guardar-buffers.sh /tmp/buffers; echo $?
   ```
   ```
   guardar-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)
   1
   ```

## Criterios de éxito

- [ ] Paso 2: con `buffer-limit 3`, los automáticos viejos desaparecen y `url` se queda
- [ ] Paso 4: explicas la diferencia entre `paste-buffer` con y sin `-p` con lo que viste en la terminal A
- [ ] Paso 6.3: `./starter/guardar-buffers.sh /tmp/buffers` crea un `.txt` por buffer y `diff` dice `iguales`
- [ ] Paso 6.3: el buffer `a/b` se guarda como `a_b.txt`
- [ ] Pasos 6.1 y 7: sin servidor, el script sale con 1 y avisa por stderr
- [ ] Paso 6.4: `shellcheck starter/guardar-buffers.sh` no muestra avisos

## Reto extra

Escribe `cargar-buffers.sh DIR`, la operación inversa: un `load-buffer -b`
por cada `.txt` de `DIR`. ¿Qué pasa si cargas dos veces el mismo directorio?
