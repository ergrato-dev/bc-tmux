# Lab 06 — Hooks rotos

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los cinco fallos de una config de hooks, popups y prompts que carga sin errores pero falla al usarla.

## Contexto

- `starter/tmux.conf` es la config de un compañero, rota a propósito. `source-file -n` la acepta: ningún fallo es de sintaxis, todos se ven al usarla.
- Cada paso muestra un síntoma, cómo observarlo y una pista. Arregla solo la línea de ese fallo, recarga y comprueba antes de pasar al siguiente.
- Repasa lo de los labs 01 a 04: índices fijos en los hooks, `-E` en los popups, llaves en las plantillas de `command-prompt`, `-b` en `run-shell`.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux**, las dos desde la raíz del
   repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-06-hooks-rotos
   ```
   En la **terminal A** arranca el servidor como dice
   [Antes de cada lab](../README.md#antes-de-cada-lab) (paso 3) y comprueba
   que la config se lee sin errores:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   tmux -L lab source-file -n "$PWD/starter/tmux.conf"; echo $?
   ```
   ```
   0
   0
   ```
   La terminal B se conecta en el paso 2. El prefix es `C-b`: la config no
   lo cambia.

1. **Fallo 1 — el saludo se multiplica.** Recarga dos veces, como haría
   alguien que retoca la config (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g client-attached
   ```
   ```
   client-attached[0] display-message -d 3000 "hola, #{session_name}"
   client-attached[1] display-message -d 3000 "hola, #{session_name}"
   client-attached[2] display-message -d 3000 "hola, #{session_name}"
   ```
   Tres saludos por cada conexión. **Pista:** lab 01, paso 4. Arréglalo,
   borra las entradas viejas y recarga dos veces:
   ```bash
   tmux -L lab set-hook -gu client-attached; tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g client-attached
   ```
   ```
   client-attached[10] display-message -d 3000 "hola, #{session_name}"
   ```

2. **Fallo 2 — un split que no para.** En la **terminal B**:
   `tmux -L lab attach -t lab`. La barra muestra `hola, lab` 3 s. El
   comentario promete un panel de notas de 5 líneas debajo de cada split:
   un split, tres paneles. En A:
   ```bash
   tmux -L lab split-window -h -d -t lab:; sleep 3; tmux -L lab list-panes -t lab: | wc -l
   ```
   Algo como (depende del alto de B):
   ```
   5
   ```
   B muestra la mitad derecha partida en tiras de 5 líneas, hasta que no
   cupo otra. El hook lanza `tmux split-window` desde una shell; ese `tmux`
   es un cliente nuevo, su split vuelve a disparar el hook, y así sin fin.
   **Pista:** un comando escrito directamente en el hook, sin `run-shell`,
   no dispara hooks; y sin `-t` actúa sobre el panel recién creado (fuera
   de `run-shell`, `-t "#{pane_id}"` no se expande: daría
   `can't find pane: #{pane_id}`). La entrada vieja es `[0]`: bórrala con
   `-u` antes de recargar:
   ```bash
   tmux -L lab set-hook -gu after-split-window; tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show-hooks -g after-split-window
   ```
   ```
   after-split-window[10] split-window -dv -l 5
   ```
   Prueba en una ventana nueva (B pasa a ella):
   ```bash
   tmux -L lab new-window -t lab:; tmux -L lab split-window -h -d; sleep 2
   tmux -L lab list-panes -F '#{pane_index} #{pane_width}x#{pane_height}'
   ```
   Algo como:
   ```
   0 50x29
   1 49x23
   2 49x5
   ```
   Tres paneles: el split y su panel de notas de 5 líneas.

3. **Fallo 3 — un popup que no se va.** En B pulsa `C-b` `u` y sal de `top`
   con `q`: queda un recuadro vacío encima del panel. Ciérralo con
   `Escape`. **Pista:** lab 02, paso 1. Arréglalo y recarga (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix u
   ```
   ```
   bind-key -T prefix u display-popup -E -h "90%" -w "90%" top
   ```
   En B, `C-b` `u` y `q`: `top` y el popup se cierran a la vez.

4. **Fallo 4 — un nombre que ejecuta.** Pon un nombre hostil a la ventana
   actual (terminal A):
   ```bash
   tmux -L lab rename-window 'x"; set -g @pwn si; set -g @z "'
   ```
   ```
   (sin salida)
   ```
   En B pulsa `C-b` `,` y `Enter` sin tocar nada:
   ```bash
   tmux -L lab show -gv @pwn; tmux -L lab display -p "#W"
   ```
   ```
   si
   x
   ```
   **Pista:** lab 03, pasos 4 y 5. Arréglalo, recarga, borra `@pwn` y
   repite:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab set -gu @pwn; tmux -L lab list-keys -T prefix ,
   tmux -L lab rename-window 'x"; set -g @pwn si; set -g @z "'
   ```
   ```
   bind-key -T prefix , command-prompt -I "#W" -p nombre: { rename-window "%%" }
   ```
   En B, `C-b` `,` y `Enter`:
   ```bash
   tmux -L lab show -gv @pwn; tmux -L lab display -p "#W"
   ```
   ```
   invalid option: @pwn
   x"; set -g @pwn si; set -g @z "
   ```

5. **Fallo 5 — un cliente congelado.** En B pulsa `C-b` `b` y enseguida
   `C-b` `c`: la ventana nueva tarda 5 s en aparecer y luego el panel pasa
   al modo vista con `copia hecha` (`q` para salir). El comentario decía
   "sin bloquear nada". **Pista:** lab 04, paso 3. Arréglalo y recarga
   (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix b
   ```
   ```
   bind-key -T prefix b run-shell -b "sleep 5; echo copia hecha"
   ```
   En B, `C-b` `b` y `C-b` `c`: la ventana aparece al instante; a los 5 s,
   `copia hecha` en el modo vista; `q`.

6. **Compara con la solución** (solo las líneas que no son comentarios):
   ```bash
   diff <(grep -v '^#' starter/tmux.conf | grep .) <(grep -v '^#' solucion/tmux.conf | grep .) && echo igual
   ```
   ```
   igual
   ```
   Si `diff` muestra diferencias, revisa ese fallo: hay más de un arreglo
   válido (por ejemplo `"%%%"` en una plantilla de texto en el fallo 4),
   pero comprueba que el tuyo pasa la prueba de su paso.

7. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   B imprime `[server exited]`.

## Criterios de éxito

- [ ] Tras dos recargas, `tmux -L lab show-hooks -g client-attached` muestra una sola entrada (fallo 1)
- [ ] Un `split-window -h` en una ventana nueva deja exactamente tres paneles (fallo 2)
- [ ] Explicas por qué el hook con `run-shell "tmux split-window ..."` se disparaba a sí mismo y el directo no (fallo 2)
- [ ] `C-b` `u` y `q` cierran `top` y el popup a la vez (fallo 3)
- [ ] Con la ventana hostil, `C-b` `,` + `Enter` deja `@pwn` sin crear (fallo 4)
- [ ] `C-b` `b` no retrasa `C-b` `c` (fallo 5)

## Reto extra

Un hook `after-new-window` con `run-shell "tmux new-window -d"` no tendría
el freno que tuvo el fallo 2 (quedarse sin sitio): crearía ventanas sin
fin. Sin probarlo, explica qué freno le pondrías si de verdad necesitaras
un `tmux` dentro de un hook. Pista: una opción `@` que el propio hook pone
y comprueba con `if -F`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — fzf en un popup](../lab-05-fzf-en-un-popup/README.md) | [Proyecto — tmux-kit: popup de proyectos, menú y log de paneles](../../3-proyecto/README.md) → |

[↑ Semana 10](../../README.md)
