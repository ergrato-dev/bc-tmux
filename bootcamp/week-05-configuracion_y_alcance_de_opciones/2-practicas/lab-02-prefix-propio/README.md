# Lab 02 — Un prefix propio

⏱ Duración estimada: ~60 min

## Objetivo

Cambiar el prefix de tmux por uno elegido con criterio, liberar `C-b` y mantener la forma de enviar el prefix al programa del panel.

## Contexto

- `C-b` choca con atajos que usas a diario: en bash mueve el cursor un carácter atrás, en vim y en `less` sube una página.
- `prefix` es una opción de **sesión**: se fija con `-g` para todas. La tecla que lo "reenvía" al panel es un binding aparte en la tabla `prefix`: `send-prefix`.
- Desde esta semana, el bootcamp escribe `prefix` y no `C-b`: cada uno usa el suyo.

## Instrucciones

1. **Lo que hay ahora.**
   ```bash
   tmux -L lab -f /dev/null new -d \; show -gv prefix \; list-keys -T prefix C-b
   tmux -L lab kill-server
   ```
   ```
   C-b
   bind-key -T prefix C-b send-prefix
   ```
   El prefix es la tecla que abre la tabla `prefix`; `C-b` **dentro** de esa
   tabla es otro binding: el que envía un `C-b` real al panel.

2. **Elige.** Ninguno es perfecto:

   | Prefix | A favor | En contra |
   |---|---|---|
   | `C-a` | Cómodo con Caps Lock como Ctrl; el de screen | En bash es "inicio de línea": `prefix` `C-a` |
   | `C-Space` | Casi nada lo usa | Algunas terminales y sistemas (cambio de idioma) lo capturan |
   | `C-s` | Cómodo | Es XOFF: sin `stty -ixon`, la terminal se congela hasta `C-q` |
   | `` ` `` (backtick) | Una sola tecla | Lo escribes en markdown y en shell a menudo |

   Escribe tu elección y el motivo en el comentario del `TODO 1`.

3. **Cámbialo.** Resuelve los tres `TODO` de `starter/tmux.conf` y comprueba
   (con tu prefix en lugar de `C-a`):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s principal
   tmux -L lab show -gv prefix
   tmux -L lab list-keys -T prefix C-a
   tmux -L lab list-keys -T prefix C-b
   ```
   ```
   C-a
   bind-key -T prefix C-a send-prefix
   unknown key: C-b
   ```

4. **Úsalo.** Conéctate (`tmux -L lab attach`) y prueba:
   - `prefix` `c` abre una ventana; `C-b` `c` escribe `c` en el panel.
   - Escribe `echo hola` sin pulsar `Enter` y pulsa `prefix` `C-a` (dos veces
     tu prefix): el cursor salta al inicio de la línea. Era un `C-a` para
     bash.

5. **Dos prefixes a la vez.** Mientras te acostumbras, puedes dejar `C-b`
   como segundo prefix:
   ```bash
   tmux -L lab set -g prefix2 C-b
   ```
   `C-b` `c` vuelve a abrir una ventana. Quítalo con
   `tmux -L lab set -gu prefix2` cuando ya no lo necesites: dos prefixes son
   dos teclas robadas a tus programas.

6. **Solo una sesión.** `prefix` es de sesión: puedes darle otro a una sola.
   ```bash
   tmux -L lab new -d -s anidada
   tmux -L lab set -t anidada prefix C-b
   tmux -L lab show -A -t anidada prefix
   tmux -L lab show -A -t principal prefix
   ```
   ```
   prefix C-b
   prefix* C-a
   ```
   El `*` marca el valor heredado del global. Lo usarás en la semana 12 para
   tmux dentro de tmux.

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] `tmux -L lab show -gv prefix` imprime tu prefix, que no es `C-b`
- [ ] `tmux -L lab list-keys -T prefix TU-PREFIX` muestra `send-prefix`
- [ ] `tmux -L lab list-keys -T prefix C-b` dice `unknown key: C-b`
- [ ] El comentario de tu `tmux.conf` explica por qué elegiste ese prefix y qué pierdes
- [ ] Explicas la diferencia entre el `C-b` del paso 1 y el prefix

## Reto extra

El estilo de screen: `prefix` `a` envía el prefix y `prefix` `C-a` salta a la
última ventana (`last-window`). Configúralo. ¿Qué ganas y qué pierdes?
