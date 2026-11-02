# Lab 03 — Buffers

⏱ Duración estimada: ~60 min

## Objetivo

Crear, listar, pegar, guardar y cargar buffers de tmux, con y sin nombre, y escribir un script que vuelca todos los buffers a archivos.

## Contexto

- Cada copia crea un buffer automático (`buffer0`, `buffer1`...) encima de una pila. Cuando hay más de `buffer-limit` (50 por defecto), tmux borra los más viejos.
- Un buffer con nombre (`set-buffer -b url ...`) no cuenta para ese límite: se queda hasta que lo borres.
- `paste-buffer` escribe el buffer en un panel como si lo teclearas; con `-p` lo envuelve en *bracketed paste* y la shell no ejecuta nada hasta que pulses `Enter`.

## Instrucciones

1. Crea tres buffers sin copy mode:
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

2. **Con nombre y con límite.** Baja el límite a 3, crea un buffer con nombre
   y dos automáticos más:
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
   `buffer0` y `buffer1` desaparecieron; `url` sigue. Devuelve el límite a
   50: `tmux -L lab set -s buffer-limit 50`.

3. **Pegar.** Conéctate (`tmux -L lab attach`) y prueba:

   | Acción | Cómo |
   |---|---|
   | Pegar el más reciente | `prefix` `]` |
   | Pegar uno concreto | `prefix` `:` y `paste-buffer -b url` |
   | Elegir de una lista | `prefix` `=`: `Enter` pega, `d` borra, `t` marca, `q` sale |
   | Ver la lista | `prefix` `#` |
   | Borrar el más reciente | `prefix` `-` |

4. **Bracketed paste.** Crea un buffer con dos órdenes y pégalo de las dos
   formas en el panel:
   ```bash
   tmux -L lab set-buffer -b dos-lineas $'echo uno\necho dos\n'
   tmux -L lab paste-buffer -b dos-lineas        # sin -p: se ejecutan al llegar
   tmux -L lab paste-buffer -p -b dos-lineas     # con -p: esperan tu Enter
   ```
   La segunda vez bash muestra las dos líneas sin ejecutarlas. Es lo que
   hace `prefix` `]`, y lo que te salva de pegar un `rm` que no querías.

5. **Archivos.** Carga un archivo en un buffer y guárdalo en otro sitio:
   ```bash
   tmux -L lab load-buffer -b hosts /etc/hosts
   tmux -L lab save-buffer -b hosts /tmp/hosts.copia
   diff /etc/hosts /tmp/hosts.copia && echo iguales
   ```
   Con `-a`, `save-buffer` añade al final en vez de sobrescribir. Las rutas
   relativas se resuelven desde el directorio en el que ejecutas `tmux`.

6. Completa `starter/guardar-buffers.sh`: guarda cada buffer en
   `DIR/NOMBRE.txt` y dice qué guardó.
   ```bash
   ./starter/guardar-buffers.sh /tmp/buffers
   ```
   ```
   guardado: hosts (221 bytes)
   guardado: dos-lineas (18 bytes)
   guardado: buffer4 (11 bytes)
   ...
   ```
   (El tamaño de `hosts` depende de tu `/etc/hosts`.) Prueba también sin
   servidor:
   ```bash
   tmux -L lab kill-server
   ./starter/guardar-buffers.sh /tmp/buffers; echo $?
   ```
   ```
   guardar-buffers.sh: no hay buffers que guardar (¿está arrancado el servidor?)
   1
   ```

7. Limpia: `tmux -L lab kill-server; rm -rf /tmp/buffers /tmp/hosts.copia`.

## Criterios de éxito

- [ ] Reproduces el paso 2: con `buffer-limit 3`, los automáticos viejos desaparecen y `url` se queda
- [ ] Explicas la diferencia entre `paste-buffer` con y sin `-p` con el ejemplo del paso 4
- [ ] `./starter/guardar-buffers.sh /tmp/buffers` crea un `.txt` por buffer con el mismo contenido que `show-buffer -b NOMBRE`
- [ ] Un buffer llamado `a/b` se guarda como `a_b.txt`
- [ ] Sin servidor, el script sale con 1 y avisa por stderr
- [ ] `shellcheck starter/guardar-buffers.sh` no muestra avisos

## Reto extra

Escribe `cargar-buffers.sh DIR`, la operación inversa: un `load-buffer -b`
por cada `.txt` de `DIR`. ¿Qué pasa si cargas dos veces el mismo directorio?
