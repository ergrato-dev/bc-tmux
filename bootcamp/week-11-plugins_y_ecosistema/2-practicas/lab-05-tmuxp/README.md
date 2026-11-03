# Lab 05 — tmuxp

⏱ Duración estimada: ~60 min

## Objetivo

Declarar en un YAML de tmuxp la misma sesión de trabajo que crea `bin/dev-up`, cargarla, congelar una sesión viva y decidir cuándo compensa cada enfoque.

## Contexto

- tmuxp lee un YAML (sesión, ventanas, paneles, directorios, comandos) y crea la sesión con `tmux` por debajo. Es Python: se instala con `uv tool install`, nunca con pip.
- `tmuxp load -d` crea la sesión sin conectarse; `tmuxp freeze` hace el camino inverso y escribe el YAML de una sesión que ya existe.
- `-L` pasa el socket a tmux, igual que en tus scripts: todo el lab va contra `-L lab`.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux** (`echo "$TMUX"` vacío), desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp
   ```
   Instala tmuxp fijado a la serie 1.76. Si no tienes uv: `brew install uv`
   en macOS o el instalador de [docs.astral.sh/uv](https://docs.astral.sh/uv/)
   en Ubuntu (en el laboratorio Docker ya está). uv descarga su propio
   Python si hace falta:
   ```bash
   uv tool install "tmuxp==1.76.*"
   export PATH="$HOME/.local/bin:$PATH"; tmuxp --version
   ```
   Algo como (la descarga de Python solo la primera vez):
   ```
   Downloading cpython-3.14.7-linux-x86_64-gnu (download) (34.3MiB)
    Downloaded cpython-3.14.7-linux-x86_64-gnu (download)
   Resolved 3 packages in 969ms
   Prepared 3 packages in 1.26s
   Installed 3 packages in 6ms
    + libtmux==0.62.0
    + pyyaml==6.0.3
    + tmuxp==1.76.0
   Installed 1 executable: tmuxp
   warning: `/home/alumno/.local/bin` is not on your PATH. To use installed tools, run `export PATH="/home/alumno/.local/bin:$PATH"` or `uv tool update-shell`.
   tmuxp 1.76.0, libtmux 0.62.0
   ```
   El `export` vale para esta terminal; `uv tool update-shell` lo deja fijo.
   Arranca tú el servidor del lab, sin config (`-f /dev/null`): si tmuxp lo
   arrancara, cargaría tu `~/.config/tmux/tmux.conf`. Con `-f /dev/null`
   el prefix es `C-b` y las ventanas empiezan en 0:
   ```bash
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f /dev/null new -d -s lab; echo $?
   F='#{window_index}:#{window_name} #{window_panes} #{pane_current_path}'
   ```
   ```
   0
   ```

1. **Carga el YAML del starter.** Abre `starter/api.yaml`: una sesión `api`
   con una ventana de un panel, en `./demo`:
   ```bash
   tmuxp load -L lab -d "$PWD/starter/api.yaml"; echo $?
   tmux -L lab list-windows -t =api -F "$F"
   ```
   Algo como (la ruta es la de tu carpeta del lab):
   ```
   ✓ Loaded workspace: api (/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/api.yaml) [1 win, 1 panes]
   Session created in detached state.
   0
   0:editor 1 /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
   ```
   `./demo` se resolvió desde la carpeta del YAML, no desde donde estás.

2. **TODO 1, 2 y 3 — el resto de la sesión.** En `starter/api.yaml`:
   - TODO 1: en la ventana `editor`, añade `layout: even-horizontal` y un
     segundo panel `- ls` debajo de `- echo editor`.
   - TODO 2: quita el `#` (y un espacio) de las líneas de la ventana `run`,
     alineando el `-` con el de `editor`.
   - TODO 3: lo mismo con la ventana `logs`.

   En YAML la sangría es la sintaxis: dos espacios por nivel, sin
   tabuladores. Compara con `solucion/api.yaml` si algo no carga. tmuxp no
   recrea una sesión que existe; bórrala y carga:
   ```bash
   tmux -L lab kill-session -t =api; tmuxp load -L lab -d "$PWD/starter/api.yaml"; echo $?
   tmux -L lab list-windows -t =api -F "$F"
   tmux -L lab list-panes -t =api:editor -F '#{pane_index} #{pane_left},#{pane_top} #{pane_width}x#{pane_height}'
   tmux -L lab list-panes -t =api:logs -F '#{pane_current_command}'
   tmux -L lab capture-pane -p -t =api:run | grep -v '^$'
   ```
   Algo como:
   ```
   ✓ Loaded workspace: api (/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/api.yaml) [3 win, 4 panes]
   Session created in detached state.
   0
   0:editor 2 /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
   1:run 1 /etc
   2:logs 1 /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
   0 0,0 39x24
   1 40,0 40x24
   top
   alumno@bc-tmux-lab:/etc$  pwd
   /etc
   alumno@bc-tmux-lab:/etc$
   ```
   Cada `panes:` es una lista de comandos que tmuxp escribe con
   `send-keys`, como tu `dev-up`: por eso `pwd` aparece tecleado en la shell.

3. **¿Es idempotente?** Carga otra vez el mismo YAML:
   ```bash
   tmuxp load -L lab -d "$PWD/starter/api.yaml"; echo $?
   tmux -L lab list-windows -t =api | wc -l
   ```
   ```
   0
   3
   ```
   Con la sesión ya creada y `-d`, no hace nada y sale con 0: el mismo
   efecto que el `has-session` de `dev-up`. Para una segunda copia, otro
   nombre:
   ```bash
   tmuxp load -L lab -d -s api2 "$PWD/starter/api.yaml"; echo $?
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   Session created in detached state.
   ✓ Loaded workspace: api2 (/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/api.yaml) [3 win, 4 panes]
   0
   api
   api2
   lab
   ```

4. **Congela una sesión viva.** Añade a mano una ventana a `api` y escribe
   el YAML de lo que hay ahora:
   ```bash
   mkdir -p /tmp/lab11
   tmux -L lab new-window -d -t =api: -n notas -c /var
   tmuxp freeze -L lab -y -o /tmp/lab11/api-frozen.yaml api; echo $?
   grep -E 'window_name|start_directory|shell_command' /tmp/lab11/api-frozen.yaml
   ```
   Algo como:
   ```
   ---------------------------------------------------------------
   Freeze does its best to snapshot live tmux sessions.

   Saved to /tmp/lab11/api-frozen.yaml.
   0
       shell_command: bash
     start_directory: /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
     window_name: editor
       shell_command: bash
     start_directory: /etc
     window_name: run
       shell_command: top
     start_directory: /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
     window_name: logs
       shell_command: bash
     start_directory: /var
     window_name: notas
   ```
   Fíjate en lo que se pierde: rutas absolutas en vez de `./demo`, y
   `bash` donde había `pwd` y `ls` (ya terminaron). `freeze` da un
   borrador para editar, no una copia exacta.

5. **Cárgalo.** Borra las dos sesiones y crea `api` desde el YAML
   congelado:
   ```bash
   tmux -L lab kill-session -t =api2; tmux -L lab kill-session -t =api
   tmuxp load -L lab -d /tmp/lab11/api-frozen.yaml; echo $?
   tmux -L lab list-windows -t =api -F "$F"
   ```
   Algo como:
   ```
   ✓ Loaded workspace: api (/tmp/lab11/api-frozen.yaml) [4 win, 5 panes]
   Session created in detached state.
   0
   0:editor 2 /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
   1:run 1 /etc
   2:logs 1 /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-05-tmuxp/starter/demo
   3:notas 1 /var
   ```
   Para verla: en una terminal B, desde la carpeta del lab,
   `tmux -L lab attach -t api`; sales con `C-b` `d` →
   `[detached (from session api)]`. En la ventana `logs`, `top` se cierra
   con `q`.

6. **tmuxp o `dev-up`.** Escribe en dos o tres líneas, en un archivo tuyo,
   cuándo usarías cada uno. Pistas: el YAML se lee de un vistazo y se
   versiona con el proyecto; `dev-up` recibe el directorio como argumento,
   no necesita Python y lo controlas entero; tmuxp es una dependencia más
   que instalar en cada máquina.

7. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -r /tmp/lab11
   ```
   ```
   (sin salida)
   ```
   tmuxp se queda instalado. Para quitarlo: `uv tool uninstall tmuxp`.

## Criterios de éxito

- [ ] `tmuxp --version` imprime `tmuxp 1.76.0` (paso 0)
- [ ] `tmux -L lab list-windows -t =api` muestra `editor` con 2 paneles, `run` en `/etc` y `logs` (paso 2)
- [ ] `list-panes -t =api:logs -F '#{pane_current_command}'` imprime `top` (paso 2)
- [ ] Un segundo `tmuxp load -d` del mismo YAML no crea ventanas nuevas (paso 3)
- [ ] `/tmp/lab11/api-frozen.yaml` carga y crea las 4 ventanas, `notas` incluida (pasos 4 y 5)
- [ ] Explicas qué se pierde al congelar una sesión y por qué (paso 4)

## Reto extra

[sesh](https://github.com/joshmedeski/sesh) es un gestor de sesiones en Go
que se distribuye como binario: descarga el de tu sistema desde su página de
releases (la versión del bootcamp es la 2.34.x) y ponlo en
`~/.local/bin`. Lee su README: ¿qué hace `sesh connect` con un directorio
que no tiene sesión, y en qué se parece a tu `kit-projects` de la semana
10?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — Interpolación en la status line](../lab-04-interpolacion-en-la-status/README.md) | [Lab 06 — Plugins rotos](../lab-06-plugins-rotos/README.md) → |

[↑ Semana 11](../../README.md)
