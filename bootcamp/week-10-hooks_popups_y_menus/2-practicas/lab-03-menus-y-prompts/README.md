# Lab 03 — Menús y prompts

⏱ Duración estimada: ~60 min

## Objetivo

Construir un menú, un prompt y una confirmación propios, y comprobar que un nombre con comillas no ejecuta comandos a través del prompt.

## Contexto

- `display-menu` muestra entradas `"Nombre" tecla comando`; `""` es un separador. `command-prompt` pide texto y lo pone en la plantilla en lugar de `%%` (o `%1`, `%2` con varios `-p`); `confirm-before` pide `y`/`n`.
- Si la plantilla es **texto entre comillas**, tmux pega lo escrito y vuelve a leer el comando: unas comillas en lo escrito cierran el argumento y lo de detrás se ejecuta. Si la plantilla va **entre llaves** `{ }`, lo escrito queda como valor del argumento. Con texto, `"%%%"` escapa las comillas; entre llaves basta `"%%"` (con `"%%%"` aparecerían barras `\`).
- Los tres esperan a que respondas en el cliente conectado: lánzalos desde A y responde en B.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux**, las dos desde la raíz del
   repositorio:
   ```bash
   cd bootcamp/week-10-hooks_popups_y_menus/2-practicas/lab-03-menus-y-prompts
   ```
   En la **terminal A** arranca el servidor como dice
   [Antes de cada lab](../README.md#antes-de-cada-lab) (paso 3):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   ```
   ```
   0
   ```
   En la **terminal B**: `tmux -L lab attach -t lab`. El prefix es `C-b`: el
   starter no lo cambia.

1. **Un menú desde A:**
   ```bash
   tmux -L lab display-menu -T ' prueba ' -x C -y C 'Nueva ventana' n new-window '' 'Mensaje' m 'display-message hola'; echo $?
   ```
   En B aparece en el centro un menú ` prueba ` con `Nueva ventana (n)`, una
   línea y `Mensaje (m)`. Pulsa `n` en B: se crea una ventana, el menú se
   cierra y A imprime `0`:
   ```bash
   tmux -L lab list-windows -F '#{window_index} #{window_name}'
   ```
   Algo como (el nombre es tu shell):
   ```
   0 bash
   1 bash
   ```
   Lánzalo otra vez y pulsa `q` (o `Escape`) en B: se cierra sin hacer nada.
   También puedes moverte con las flechas y elegir con `Enter`.

2. **Un prompt, uno o dos valores.** `-I` rellena el texto inicial; `%1` y
   `%2` reciben cada respuesta de `-p 'a:,b:'`:
   ```bash
   tmux -L lab command-prompt -I notas -p 'nombre:' 'set -g @lab-name "%%"'
   tmux -L lab show -gv @lab-name
   ```
   En B la línea de abajo muestra `nombre: notas`; pulsa `Enter`. A imprime:
   ```
   notas
   ```
   ```bash
   tmux -L lab command-prompt -p 'origen:,destino:' 'set -g @lab-name "%1 -> %2"'
   tmux -L lab show -gv @lab-name
   ```
   En B escribe `api` `Enter` y luego `web` `Enter`. A imprime:
   ```
   api -> web
   ```

3. **Unas comillas que ejecutan.** La plantilla es texto (comillas simples
   para la shell de A):
   ```bash
   tmux -L lab command-prompt -p 'nombre:' 'set -g @lab-name "%%"'
   tmux -L lab show -gv @lab-name; tmux -L lab show -gv @pwn
   ```
   En B escribe (o pega) exactamente `x"; set -g @pwn si; set -g @z "` y
   pulsa `Enter`. A imprime:
   ```
   x
   si
   ```
   Las comillas cerraron el valor tras `x` y `set -g @pwn si` se ejecutó.
   Repite con `"%%%"`:
   ```bash
   tmux -L lab set -gu @pwn
   tmux -L lab command-prompt -p 'nombre:' 'set -g @lab-name "%%%"'
   tmux -L lab show -gv @lab-name; tmux -L lab show -gv @pwn
   ```
   Escribe lo mismo en B y `Enter`. A imprime:
   ```
   x"; set -g @pwn si; set -g @z "
   invalid option: @pwn
   ```
   `invalid option` es la buena noticia: `@pwn` no existe.

4. **El `prefix` `,` del starter.** Compáralo con el de serie
   (`command-prompt -I "#W" { rename-window "%%" }`, entre llaves):
   ```bash
   tmux -L lab list-keys -T prefix ,
   ```
   ```
   bind-key -T prefix , command-prompt -I "#W" -p nombre: "rename-window -- \"%%\""
   ```
   Texto, no llaves. No hace falta escribir nada raro: basta un nombre de
   ventana hostil y `Enter` (`-I "#W"` lo pone en el prompt):
   ```bash
   tmux -L lab new-window -n 'x"; set -g @pwn si; set -g @z "'; tmux -L lab display -p '#W'
   ```
   ```
   x"; set -g @pwn si; set -g @z "
   ```
   En B pulsa `C-b` `,`: el prompt muestra `nombre: x"; set -g @pwn si; set -g @z "`.
   Pulsa `Enter` y mira en A:
   ```bash
   tmux -L lab show -gv @pwn; tmux -L lab display -p "#W"
   ```
   ```
   si
   x
   ```
   Un programa puede ponerle nombre a una ventana; el nombre ejecutó un
   comando en cuanto aceptaste el prompt.

5. **TODO 2 — llaves.** En `starter/tmux.conf` borra la línea
   `bind , command-prompt ... 'rename-window -- "%%"'` y quita el `#   ` de
   la de llaves que hay en el comentario. Recarga y repite (terminal A):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix ,
   tmux -L lab set -gu @pwn; tmux -L lab rename-window 'x"; set -g @pwn si; set -g @z "'
   ```
   ```
   bind-key -T prefix , command-prompt -I "#W" -p nombre: { rename-window "%%" }
   ```
   (`list-keys` no muestra el `--`, pero sigue ahí.) En B pulsa `C-b` `,` y
   `Enter`:
   ```bash
   tmux -L lab show -gv @pwn; tmux -L lab display -p "#W"
   ```
   ```
   invalid option: @pwn
   x"; set -g @pwn si; set -g @z "
   ```
   El nombre sigue siendo un nombre. Para un texto en `run-shell`, ni las
   llaves ni `%%%` bastan: lo escrito llega a una shell, y `$(...)` se
   ejecutaría.

6. **TODO 1 — el menú en `prefix` `K`.** Quita el `#   ` de las seis líneas
   de `bind K display-menu ...` (la `\` final une cada línea con la
   siguiente). La entrada `r` anida un prompt entre llaves, con `"%%"`:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix K
   ```
   ```
   bind-key -T prefix K display-menu -T " lab " -x C -y C "Nueva ventana" n new-window "Dividir en vertical" v "split-window -h" '' "Renombrar ventana" r { command-prompt -p nombre: { rename-window "%%" } } "Cerrar ventana" x { confirm-before -p "cerrar la ventana? (y/n)" kill-window }
   ```
   En B:
   - `C-b` `K` y `v`: la ventana se divide en dos paneles.
   - `C-b` `K` y `r`: escribe `web` y `Enter`; la barra muestra `web`.
   - `C-b` `K` y `x`: la línea de abajo pregunta `cerrar la ventana? (y/n)`;
     pulsa `n` y no se cierra.
   - `C-b` `K` y `Escape`: el menú se cierra.

   ```bash
   tmux -L lab list-panes | wc -l; tmux -L lab display -p "#W"
   ```
   ```
   2
   web
   ```

7. **TODO 3 — `prefix` `k` con confirmación.** Quita el `#   ` de la línea
   `bind k confirm-before ...` y recarga:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; tmux -L lab list-keys -T prefix k
   tmux -L lab list-windows -F '#{window_index} #{window_name} #{window_active}'
   ```
   Algo como:
   ```
   bind-key -T prefix k confirm-before -p "cerrar las demás ventanas? (y/n)" "kill-window -a"
   0 bash 0
   1 bash 0
   2 web 1
   ```
   En B pulsa `C-b` `k` y `n`: no cambia nada. Pulsa `C-b` `k` y `y`:
   ```bash
   tmux -L lab list-windows -F '#{window_index} #{window_name}'
   ```
   ```
   2 web
   ```

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   ```
   B imprime `[server exited]`.

## Criterios de éxito

- [ ] El menú del paso 1 crea una ventana con `n` y se cierra sin hacer nada con `q`
- [ ] Explicas, con la salida del paso 3, por qué `"%%"` en una plantilla de texto ejecutó `set -g @pwn si` y `"%%%"` no
- [ ] Tras el TODO 2, `C-b` `,` + `Enter` sobre la ventana hostil deja `tmux -L lab show -gv @pwn` en `invalid option: @pwn` (paso 5)
- [ ] `tmux -L lab list-keys -T prefix K` muestra el menú y sus entradas `v`, `r` y `x` funcionan (paso 6)
- [ ] `C-b` `k` + `y` deja una sola ventana (paso 7)

## Reto extra

Las entradas del menú se expanden como format **al abrirlo**. Añade una
entrada `"Ventana #W" w "display-message 'eras #W'"`, abre el menú, cierra
con `Escape`, renombra la ventana y vuelve a abrirlo. ¿Qué pasaría si `#W`
tuviera comillas? Arréglalo sin `#W` en el comando.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — Popups](../lab-02-popups/README.md) | [Lab 04 — run-shell y pipe-pane](../lab-04-run-shell-y-pipe-pane/README.md) → |

[↑ Semana 10](../../README.md)
