# Lab 04 — Recarga en caliente

⏱ Duración estimada: ~60 min

## Objetivo

Recargar la config con `prefix` `r` sin cerrar nada y escribirla de forma que recargar dos veces dé el mismo resultado, comprobándolo con un script.

## Contexto

- `source-file` ejecuta la config **encima** del estado actual: no vuelve a los valores por defecto antes.
- Por eso, lo que borras de la config sigue activo, y lo que añades con `-a` se añade otra vez en cada recarga.
- Una config está bien escrita si recargarla diez veces deja lo mismo que recargarla una.

## Instrucciones

1. Arranca con el starter (ruta absoluta: `@lab-dir` sale de ella) y mira
   qué hace hoy `prefix` `r`:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d
   tmux -L lab list-keys -T prefix r
   ```
   ```
   bind-key -T prefix r refresh-client
   ```
   Por defecto, `r` vuelve a dibujar la pantalla. No recarga nada.

2. **La tecla.** Resuelve el `TODO 1`:
   ```tmux
   bind r source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```
   `-F` expande `#{@lab-dir}` **al pulsar** la tecla, así que funciona estés
   en el directorio que estés. Carga el cambio a mano una vez y prueba la
   tecla desde un cliente:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab attach
   ```
   `prefix` `r` muestra `config recargada` en la barra. Si `source-file` no
   encuentra el archivo, el `display` ya no se ejecuta: no ver el mensaje es
   el aviso. Los errores **dentro** del archivo, en cambio, aparecen en el
   panel y el mensaje sale igual.

3. **Borrar no deshace.** Quita la línea `set -g status-position top` del
   starter, guarda y pulsa `prefix` `r`. La barra sigue arriba:
   ```bash
   tmux -L lab show -gv status-position      # top
   ```
   Nadie volvió a poner `bottom`. Para deshacerlo sin reiniciar:
   ```bash
   tmux -L lab set -gu status-position       # vuelve al valor por defecto
   ```
   Lo mismo con las teclas: borrar un `bind` de la config deja la tecla
   puesta hasta un `unbind` o un `kill-server`.

4. **Añadir se acumula.** Pulsa `prefix` `r` tres veces y mira la lista:
   ```bash
   tmux -L lab show -g update-environment | tail -4
   ```
   ```
   update-environment[7] XAUTHORITY
   update-environment[8] WAYLAND_DISPLAY
   update-environment[9] WAYLAND_DISPLAY
   update-environment[10] WAYLAND_DISPLAY
   ```
   Cada recarga ejecuta `set -ga` otra vez. Arréglalo para que la línea dé el
   mismo resultado siempre: devuelve la lista a su valor por defecto y añade
   después.
   ```tmux
   set -gu update-environment
   set -ga update-environment WAYLAND_DISPLAY
   ```
   Recarga tres veces más: un solo `WAYLAND_DISPLAY`.

5. **Comprobarlo con un script.** Completa `starter/comparar-recarga.sh`:
   recarga dos veces, compara el estado de las dos y enseña la diferencia.
   Pruébalo primero con la versión rota del paso 4 (vuelve a dejar solo el
   `set -ga`) y después con la arreglada:
   ```bash
   ./starter/comparar-recarga.sh "$PWD/starter/tmux.conf"; echo $?
   ```
   ```
   80a81
   > update-environment[10] WAYLAND_DISPLAY
   1
   ```
   ```
   idéntico: recargar /ruta/a/starter/tmux.conf no cambia nada
   0
   ```
   El autograding del proyecto hace la misma comprobación con tu kit.

6. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] `tmux -L lab list-keys -T prefix r` muestra `source-file -F` con `@lab-dir`
- [ ] `prefix` `r` muestra `config recargada` aunque hayas arrancado tmux desde otro directorio
- [ ] Explicas por qué la barra seguía arriba en el paso 3 y lo deshaces sin reiniciar
- [ ] Tras cinco recargas, `show -g update-environment` tiene un solo `WAYLAND_DISPLAY`
- [ ] `comparar-recarga.sh` sale con 1 y muestra la línea repetida en la config rota, y con 0 en la arreglada
- [ ] `shellcheck starter/comparar-recarga.sh` no muestra avisos

## Reto extra

Tras varias recargas seguidas no sabes si el mensaje es el de ahora o el de
antes. Haz que diga la hora: `display` interpreta los formatos de `strftime`,
como `%H:%M:%S`. Añade también cuántas sesiones hay, con un formato de
tmux (`#{server_sessions}`).
