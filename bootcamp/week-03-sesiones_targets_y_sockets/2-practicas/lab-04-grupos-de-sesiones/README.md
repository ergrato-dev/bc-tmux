# Lab 04 — Grupos de sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Crear dos sesiones que comparten ventanas pero tienen cada una su ventana actual, y saber cuándo conviene frente a conectar dos clientes a la misma sesión.

## Contexto

- Dos clientes en la **misma sesión** ven siempre la misma ventana: si uno cambia, el otro también.
- Una sesión **agrupada** (`new-session -t BASE`) comparte las ventanas de `BASE`, pero tiene su propia ventana actual. Crear o cerrar una ventana afecta a todo el grupo.
- Sirve para tener la misma sesión en dos monitores mirando ventanas distintas, o para que dos personas trabajen en el mismo proyecto sin pelearse por la ventana activa.

## Instrucciones

0. Abre **tres** terminales **fuera de tmux** (`echo "$TMUX"` no imprime nada
   en ninguna) y colócalas de modo que veas las tres a la vez. En las tres:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-04-grupos-de-sesiones
   ```
   Las **terminales A y B** se conectarán a tmux; la **terminal C** se queda
   fuera para preguntar. El servidor del lab (`-L lab`) arranca con
   `-f /dev/null`, sin configuración: el prefix es `C-b`.

1. **Dos clientes, una sesión.** En la terminal A crea `base` conectada; en la
   C añade una ventana; en la B conéctate a la misma sesión:
   ```bash
   tmux -L lab -f /dev/null new -s base -n codigo   # terminal A
   tmux -L lab new-window -t base: -n logs          # terminal C (sin salida)
   tmux -L lab attach -t =base                      # terminal B
   ```
   Sin `-d`, `new-window` hace actual la ventana nueva: A y B muestran la misma
   barra, `[base] 0:codigo- 1:logs*` (el `*` marca la ventana actual y el `-`
   la anterior). En la terminal B pulsa `C-b` `0`: **las dos** barras pasan a
   `0:codigo* 1:logs-`. Pulsa `C-b` `1` en B: las dos vuelven a `logs`.
   Desconecta la terminal B con `C-b` `d`:
   ```
   [detached (from session base)]
   ```

2. **Un grupo.** En la terminal C crea `copia` en el grupo de `base`; en la B
   conéctate a ella:
   ```bash
   tmux -L lab new -d -t base -s copia; echo $?   # terminal C
   tmux -L lab attach -t =copia                   # terminal B
   ```
   ```
   0
   ```
   En `new-session`, `-t` no es un destino: es la sesión con la que agruparse.
   La barra de B dice `[copia] 0:codigo* 1:logs` y la de A sigue en
   `[base] 0:codigo- 1:logs*`: cada sesión tiene su ventana actual. Pulsa
   `C-b` `1` y `C-b` `0` en B: A no se mueve.

   Ahora crea una ventana en B con `C-b` `c`:
   - B: `[copia] 0:codigo- 1:logs  2:bash*`
   - A: `[base] 0:codigo- 1:logs* 2:bash`

   La ventana nueva aparece en las dos sesiones (`bash` o `zsh`, según tu
   shell).

3. **Las mismas ventanas, no copias.** En la terminal C:
   ```bash
   tmux -L lab ls -F '#{session_name} grupo=#{session_group} miembros=#{session_group_list}'
   tmux -L lab list-windows -t copia: -F '#{window_index} #{window_name} #{window_id}'
   tmux -L lab list-windows -t base: -F '#{window_index} #{window_name} #{window_id}'
   ```
   ```
   base grupo=base miembros=base,copia
   copia grupo=base miembros=base,copia
   0 codigo @0
   1 logs @1
   2 bash @3
   0 codigo @0
   1 logs @1
   2 bash @3
   ```
   (Algo como: el id de la tercera ventana puede ser otro.) Los ids de ventana
   (`@N`) son los mismos en las dos sesiones: son las mismas ventanas.

4. **Lo que se comparte y lo que no.** En la terminal B (estás en la ventana
   2 de `copia`) pulsa `C-b` `&`. Abajo aparece:
   ```
   kill-window bash? (y/n)
   ```
   Responde `y`. La ventana desaparece de las dos barras:
   - B: `[copia] 0:codigo* 1:logs-`
   - A: `[base] 0:codigo- 1:logs*`

   Ahora cierra la sesión `copia` entera desde la terminal C:
   ```bash
   tmux -L lab kill-session -t =copia
   ```
   ```
   (sin salida)
   ```
   La terminal B sale de tmux con `[exited]`. La A sigue en `base` con sus dos
   ventanas: cerrar una sesión del grupo no cierra las ventanas que siguen en
   otra.

5. **Tamaño.** Haz la ventana de la terminal B claramente más pequeña que la
   de A (arrastra su borde). En la terminal B conéctate a `base`, la misma
   sesión que A, y en la C mira los tamaños:
   ```bash
   tmux -L lab attach -t =base                                                                     # terminal B
   tmux -L lab list-clients -F '#{client_name} #{client_width}x#{client_height} #{session_name}'   # terminal C
   tmux -L lab list-windows -t base: -F '#{window_index} #{window_name} #{window_width}x#{window_height}'
   ```
   ```
   /dev/pts/0 100x30 base
   /dev/pts/1 80x20 base
   0 codigo 80x19
   1 logs 80x19
   ```
   (Algo como: los números son los de tus terminales; la altura de la ventana
   es la del cliente menos la barra de estado.) Las dos terminales miran
   `logs`, y la ventana tiene el tamaño de B, el último cliente que se usó
   (`window-size latest`). Ahora pulsa `Enter` en la terminal A y repite el
   `list-windows` en la C:
   ```
   0 codigo 80x19
   1 logs 100x29
   ```
   `logs` toma el tamaño de A, y B ve la ventana recortada. Con un grupo, cada
   terminal mira su propia ventana y cada una se ve a su tamaño.

6. **El escenario de `starter/mirror.sh`.** El script crea, si no existe, una
   sesión `BASE-espejo` en el grupo de `BASE` y muestra los miembros. En la
   terminal C reinicia el servidor: **A y B salen de tmux** con
   `[server exited]`.
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f /dev/null new -d -s base
   ./starter/mirror.sh base; echo $?
   ```
   ```
   mirror.sh: sin implementar (base, base-espejo)
   0
   ```
   Abre `starter/mirror.sh` con tu editor y borra la línea
   `echo "mirror.sh: sin implementar ..."`. El resto del lab se hace en la
   terminal C.

7. **TODO 1: la base existe.** Pista:
   `if ! tmx has-session -t "=$base" 2>/dev/null; then`, con
   `echo "no existe la sesión '$base'" >&2` y `exit 1` dentro. Prueba:
   ```bash
   ./starter/mirror.sh nada; echo $?
   ```
   ```
   no existe la sesión 'nada'
   1
   ```

8. **TODO 2: crear solo si falta.** Si `tmx has-session -t "=$mirror"` sale
   con 0, `echo "ya existe: $mirror"`; si no,
   `tmx new-session -d -t "=$base" -s "$mirror"` y
   `echo "creada: $mirror"`. Comprobar antes de crear es lo que hace el script
   **idempotente**: ejecutarlo dos veces deja lo mismo que una. Prueba:
   ```bash
   ./starter/mirror.sh base
   ./starter/mirror.sh base
   ```
   ```
   creada: base-espejo
   ya existe: base-espejo
   ```

9. **TODO 3: mostrar el grupo.** Al final, imprime el grupo y sus miembros con
   `display-message` sobre la base:
   ```bash
   tmx display-message -p -t "=$base:" 'grupo #{session_group}: #{session_group_list}'
   ```
   Fíjate en los `:` finales de `"=$base:"`: `display-message` espera un panel,
   y con `-t "=base"` a secas deja los campos vacíos (imprime `grupo :`).
   Prueba desde cero:
   ```bash
   tmux -L lab kill-session -t =base-espejo
   ./starter/mirror.sh base
   ./starter/mirror.sh base
   ```
   ```
   creada: base-espejo
   grupo base: base,base-espejo
   ya existe: base-espejo
   grupo base: base,base-espejo
   ```

10. Limpia:
    ```bash
    tmux -L lab kill-server
    ```
    ```
    (sin salida)
    ```

## Criterios de éxito

- [ ] Con dos clientes en la misma sesión, cambiar de ventana en uno cambió el otro (paso 1)
- [ ] Con un grupo, cada cliente miró su ventana y la ventana nueva apareció en las dos sesiones (paso 2)
- [ ] Mostraste con `#{window_id}` que las ventanas son las mismas (paso 3)
- [ ] Explicas qué tamaño toma una ventana que miran dos clientes (paso 5)
- [ ] `mirror.sh base` dos veces imprime las cuatro líneas del paso 9

## Reto extra

¿Qué pasa con el grupo si cierras `base` y dejas `base-espejo`? Compruébalo
con `#{session_group}` y `#{session_group_list}`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Moverte entre sesiones](../lab-03-moverte-entre-sesiones/README.md) | [Lab 05 — Sockets y la variable TMUX](../lab-05-sockets-y-la-variable-tmux/README.md) → |

[↑ Semana 03](../../README.md)
