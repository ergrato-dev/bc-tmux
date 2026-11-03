# Lab 06 — Status line rota

⏱ Duración estimada: ~60 min

## Objetivo

Depurar una status line con cinco errores de formats, usando solo `source-file`, `show -gv` y `display -p '#{E:...}'`.

## Contexto

- `starter/tmux.conf` es la barra de un compañero y está **rota a propósito**. Su cabecera dice lo que quería que hiciera; este README te da los síntomas. No hay TODOs.
- Un format mal escrito casi nunca da error: dibuja otra cosa. El método es siempre el mismo: aislar la opción con `show -gv`, expandirla con `display -p '#{E:opción}'` y comparar con lo que esperabas.
- Arregla un error cada vez y recarga. Si dudas de lo que ves, `solucion/tmux.conf` es la referencia, pero ábrela solo al final.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-06-status-rota
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**. Necesitas `git` (`sudo apt install git` / `brew install git`).

1. **Un repo con espacio en el nombre** y el servidor (terminal A):
   ```bash
   R="$(mktemp -d)/mi repo"; git init -q -b main "$R"
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api -c "$R"; echo $?
   ```
   ```
   0
   ```
   El servidor arranca aunque la config tenga errores. En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   Lo primero que ves no es la shell, sino el error de la config, algo
   como:
   ```
   /ruta/a/lab-06-status-rota/starter/tmux.conf:19: invalid option: window-status-curent-format
   ```
   Pulsa `q` para cerrar ese aviso. La barra, algo como:
   ```
   [api] bg=c0:bash*                                   bc-tmux-laboy: 03/11 02:02
   ```
   Deja la B conectada.

2. **Los síntomas.** Compáralos con lo que quería el compañero (cabecera
   del starter):

   | # | Síntoma | Dónde mirar |
   |---|---------|-------------|
   | 1 | Error `invalid option` al arrancar; la ventana actual no sale entre corchetes | `source-file` |
   | 2 | `bg=c` en la izquierda sin pulsar nada; con `C-b` pulsado, no sale `PREFIX` | `status-left` |
   | 3 | (Tras arreglar el 2) con `C-b` pulsado sale ` PRE` y la lista de ventanas pegada | `status-left-length` |
   | 4 | No sale la rama `main`, aunque el panel está en un repo | `status-right`, el `#()` |
   | 5 | Sale `bc-tmux-laboy:` (tu host + `oy`) donde debería decir `#hoy:` | `status-right` |

   Tras cada arreglo: guarda, `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?`
   en la A y mira la B.

3. **Error 1: el que sí avisa.** En la terminal A:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab show -gv window-status-current-format
   ```
   Algo como:
   ```
   /ruta/a/lab-06-status-rota/starter/tmux.conf:19: invalid option: window-status-curent-format
   invalid option: window-status-curent-format
   1
   #I:#W#{?window_flags,#{window_flags}, }
   ```
   Te da la línea. La opción buena sigue con su valor por defecto: la línea
   mala no la tocó. tmux **sigue** con las líneas siguientes, por eso el
   resto de la barra sí cambió. Arréglalo (es una errata en el nombre):
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   ```
   ```
   0
   ```
   La ventana actual de la B pasa a `[0:bash]`. `source-file -n` solo comprueba la sintaxis de
   los comandos: no habría encontrado este error (sale con 0).

4. **Error 2: `bg=c`.** Expande la izquierda:
   ```bash
   tmux -L lab show -gv status-left
   tmux -L lab display -p '[#{E:status-left}]'
   ```
   Con el starter sin arreglar:
   ```
   [#{session_name}] #{?client_prefix,#[fg=colour235,bg=colour203,bold] PREFIX #[default],}
   [[api] bg=colour203,bold] PREFIX #[default],]
   ```
   Cuenta las comas del condicional: tmux ve la rama verdadera
   `#[fg=colour235` (un estilo sin cerrar, que no dibuja nada) y toma el
   resto como rama falsa, que es lo que sale sin el prefix. La barra corta
   ese texto en `bg=c` por el error 3. Pista: en una rama, la coma del
   estilo se escribe `#,`. Arreglado:
   ```bash
   tmux -L lab display -p '[#{E:status-left}]'
   ```
   ```
   [[api] ]
   ```

5. **Error 3: ` PRE`.** En la B pulsa `C-b` y nada más: la izquierda pasa a
   `[api]  PRE` y la lista de ventanas va pegada. En la A, sin pulsar nada
   en la B:
   ```bash
   tmux -L lab display -p '[#{E:status-left}]'
   tmux -L lab show -gv status-left-length
   ```
   ```
   [[api] #[fg=colour235,bg=colour203,bold] PREFIX #[default]]
   10
   ```
   El format está bien; la barra lo corta a 10 columnas (`[api] ` y
   ` PRE` suman 10). Pulsa `Escape` en la B. Pista: una línea
   `set -g status-left-length 30` antes de `status-left`. Tras recargar,
   `C-b` en la B muestra ` PREFIX ` entero, en rojo.

6. **Error 4: sin rama.** `display -p` no ejecuta `#()`: copia el comando a
   mano, con la ruta que tmux le pasaría (terminal A):
   ```bash
   tmux -L lab display -p '#{pane_current_path}'
   git -C $R symbolic-ref --short HEAD; echo $?
   ```
   Algo como:
   ```
   /tmp/tmp.I5TITEAoBX/mi repo
   fatal: cannot change to '/tmp/tmp.I5TITEAoBX/mi': No such file or directory
   128
   ```
   Sin comillas (como en el `#()` del compañero), la shell parte la ruta en
   el espacio. El error va a la salida de errores del `#()`, no a la barra:
   la barra solo se queda sin rama. Pista: `#{q:pane_current_path}`. Tras
   recargar, la B muestra `main` en ≤ 15 s.

7. **Error 5: `bc-tmux-laboy:`.**
   ```bash
   tmux -L lab display -p '[#{E:status-right}]'
   ```
   Con el error 4 ya arreglado, algo como:
   ```
   [ bc-tmux-laboy: 03/11 02:02 ]
   ```
   `#h` es el atajo de `host_short`, así que `#hoy` es el host seguido de
   `oy`. Pista: un `#` literal se escribe `##`. Arreglado:
   ```
   [ #hoy: 03/11 02:02 ]
   ```
   (el hueco del principio es el `#()`, que `display -p` deja vacío). La B
   termina en `main #hoy: 03/11 02:02`.

8. **Compara con la solución.**
   ```bash
   diff starter/tmux.conf solucion/tmux.conf
   ```
   Las diferencias que quedan tienen que ser solo comentarios (y quizá el
   sitio de `status-left-length`).

9. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?` imprime solo `0` (paso 3)
- [ ] `tmux -L lab display -p '[#{E:status-left}]'` imprime `[[api] ]` sin el prefix pulsado (paso 4)
- [ ] Con `C-b` pulsado, la B muestra ` PREFIX ` entero y en rojo (paso 5)
- [ ] La B muestra `main` con el panel en `mi repo` (paso 6)
- [ ] `tmux -L lab display -p '[#{E:status-right}]'` contiene `#hoy:` (paso 7)
- [ ] Para cada uno de los cinco errores, escribes en tus notas el síntoma, la herramienta que lo encontró y por qué no daba error (o por qué sí)

## Reto extra

Rompe tú una barra para otra persona: un estilo que no se cierra con
`#[default]` dentro de `status-right` (el color sigue hasta el final de ese
lado, pero no pasa a la lista de ventanas) y un `#{=5:...}` que corta un
nombre a la mitad. Pásale tu `tmux.conf` y solo la lista de síntomas.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — Comandos en la barra y varias líneas](../lab-05-comandos-y-varias-lineas/README.md) | [Proyecto — tmux-kit: status line propia, sin plugins](../../3-proyecto/README.md) → |

[↑ Semana 07](../../README.md)
