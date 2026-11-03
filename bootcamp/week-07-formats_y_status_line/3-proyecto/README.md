# Proyecto Semana 07 — tmux-kit: status line propia, sin plugins

⏱ Duración estimada: ~3 h

## Contexto

Tu kit ya tiene modo resize, navegación con `C-h/j/k/l` y un interruptor `@kit-nav`, pero la barra de abajo sigue siendo la verde de fábrica: no te dice si pulsaste el prefix, si estás en el modo resize, si la ventana tiene un panel con zoom o si apagaste la navegación. Y cada vez que cambias de repo en un panel, haces `git branch` para saber en qué rama estás.

Esta semana escribes **tu propia status line**, solo con formats de tmux, en un módulo nuevo `conf.d/30-status.conf`. Los colores viven en opciones `@kit-color-*` para cambiarlos en un sitio, la izquierda reacciona al prefix y al modo resize, la lista de ventanas marca `ZOOM` y `SYNC`, y la derecha enseña `NAV off`, la rama git del panel activo (con un script nuevo, **`bin/kit-git-branch`**), el host y la hora.

```
 api  RESIZE   1:editor ZOOM  2:logs SYNC                     NAV off main bc-tmux-lab 18:42
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                 ← tu tmux-kit de la semana 06 + lo nuevo
├── README.md            ← añade la status line, kit-git-branch y la bitácora
├── .gitignore           ← local.conf
├── tmux.conf            ← sin cambios: carga conf.d/*.conf
├── conf.d/
│   ├── 10-options.conf  ← sin cambios
│   ├── 20-bindings.conf ← sin cambios
│   └── 30-status.conf   ← TODOs 1-6, 9 y 10 (nuevo)
└── bin/
    ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option, kit-keys   (semanas 01-06)
    └── kit-git-branch   ← TODOs 7 y 8 (nuevo)
```

`tmux.conf` carga `conf.d/*.conf` por orden de nombre: `30-status.conf` entra solo, sin tocar el punto de entrada.

## Lo que debes construir

1. **Paleta**: `@kit-color-bg`, `@kit-color-fg`, `@kit-color-accent`, `@kit-color-alert` y `@kit-color-warn`, y `@kit-status-git on`. Ningún color se escribe dos veces: todo lo demás usa `#{@kit-color-...}`.
2. **Barra**: `status-interval 5`, `status-justify left`, y `status-style`, `message-style` y `pane-active-border-style` con la paleta.
3. **Izquierda**: la sesión (cortada a 20 caracteres) sobre fondo `accent`, que pasa a `alert` mientras el prefix está pulsado; detrás, `RESIZE` sobre `warn` cuando el cliente está en la tabla `kit-resize`.
4. **Ventanas**: `índice:nombre`, con ` ZOOM` si la ventana tiene zoom y ` SYNC` si tiene `synchronize-panes`, escrito una sola vez en `@kit-window-label`. La actual con un estilo propio (`window-status-current-style`), sin separador entre ventanas.
5. **`bin/kit-git-branch DIR`**: imprime la rama de `DIR`, el commit corto si HEAD está suelto, o nada si no es un repo. Sale con **0** también fuera de un repo o si `DIR` no existe, y con **2** si el uso es incorrecto.
6. **Derecha**: `NAV off` en `warn` si `@kit-nav` no vale `on`; la rama del panel activo con `#(...)`, solo si `@kit-status-git` vale `on`; `#{host_short}` y la hora.
7. **README del kit** con una sección de status line, `kit-git-branch` en la tabla de scripts, `30-status.conf` en la de estructura y la bitácora de la semana.

## Paso a paso

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte y mirar la
   barra. En la A, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/3-proyecto/starter
   ```
   Todo va contra un servidor aparte, `-L kit`, con ruta absoluta. El prefix
   del kit es `C-a`; si elegiste otro, cámbialo en cada paso. Los ejemplos
   enseñan el host del laboratorio (`bc-tmux-lab`) y una hora: tú verás los
   tuyos.

1. **Punto de partida.** Lo que el kit todavía no tiene:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s api
   tmux -L kit show -gv status-left
   tmux -L kit show -gv @kit-color-accent
   tmux -L kit display -p '#{E:status-left}'
   bin/kit-git-branch "$PWD"; echo $?
   bin/kit-git-branch; echo $?
   ```
   ```
   [#{session_name}] 
   invalid option: @kit-color-accent
   [api] 
   kit-git-branch: sin implementar (/ruta/a/starter)
   1
   Uso: kit-git-branch DIR
   Imprime la rama de DIR, el commit corto si HEAD está suelto o nada si no es un repo.
   2
   ```
   `show -gv` enseña el format **guardado**; `display -p '#{E:opción}'` lo
   **expande** como lo haría la barra (lab-01-formats-y-display). Las dos
   herramientas te acompañan toda la semana. Deja el servidor arrancado:
   después de cada TODO lo recargas con
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; echo $?
   ```
   ```
   0
   ```
   Si sale `1`, el mensaje de encima dice el archivo y la línea. Conéctate en
   la B para ver cada cambio:
   ```bash
   tmux -L kit attach -t api
   ```

2. **Paleta y barra (TODOs 1 y 2, `conf.d/30-status.conf`).** Todo con
   `set -g` y **sin `-F`**: así el `#{...}` se guarda tal cual y tmux lo
   expande cada vez que dibuja. Pistas:
   - TODO 1: `set -g @kit-color-accent "#3fb950"` y los otros cuatro
     (`bg` `#161b22`, `fg` `#8b949e`, `alert` `#f78166`, `warn` `#e3b341`,
     o los que prefieras), y `set -g @kit-status-git on`. Las comillas son
     obligatorias: sin ellas, `#3fb950` es un comentario.
   - TODO 2: `set -g status-style "fg=#{@kit-color-fg},bg=#{@kit-color-bg}"`;
     `message-style` con fondo `warn` y `pane-active-border-style` con
     `fg=#{@kit-color-accent}`. Y `status-interval 5`, `status-justify left`.

   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -g | grep '^@kit-color'
   tmux -L kit show -gv status-interval
   tmux -L kit show -gv status-style
   ```
   ```
   @kit-color-accent "#3fb950"
   @kit-color-alert "#f78166"
   @kit-color-bg "#161b22"
   @kit-color-fg "#8b949e"
   @kit-color-warn "#e3b341"
   5
   fg=#{@kit-color-fg},bg=#{@kit-color-bg}
   ```
   La B ya pinta la barra con tus colores. Prueba un mensaje desde la A:
   `tmux -L kit display "hola"` sale en la B con fondo amarillo.

3. **Izquierda: sesión, prefix y RESIZE (TODOs 3 y 4).** Del
   lab-02-condicionales-y-comparaciones y el lab-03-modificadores.
   - TODO 3:
     `#[fg=#{@kit-color-bg},bg=#{?client_prefix,#{@kit-color-alert},#{@kit-color-accent}},bold] #{=/20/…:session_name} #[default]`.
     `#{=/20/…:session_name}` corta el nombre a 20 caracteres y pone `…`.
     `set -g status-left-length 40`: el valor por defecto, 10, cortaría
     `RESIZE`.
   - TODO 4: detrás, `#{?#{==:#{client_key_table},kit-resize},ESTILO RESIZE #[default],}`.
     El estilo lleva comas (`fg=...,bg=...,bold`) **dentro** de una rama del
     condicional: escríbelas `#,`, o tmux cortará la rama en la primera
     (lab-06-status-rota).

   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit display -p '#{E:status-left}'
   ```
   ```
   #[fg=#161b22,bg=#3fb950,bold] api #[default] 
   ```
   Sin cliente no hay prefix: para ver lo que ve la B, pregunta **por su
   cliente** con `-c`. En la A:
   ```bash
   c=$(tmux -L kit list-clients -F '#{client_name}' | head -1)
   ```
   Pulsa `C-a` en la B (solo el prefix) y en la A:
   ```bash
   tmux -L kit list-clients -F '#{client_prefix} #{client_key_table}'
   tmux -L kit display -p -c "$c" '#{E:status-left}'
   ```
   ```
   1 prefix
   #[fg=#161b22,bg=#f78166,bold] api #[default] 
   ```
   Pulsa `R` en la B (ya estás en el modo resize) y repite los dos comandos:
   ```
   1 kit-resize
   #[fg=#161b22,bg=#f78166,bold] api #[default]#[fg=#161b22,bg=#e3b341,bold] RESIZE #[default] 
   ```
   `client_prefix` vale `1` en **cualquier** tabla que no sea `root`: en el
   modo resize la sesión sigue naranja. Sal con `q` en la B. Ahora cambia un
   color en caliente, sin recargar:
   ```bash
   tmux -L kit set -g @kit-color-accent colour99
   tmux -L kit display -p '#{E:status-left}'
   tmux -L kit set -g @kit-color-accent "#3fb950"
   ```
   ```
   #[fg=#161b22,bg=colour99,bold] api #[default] 
   ```
   La B se vuelve morada y luego verde: la paleta se lee al dibujar.

4. **Ventanas (TODOs 5 y 6).** Del lab-04-estilos-y-ventanas.
   - TODO 5: `set -g @kit-window-label "#I:#W#{?window_zoomed_flag, ZOOM,}#{?pane_synchronized, SYNC,}"`
     y `window-status-format` y `window-status-current-format` con
     `" #{E:@kit-window-label} "`. `E:` expande el format **que hay dentro**
     de la opción; sin él saldría el texto `#I:#W...` tal cual.
   - TODO 6: `window-status-style` con `fg`/`bg` de la paleta,
     `window-status-current-style` con fondo `accent` y `bold`, y
     `window-status-separator ""`.

   La barra recorre las ventanas con `#{W:normal,actual}`; puedes imitarla
   con `display -p`. Crea una segunda ventana y mira la lista:
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit new-window -d -t api -n logs
   tmux -L kit display -p -t api: '#{W:#{E:window-status-format}|,#{E:window-status-current-format}|}'
   ```
   ```
    1:bash | 2:logs |
   ```
   Ahora zoom en la 1 y `synchronize-panes` en la 2:
   ```bash
   tmux -L kit split-window -d -t api:1; tmux -L kit resize-pane -Z -t api:1
   tmux -L kit setw -t api:2 synchronize-panes on
   tmux -L kit display -p -t api: '#{W:#{E:window-status-format}|,#{E:window-status-current-format}|}'
   tmux -L kit show -gv window-status-current-style
   ```
   ```
    1:bash ZOOM | 2:logs SYNC |
   fg=#{@kit-color-bg},bg=#{@kit-color-accent},bold
   ```
   En la B, la ventana 1 sale verde y la 2 gris. Deshazlo antes de seguir:
   en tmux 3.4, `kill-server` con una ventana en zoom y sin clientes hace
   que el servidor falle al salir (y deja un archivo `core.*` en el
   directorio desde el que lo lanzaste).
   ```bash
   tmux -L kit resize-pane -Z -t api:1; tmux -L kit setw -t api:2 synchronize-panes off
   ```

5. **`bin/kit-git-branch` (TODOs 7 y 8).** El uso incorrecto ya funciona;
   al final hay un `echo "kit-git-branch: sin implementar"` y un `exit 1`
   que se borran en el TODO 8.
   - TODO 7: `command -v git >/dev/null 2>&1 || exit 0` y
     `[[ -d "$dir" ]] || exit 0`. tmux lo lanza desde la barra cada 5 s: un
     error no te sirve de nada ahí.
   - TODO 8: `if branch=$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null); then printf '%s\n' "$branch"`,
     y si no, lo mismo con `git -C "$dir" rev-parse --short HEAD`. Termina
     con `exit 0`. `symbolic-ref` solo lee `HEAD`: no recorre el árbol como
     `git status`, que en un repo grande tarda segundos.

   ```bash
   d=$(mktemp -d); git init -q -b demo "$d"
   bin/kit-git-branch "$d"; echo $?
   bin/kit-git-branch "$(mktemp -d)"; echo $?
   bin/kit-git-branch /no/existe; echo $?
   shellcheck bin/kit-git-branch; echo $?
   ```
   ```
   demo
   0
   0
   0
   0
   ```
   Fuera de un repo y con un directorio que no existe no imprime nada.

6. **Derecha: NAV off, rama, host y hora (TODOs 9 y 10).**
   - TODO 9: `set -g status-right-length 80` y `status-right` con
     `#{?#{!=:#{@kit-nav},on},#[fg=#{@kit-color-warn}#,bold]NAV off #[default],}`
     delante y `#{host_short} %H:%M ` al final. `%H:%M` es strftime, como en
     `date`.
   - TODO 10: entre los dos,
     `#{?#{==:#{@kit-status-git},on},#[fg=#{@kit-color-accent}]#(#{q:@kit-dir}/bin/kit-git-branch #{q:pane_current_path}) #[default],}`.
     tmux expande los `#{}` del comando **antes** de dárselo a la shell, y la
     ruta del panel no la eliges tú: `q:` escapa espacios, `$`, `;` y
     comillas. `#(...)` corre en segundo plano y la barra enseña su última
     salida (lab-05-comandos-y-varias-lineas).

   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit display -p '#{E:status-right}'
   tmux -L kit set -g @kit-nav off
   tmux -L kit display -p '#{E:status-right}'
   tmux -L kit set -g @kit-nav on
   ```
   ```
   #[fg=#3fb950] #[default]bc-tmux-lab 18:42 
   #[fg=#e3b341,bold]NAV off #[default]#[fg=#3fb950] #[default]bc-tmux-lab 18:42 
   ```
   ¿Y la rama? `display -p` **no ejecuta** `#(...)`: lo deja vacío. La rama
   solo la ves en la barra de verdad. En la B, ve al repo del bootcamp
   (`cd "$(git rev-parse --show-toplevel)"`): en menos de 5 s la derecha
   enseña `main` (o tu rama). Haz `cd /tmp` y desaparece. Prueba la cita:
   ```bash
   mkdir -p "/tmp/mi repo" && git init -q -b con-espacios "/tmp/mi repo"
   ```
   En la B, `cd "/tmp/mi repo"`: la barra dice `con-espacios`. Apágala desde
   la A con `tmux -L kit set -g @kit-status-git off`: la rama se va y
   `kit-git-branch` deja de ejecutarse (tmux no expande la rama del
   condicional que no elige). Vuelve a `on`.

7. **README del kit.** En `starter/README.md`: una sección
   `## Status line` con qué muestra cada zona y cómo cambiar la paleta y
   apagar la rama; la fila de `bin/kit-git-branch` en la tabla de scripts;
   `conf.d/30-status.conf` en la tabla de estructura; y la fila `07` en la
   bitácora.

8. **Cierra y verifica.** El `kill-server` expulsa a la B si seguía
   conectada (`[server exited]`). En la terminal A:
   ```bash
   tmux -L kit kill-server
   rm -rf "/tmp/mi repo"
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 07
   ```
   ```
   Semana 07 — Formats y status line

     ✅ tmux.conf carga sin errores
     ✅ La status line se define en conf.d/30-status.conf
     ✅ La paleta define @kit-color-bg, -fg, -accent, -alert y -warn
     ✅ Cambiar @kit-color-accent en caliente cambia el color de la sesión
     ✅ Con el prefix pulsado, la sesión usa @kit-color-alert
     ✅ En el modo resize, la izquierda muestra RESIZE
     ✅ Una ventana con zoom muestra ZOOM en la lista de ventanas
     ✅ Una ventana con synchronize-panes muestra SYNC en la lista de ventanas
     ✅ La ventana actual tiene un estilo propio, distinto del de las demás
     ✅ kit-git-branch sale con 2 sin argumentos
     ✅ kit-git-branch DIR imprime la rama de un repo
     ✅ kit-git-branch no imprime nada y sale con 0 fuera de un repo
     ✅ La derecha muestra la rama del panel aunque su ruta tenga espacios
     ✅ Con @kit-status-git off, la derecha deja de mostrar la rama
     ✅ Con @kit-nav off, la derecha muestra NAV off
     ✅ status-interval vale entre 1 y 5 segundos
     ✅ tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

   17/17 comprobaciones superadas.
   ```
   Tarda algo más de un minuto: varias comprobaciones conectan un cliente,
   pulsan el prefix de verdad (`send-keys -K`) o leen lo que la barra dibuja
   en la terminal. Cada fallo trae una pista al paso que lo arregla.

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-07-formats_y_status_line/3-proyecto/starter"
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
tmux -L kit show -gv status-interval
tmux -L kit display -p '#{E:status-left}'
bin/kit-git-branch "$(git rev-parse --show-toplevel)"
tmux -L kit kill-server
```
```
0
5
#[fg=#161b22,bg=#3fb950,bold] kit #[default] 
main
```
(La última línea es tu rama actual.)
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 07
```
```
17/17 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 07` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] La status line se define en conf.d/30-status.conf
- [ ] La paleta define @kit-color-bg, -fg, -accent, -alert y -warn
- [ ] Cambiar @kit-color-accent en caliente cambia el color de la sesión
- [ ] Con el prefix pulsado, la sesión usa @kit-color-alert
- [ ] En el modo resize, la izquierda muestra RESIZE
- [ ] Una ventana con zoom muestra ZOOM en la lista de ventanas
- [ ] Una ventana con synchronize-panes muestra SYNC en la lista de ventanas
- [ ] La ventana actual tiene un estilo propio, distinto del de las demás
- [ ] kit-git-branch sale con 2 sin argumentos
- [ ] kit-git-branch DIR imprime la rama de un repo
- [ ] kit-git-branch no imprime nada y sale con 0 fuera de un repo
- [ ] La derecha muestra la rama del panel aunque su ruta tenga espacios
- [ ] Con @kit-status-git off, la derecha deja de mostrar la rama
- [ ] Con @kit-nav off, la derecha muestra NAV off
- [ ] status-interval vale entre 1 y 5 segundos
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- `30-status.conf` agrupado por zona (paleta, barra, izquierda, ventanas, derecha) y ningún color escrito fuera de la paleta.
- Comentarios del porqué: por qué `set -g` sin `-F`, por qué `#,` dentro de los condicionales, por qué `q:` en el `#(...)`, qué coste tiene `status-interval` y por qué `client_prefix` también se enciende en el modo resize.
- Una sola etiqueta de ventana (`@kit-window-label`) para la actual y las demás.
- `kit-git-branch` rápido (sin `git status`), silencioso ante cualquier fallo y con los códigos de salida documentados en la cabecera.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.

## Entrega

Commit con el mensaje:
```
feat(week-07): status line propia con paleta @kit-color-* y kit-git-branch
```
