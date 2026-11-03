# Lab 01 — Formats y `display -p`

⏱ Duración estimada: ~60 min

## Objetivo

Leer el estado de tmux con formats (`#{...}`) desde la terminal, con `display -p` y `list-* -F`, antes de ponerlos en la barra.

## Contexto

- Un format es texto con variables `#{nombre}` que tmux sustituye por su valor: el de la sesión, ventana y panel **del momento** en que lo expande.
- `display -p` imprime un format en la terminal: es tu banco de pruebas para todo lo de esta semana. `list-windows -F`, `list-panes -F` y compañía hacen lo mismo con cada elemento de una lista.
- Una variable que no existe no da error: se expande a vacío. Una errata en `#{...}` no avisa nunca; por eso se prueba con `display -p` antes de dejarla en la config.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-01-formats-y-display
   ```
   El servidor es `-L lab`. Ni `-f /dev/null` ni el starter cambian el
   prefix: en este lab es **`C-b`**.

1. **Las primeras variables.** Un servidor vacío con dos ventanas, cada una
   en una carpeta distinta (terminal A):
   ```bash
   tmux -L lab -f /dev/null new -d -s api -n editor -c /tmp
   tmux -L lab new-window -t api -n logs -c /var/log
   tmux -L lab display -p '#{session_name}'
   tmux -L lab display -p '#{session_name}:#{window_index}.#{pane_index} #{window_name}'
   tmux -L lab display -p '#{pane_current_path} #{pane_current_command}'
   tmux -L lab display -p 'tmux #{version} en #{host_short}'
   ```
   Algo como (el host es el nombre de tu máquina):
   ```
   api
   api:1.0 logs
   /var/log bash
   tmux 3.4 en bc-tmux-lab
   ```
   Sin cliente conectado, `display -p` usa la ventana actual de la sesión:
   la última que creaste. Con `-t` eliges otra:
   ```bash
   tmux -L lab display -p -t api:0 '#{window_name} #{pane_current_path}'
   ```
   ```
   editor /tmp
   ```

2. **Lo que no existe.** Una variable inventada y una opción de usuario que
   nadie definió (las que empiezan por `@`):
   ```bash
   tmux -L lab display -p '[#{nada}] [#{@nada}]'; echo $?
   tmux -L lab show -gv @nada; echo $?
   ```
   ```
   [] []
   0
   invalid option: @nada
   1
   ```
   En un format, lo que no existe es vacío y no avisa. `show` sí falla: úsalo
   para saber si una opción está definida. Dos detalles más:
   ```bash
   tmux -L lab display -p '##{session_name} vale #{session_name}'
   tmux -L lab display -p '#[fg=red]hola#[default]'
   ```
   ```
   #{session_name} vale api
   #[fg=red]hola#[default]
   ```
   `##` es un `#` literal. Los estilos `#[...]` solo los entiende la barra:
   `display -p` los imprime tal cual (lab-04).

3. **Un target que no existe.** Cuidado al usar `display -p` en un script:
   ```bash
   tmux -L lab display -p -t nope '#{session_name}'; echo $?
   tmux -L lab list-panes -t nope; echo $?
   ```
   ```

   0
   can't find window: nope
   1
   ```
   `display -p` imprime una línea vacía y sale con 0 aunque `nope` no
   exista. Para validar un target, `list-panes -t` (o `has-session` para
   sesiones), que sí fallan.

4. **Formats en listas.** `-F` aplica el format a cada elemento:
   ```bash
   tmux -L lab list-windows -t api -F '#{window_index} #{window_name} #{window_active}'
   tmux -L lab list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_path}'
   tmux -L lab list-sessions -F '#{session_name}: #{session_windows} ventanas'
   tmux -L lab kill-server
   ```
   ```
   0 editor 0
   1 logs 1
   api:0.0 /tmp
   api:1.0 /var/log
   api: 2 ventanas
   ```
   `#{window_active}` vale `1` solo en la actual. La lista completa de
   variables está en `man tmux`, sección FORMATS.

5. **Arranca con el starter** (terminal A). Todavía no define nada:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api -n editor; echo $?
   tmux -L lab display -p '[#{@lab-owner}] [#{E:@lab-where}]'
   tmux -L lab show -gv status-right
   ```
   ```
   0
   [] []
   #{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}"#{=21:pane_title}" %H:%M %d-%b-%y
   ```
   El `status-right` por defecto ya es un format: condicionales (lab-02),
   modificadores (lab-03) y `%H:%M`, que es `strftime`, como en `date`.

6. **Los TODOs de `starter/tmux.conf`.** Edita el archivo, recarga y
   prueba cada uno en la terminal A.

   1. **TODO 1: una opción de usuario.** Pista: `set -g @lab-owner ana`
      (tu nombre, sin espacios; aquí se usa `ana`).
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
      tmux -L lab display -p '#{@lab-owner}'
      ```
      ```
      0
      ana
      ```
   2. **TODO 2: un format guardado.** Pista:
      `set -g @lab-where '#{session_name}:#{window_index}.#{pane_index}'`,
      con comillas simples y **sin** `-F`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"
      tmux -L lab show -gv @lab-where
      tmux -L lab display -p '#{@lab-where}'
      tmux -L lab display -p '#{E:@lab-where}'
      ```
      ```
      #{session_name}:#{window_index}.#{pane_index}
      #{session_name}:#{window_index}.#{pane_index}
      api:0.0
      ```
      La opción guarda el texto. `#{@lab-where}` devuelve ese texto;
      `#{E:@lab-where}` lo **expande** como format. `display -p
      '#{E:opción}'` es la forma de ver lo que dibujaría la barra.
   3. **TODO 3: a la barra.** Pista:
      `set -g status-right '#{@lab-owner} #{E:@lab-where} '`.
      ```bash
      tmux -L lab source-file "$PWD/starter/tmux.conf"
      tmux -L lab display -p '#{E:status-right}'
      ```
      ```
      ana api:0.0 
      ```
      En la terminal B:
      ```bash
      tmux -L lab attach -t api
      ```
      La barra (el hueco del medio depende del ancho de tu terminal):
      ```
      [api] 0:editor*                                          ana api:0.0
      ```
      Deja la B conectada.

7. **Con `-F` o sin `-F`.** `set -gF` expande el format **una vez**, al
   guardarlo. En la terminal A:
   ```bash
   tmux -L lab set -gF @lab-fixed '#{session_name}:#{window_index}.#{pane_index}'
   tmux -L lab show -gv @lab-fixed
   tmux -L lab new-window -n logs
   tmux -L lab display -p 'fija=#{@lab-fixed} viva=#{E:@lab-where}'
   ```
   ```
   api:0.0
   fija=api:0.0 viva=api:1.0
   ```
   La B salta a la ventana nueva y su barra termina en `ana api:1.0`. Para
   la barra, casi siempre sin `-F`: quieres el valor de cada momento.

8. **TODO 4 de `starter/bin/lab-windows`.** El script ya comprueba los
   argumentos y que la sesión exista; le falta listar. Antes de tocarlo
   (terminal A):
   ```bash
   ./starter/bin/lab-windows; echo $?
   TMUX_SOCKET=lab ./starter/bin/lab-windows nope; echo $?
   TMUX_SOCKET=lab ./starter/bin/lab-windows api; echo $?
   ```
   ```
   uso: lab-windows SESION
   2
   no existe la sesión: nope
   1
   sin implementar
   1
   ```
   `TMUX_SOCKET=lab` hace que `tmx` hable con `-L lab`. Borra las dos
   líneas `echo "sin implementar"` y `exit 1`, y en su lugar escribe:
   `tmx list-windows -t "=$session" -F '#{window_index} #{window_name} #{window_panes} #{window_active}'`.
   ```bash
   TMUX_SOCKET=lab ./starter/bin/lab-windows api; echo $?
   tmux -L lab new -d -s api-vieja
   TMUX_SOCKET=lab ./starter/bin/lab-windows ap; echo $?
   ```
   ```
   0 editor 1 0
   1 logs 1 1
   0
   no existe la sesión: ap
   1
   ```
   Con `=`, `ap` no coincide por prefijo con `api` ni con `api-vieja`.
   Pasa shellcheck (`sudo apt install shellcheck` / `brew install
   shellcheck` si no lo tienes):
   ```bash
   shellcheck starter/bin/lab-windows; echo $?
   ```
   ```
   0
   ```

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

- [ ] `tmux -L lab display -p '[#{nada}]'; echo $?` imprime `[]` y `0`, y explicas por qué una errata en un format no avisa (paso 2)
- [ ] Explicas por qué `display -p -t nope` no sirve para validar un target y qué usar en su lugar (paso 3)
- [ ] `tmux -L lab show -gv @lab-where` imprime el format con `#{...}` y `display -p '#{E:@lab-where}'` imprime `api:0.0` (paso 6.2)
- [ ] La barra de la B termina en tu nombre y `api:0.0` (paso 6.3)
- [ ] `display -p 'fija=#{@lab-fixed} viva=#{E:@lab-where}'` imprime `fija=api:0.0 viva=api:1.0` (paso 7)
- [ ] `TMUX_SOCKET=lab ./starter/bin/lab-windows api` imprime una línea por ventana y `shellcheck` sale con 0 (paso 8)

## Reto extra

Añade una columna a `lab-windows` con el programa del panel activo de cada
ventana (`#{pane_current_command}`) y otra con su carpeta. ¿De qué panel
sale `pane_*` cuando la ventana tiene varios? Pruébalo con un
`split-window` en una de ellas.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — Condicionales y comparaciones](../lab-02-condicionales-y-comparaciones/README.md) → |

[↑ Semana 07](../../README.md)
