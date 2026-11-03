# Lab 02 — Condicionales y comparaciones

⏱ Duración estimada: ~60 min

## Objetivo

Construir indicadores de barra que solo aparecen cuando toca (prefix pulsado, zoom, sesión de producción, muchos paneles) con `#{?...}`, comparaciones y patrones.

## Contexto

- `#{?cond,sí,no}` elige una rama. La condición es verdadera si no está vacía y no es `0`.
- Las comparaciones devuelven `1` o `0`: `#{==:a,b}`, `#{!=:a,b}`, `#{m:patrón,texto}` (glob, como en la shell), `#{||:a,b}`, `#{&&:a,b}`. `#{<:a,b}` y compañía comparan **texto**; para números, `#{e|<|:a,b}`.
- La coma separa las ramas: una coma que quieres ver se escribe `#,`. En tmux 3.4 no hay operador de negación: se niega con `#{==:x,0}` o invirtiendo las ramas.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-02-condicionales-y-comparaciones
   ```
   El servidor es `-L lab`. Ni `-f /dev/null` ni el starter cambian el
   prefix: en este lab es **`C-b`**.

1. **Condiciones a mano** (terminal A):
   ```bash
   tmux -L lab -f /dev/null new -d -s api
   tmux -L lab set -g @x hola
   tmux -L lab set -g @cero 0
   tmux -L lab display -p '#{?@x,si,no} #{?@nada,si,no} #{?@cero,si,no}'
   tmux -L lab display -p '#{==:#{@x},hola} #{!=:#{@x},hola} #{m:h*,#{@x}} #{m:*ap*,#{@x}}'
   tmux -L lab display -p '#{?#{==:#{@x},hola},saludo,otra cosa}'
   tmux -L lab display -p '#{||:0,1} #{&&:1,0} #{&&:1,#{@x}}'
   ```
   ```
   si no no
   1 0 1 0
   saludo
   1 0 1
   ```
   Una opción vacía, inexistente o `0` es falsa; cualquier otro texto,
   verdadero.

2. **Texto contra número.**
   ```bash
   tmux -L lab display -p 'texto: #{<:10,9}  numeros: #{e|<|:10,9}'
   ```
   ```
   texto: 1  numeros: 0
   ```
   Como texto, `"10"` va antes que `"9"` (compara el `1` con el `9`). Para
   contar paneles o ventanas, siempre `e|`.

3. **Negar y escapar comas.**
   ```bash
   tmux -L lab display -p '[#{!:0}] [#{==:#{@cero},0}] [#{?@cero,0,1}]'
   tmux -L lab display -p '[#{?@x,a,b,c}] [#{?@x,a#,b,c}]'
   tmux -L lab display -p '[#{?client_prefix,P,-}]'
   tmux -L lab kill-server
   ```
   ```
   [] [1] [1]
   [a] [a,b]
   [-]
   ```
   `#{!:0}` no existe en 3.4: se expande a vacío, sin error. Sin `#,`, la
   rama verdadera es solo `a`. Y sin cliente conectado nadie ha pulsado el
   prefix: `client_prefix` es `0`.

4. **Arranca con el starter** (terminal A). La derecha ya junta cinco
   opciones vacías y la hora:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api; echo $?
   tmux -L lab display -p '[#{E:status-right}]'
   ```
   Algo como (la hora es la tuya):
   ```
   0
   [01:58 ]
   ```
   En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   La barra termina en la hora. Deja la B conectada.

5. **Los TODOs de `starter/tmux.conf`.** Tras cada uno, en la terminal A:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"` (sin salida).

   1. **TODO 1: PREFIX.** Pista:
      `set -g @lab-prefix '#{?client_prefix,PREFIX ,}'`.
      ```bash
      tmux -L lab display -p '[#{E:@lab-prefix}]'
      ```
      ```
      []
      ```
      En la B pulsa `C-b` y nada más: la barra muestra `PREFIX 01:58`. Sin
      pulsar otra tecla en la B, en la A:
      ```bash
      tmux -L lab display -p '[#{E:@lab-prefix}] #{client_key_table}'
      ```
      ```
      [PREFIX ] prefix
      ```
      En la B pulsa `Escape` (tarda medio segundo): `PREFIX` desaparece y
      el mismo comando imprime `[] root`. `client_prefix` vale `1` en
      **cualquier** tabla que no sea `root`, también en una tabla propia
      como el modo resize de la semana 06.
   2. **TODO 2: ZOOM.** Pista:
      `set -g @lab-zoom '#{?window_zoomed_flag,ZOOM ,}'`. Un panel solo no
      se amplía: parte la ventana primero.
      ```bash
      tmux -L lab split-window -h
      tmux -L lab resize-pane -Z
      tmux -L lab display -p '[#{E:@lab-zoom}] #{window_zoomed_flag} #{window_flags}'
      ```
      ```
      [ZOOM ] 1 *Z
      ```
      La B muestra `0:bash*Z` y `ZOOM` a la derecha. `Z` es el flag de
      tmux; `ZOOM` se lee sin conocerlo. Quita el zoom (terminal A):
      ```bash
      tmux -L lab resize-pane -Z
      tmux -L lab display -p '[#{E:@lab-zoom}]'
      ```
      ```
      []
      ```
   3. **TODO 3: PROD.** Pista:
      `set -g @lab-env '#{?#{m:*-prod,#{session_name}},PROD ,}'`.
      ```bash
      tmux -L lab display -p '[#{E:@lab-env}]'
      tmux -L lab rename-session api-prod
      tmux -L lab display -p '[#{E:@lab-env}]'
      tmux -L lab rename-session api
      ```
      ```
      []
      [PROD ]
      ```
   4. **TODO 4: muchos paneles.** Pista:
      `set -g @lab-panes '#{?#{e|>=|:#{window_panes},3},#{window_panes} paneles#, ventana #{window_index} ,}'`.
      ```bash
      tmux -L lab display -p '[#{E:@lab-panes}] #{window_panes}'
      tmux -L lab split-window -v
      tmux -L lab display -p '[#{E:@lab-panes}]'
      ```
      ```
      [] 2
      [3 paneles, ventana 0 ]
      ```
      Ahora rómpelo a propósito: la misma opción con `,` en lugar de `#,`
      (terminal A):
      ```bash
      tmux -L lab set -g @lab-panes '#{?#{e|>=|:#{window_panes},3},#{window_panes} paneles, ventana #{window_index} ,}'
      tmux -L lab display -p '[#{E:@lab-panes}]'
      ```
      ```
      [3 paneles]
      ```
      La rama acabó en la coma y el resto se tomó como rama falsa. Y con
      `>=` de texto en lugar de `e|>=|`:
      ```bash
      tmux -L lab display -p '#{>=:10,3} #{e|>=|:10,3}'
      tmux -L lab source-file "$PWD/starter/tmux.conf"
      ```
      ```
      0 1
      ```
      Con texto, 10 paneles no serían "3 o más". El `source-file` deja tu
      versión buena.
   5. **TODO 5: OJO.** Pista:
      `set -g @lab-look '#{?#{||:#{window_zoomed_flag},#{pane_synchronized}},OJO ,}'`.
      ```bash
      tmux -L lab display -p '[#{E:@lab-look}]'
      tmux -L lab setw synchronize-panes on
      tmux -L lab display -p '[#{E:@lab-look}] #{pane_synchronized}'
      ```
      ```
      []
      [OJO ] 1
      ```
      La B termina en `3 paneles, ventana 0 OJO 01:58`: lo que escribas en
      un panel va a los tres. Apágalo:
      ```bash
      tmux -L lab setw synchronize-panes off
      tmux -L lab display -p '[#{E:@lab-look}]'
      ```
      ```
      []
      ```

6. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A (sin zoom activo: lo quitaste en el TODO 2):
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `#{<:10,9}` imprime `1` y qué usar para comparar números (paso 2)
- [ ] Sabes negar una condición en 3.4 sin `#{!:...}` (paso 3)
- [ ] Con `C-b` pulsado en la B, `display -p '[#{E:@lab-prefix}]'` imprime `[PREFIX ]` (paso 5.1)
- [ ] `display -p '[#{E:@lab-env}]'` imprime `[PROD ]` solo con la sesión `api-prod` (paso 5.3)
- [ ] Con 3 paneles, `display -p '[#{E:@lab-panes}]'` imprime `[3 paneles, ventana 0 ]`, y explicas qué pasa sin `#,` (paso 5.4)
- [ ] Con `synchronize-panes on`, `display -p '[#{E:@lab-look}]'` imprime `[OJO ]` (paso 5.5)

## Reto extra

Haz que `@lab-env` distinga tres casos con condicionales anidados: `PROD`
si la sesión termina en `-prod`, `STG` si termina en `-stg` y nada en otro
caso. Después prueba `#{m/r:-(prod|stg)$,#{session_name}}` (expresión
regular) y explica qué ventaja tiene sobre el glob.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — Formats y `display -p`](../lab-01-formats-y-display/README.md) | [Lab 03 — Modificadores](../lab-03-modificadores/README.md) → |

[↑ Semana 07](../../README.md)
