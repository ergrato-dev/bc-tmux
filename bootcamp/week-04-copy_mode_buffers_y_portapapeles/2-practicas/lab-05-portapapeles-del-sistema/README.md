# Lab 05 — Portapapeles del sistema

⏱ Duración estimada: ~60 min

## Objetivo

Llevar lo que copias en tmux al portapapeles de tu sistema con la herramienta correcta para macOS, WSL, Wayland o X11, conectada a `copy-command`.

## Contexto

- Cada sistema tiene su herramienta y su trampa: `clip.exe` rompe la ñ, `xclip` sin opciones copia en la selección equivocada, WSL con WSLg también define `DISPLAY`.
- `copy.sh` recibe el texto por stdin y elige la herramienta. tmux lo llama desde `copy-command`, así que `y`, `Enter` y el ratón copian al mismo sitio.
- Los pasos 1 y 2 se hacen **en tu máquina**: el contenedor del laboratorio no tiene portapapeles. Del 3 al 6 funcionan en los dos sitios, con herramientas falsas que anotan lo que reciben (`3-proyecto/tests/fake-path`).

## Instrucciones

0. Abre una terminal **fuera de tmux** (`echo "$TMUX"` imprime una línea
   vacía) en tu máquina, no en el laboratorio. Desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-05-portapapeles-del-sistema
   F="$PWD/../../3-proyecto/tests/fake-path"
   ```
   `F` se usa en los pasos 3 a 6. Servidor aparte: `-L lab`.

1. **¿Dónde estás?**
   ```bash
   uname; echo "WSL=${WSL_DISTRO_NAME:-} WAYLAND=${WAYLAND_DISPLAY:-} DISPLAY=${DISPLAY:-}"
   ```
   | Ves | Sistema | Herramienta | Sigue en |
   |---|---|---|---|
   | `Darwin` | macOS | `pbcopy` | 2.1 |
   | `WSL=Ubuntu...` | WSL | `win32yank.exe` o `clip.exe` | 2.2 |
   | `WAYLAND=wayland-0` | Linux con Wayland | `wl-copy` | 2.3 |
   | `DISPLAY=:0` y nada más | Linux con X11 | `xclip` o `xsel` | 2.4 |
   | `Linux` y las tres vacías | Contenedor o SSH | ninguna: OSC 52 (lab 06) | 3 |

   En WSL con WSLg verás las tres variables: por eso `copy.sh` mira WSL
   primero.

2. **Tu herramienta, sin tmux.** Haz solo el subpaso de tu sistema.

   1. **macOS.** `pbcopy` y `pbpaste` vienen con el sistema:
      ```bash
      printf 'año' | pbcopy; pbpaste; echo
      ```
      ```
      año
      ```
      Pega con `Cmd+V` en el navegador. No hay trampa que reproducir.
   2. **WSL: la ñ.** Comprueba primero que ves los programas de Windows:
      ```bash
      command -v clip.exe powershell.exe
      ```
      ```
      /mnt/c/Windows/System32/clip.exe
      /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
      ```
      Si no imprime nada, tu WSL no añade las rutas de Windows al `PATH`
      (`appendWindowsPath=false` en `/etc/wsl.conf`). Para este lab, añádelas
      en esta terminal:
      `export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"`.
      Reproduce el problema: copia con `clip.exe` y lee el portapapeles de
      Windows:
      ```bash
      printf 'año\n' | clip.exe
      powershell.exe -NoProfile -Command Get-Clipboard
      ```
      ```
      aÃ±o
      ```
      `clip.exe` interpreta los bytes con la página de códigos de Windows (si
      activaste la opción beta "UTF-8 para todo el mundo" de Windows, sale
      `año`). Instala `win32yank.exe`, que respeta UTF-8:
      ```bash
      sudo apt install unzip curl
      curl -sLo /tmp/w.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
      mkdir -p ~/.local/bin && unzip -p /tmp/w.zip win32yank.exe > ~/.local/bin/win32yank.exe
      chmod +x ~/.local/bin/win32yank.exe
      command -v win32yank.exe
      ```
      Si `command -v` no imprime nada, `~/.local/bin` no está en tu `PATH`:
      `export PATH="$HOME/.local/bin:$PATH"; hash -r` (y añade el `export` a
      tu `~/.bashrc` o `~/.zshrc` para las próximas terminales). Prueba:
      ```bash
      printf 'año' | win32yank.exe -i; win32yank.exe -o; echo
      ```
      ```
      año
      ```
   3. **Wayland.** Instala y prueba `wl-clipboard`:
      ```bash
      command -v wl-copy || echo "falta wl-copy"
      sudo apt install wl-clipboard
      printf 'año' | wl-copy; wl-paste
      ```
      ```
      falta wl-copy
      año
      ```
      (La primera línea solo si no lo tenías: esa es la trampa, el error que
      verá `copy.sh`.) Pega con `Ctrl+V` en el navegador.
   4. **X11: dos portapapeles.** Instala `xclip`, copia sin opciones e
      intenta leer el portapapeles de `Ctrl+V`:
      ```bash
      sudo apt install xclip
      printf hola | xclip
      xclip -o; echo
      xclip -o -selection clipboard; echo
      ```
      ```
      hola
      <otra cosa: lo que copiaste antes, o un error si estaba vacío>
      ```
      Sin opciones, `xclip` escribe en **PRIMARY**, la selección que se pega
      con el botón central. `Ctrl+V` lee **CLIPBOARD**. Con la opción, sí:
      ```bash
      printf hola | xclip -selection clipboard; xclip -o -selection clipboard; echo
      ```
      ```
      hola
      ```

3. **TODO 1** de `starter/copy.sh` (WSL): borra la línea
   `missing "WSL sin implementar"` y usa `win32yank.exe -i` si está,
   `clip.exe` si no (la pista exacta está en el starter). Pruébalo en
   cualquier sistema con `fake-path`: crea un `PATH` donde las herramientas
   de portapapeles son falsas y guardan su entrada en `NOMBRE.data` y sus
   argumentos en `NOMBRE.args`. `env -i` vacía el entorno: así decides qué
   sistema "ve" el script.
   ```bash
   f=$("$F" clip.exe win32yank.exe); printf año | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu ./starter/copy.sh; ls "$f" | grep '\.data$'
   f=$("$F" clip.exe); printf año | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu ./starter/copy.sh; ls "$f" | grep '\.data$'
   f=$("$F"); printf año | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu ./starter/copy.sh; echo $?
   ```
   ```
   win32yank.exe.data
   clip.exe.data
   copy.sh: no encuentro clip.exe: ¿está activada la interoperabilidad de WSL?
   1
   ```
   Con las dos herramientas, solo `win32yank.exe` recibe el texto.

4. **TODO 2** (X11): borra `missing "X11 sin implementar"` y usa
   `xclip -selection clipboard`, o `xsel --clipboard --input` si no hay
   `xclip`.
   ```bash
   f=$("$F" xclip); printf hola | env -i PATH="$f" DISPLAY=:0 ./starter/copy.sh; cat "$f/xclip.data"; echo; cat "$f/xclip.args"
   f=$("$F" xsel); printf hola | env -i PATH="$f" DISPLAY=:0 ./starter/copy.sh; cat "$f/xsel.data"; echo; cat "$f/xsel.args"
   f=$("$F"); printf x | env -i PATH="$f" DISPLAY=:0 ./starter/copy.sh; echo $?
   ```
   ```
   hola
   -selection clipboard
   hola
   --clipboard --input
   copy.sh: instala xclip (sudo apt install xclip)
   1
   ```
   Cada herramienta recibió `hola` por stdin (`.data`) y sus opciones
   (`.args`). Las ramas de Wayland y "sin portapapeles" ya venían hechas:
   ```bash
   f=$("$F" wl-copy); printf hola | env -i PATH="$f" WAYLAND_DISPLAY=wayland-0 ./starter/copy.sh; cat "$f/wl-copy.data"; echo
   f=$("$F"); printf x | env -i PATH="$f" ./starter/copy.sh; echo $?
   ```
   ```
   hola
   copy.sh: no hay portapapeles gráfico (¿SSH o contenedor?): lo resuelve OSC 52, en el lab 06
   1
   ```
   Y `shellcheck starter/copy.sh; echo $?` imprime `0` (instálalo con
   `sudo apt install shellcheck` o `brew install shellcheck`).

5. **TODO 3** de `starter/tmux.conf`: `copy-command` apunta a `copy.sh`.
   Pista: `set -sF copy-command "#{d:current_file}/copy.sh"`. Mira qué
   ruta queda con un `-f` relativo:
   ```bash
   tmux -L lab -f starter/tmux.conf new -d \; show -sv copy-command
   ```
   ```
   starter/copy.sh
   ```
   Relativa: `current_file` es la ruta que pasaste a `-f`, tal cual. Y tmux
   ejecuta `copy-command` desde tu `$HOME`, donde `starter/copy.sh` no
   existe: copiarías sin error visible y sin resultado. Con ruta absoluta:
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -sv copy-command
   ```
   Algo como (tu ruta hasta el repositorio):
   ```
   /home/tú/bc-tmux/bootcamp/week-04-copy_mode_buffers_y_portapapeles/2-practicas/lab-05-portapapeles-del-sistema/starter/copy.sh
   ```
   Al instalar el kit en `~/.config/tmux` la ruta ya es absoluta. Para el
   paso siguiente, para este servidor:
   ```bash
   tmux -L lab kill-server
   ```

6. **Copia de verdad.** Haz la versión de tu sitio.

   - **En tu máquina** (macOS, WSL, Wayland o X11). Arranca y conéctate en
     esta misma terminal (sin `new -d`, el comando te deja dentro):
     ```bash
     tmux -L lab -f "$PWD/starter/tmux.conf"
     ```
     El prefix es `C-b`: el starter no define otro. Dentro, ejecuta
     `echo hola`. Copia: `C-b` `[`, `?` `hola` `Enter` (el cursor va a la
     salida `hola`), `v` (empieza), `e` (fin de palabra), `y` (copia y sale).
     Pega con `Ctrl+V` (`Cmd+V` en macOS) en el navegador: `hola`. También
     puedes arrastrar con el ratón y soltar. Sal con `C-b` `d`:
     ```
     [detached (from session 0)]
     ```
   - **En el laboratorio**, con herramientas falsas. El servidor hereda el
     entorno de `env -i`: tmux y `copy.sh` creen que estás en X11.
     ```bash
     f=$("$F" xclip)
     env -i PATH="$f" HOME="$HOME" TERM="$TERM" DISPLAY=:0 tmux -L lab -f "$PWD/starter/tmux.conf"
     ```
     Ya conectado: `echo hola`, y las mismas teclas: `C-b` `[`, `?` `hola`
     `Enter`, `v`, `e`, `y`. Sal con `C-b` `d` y, fuera:
     ```bash
     cat "$f/xclip.data"; echo; cat "$f/xclip.args"
     ```
     ```
     hola
     -selection clipboard
     ```

7. Limpia:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Paso 1: explicas qué sistema tienes y por qué `copy.sh` mira WSL antes que Wayland
- [ ] Paso 2: reproduces la trampa de tu sistema (la ñ con `clip.exe`, PRIMARY con `xclip`, `wl-copy` que falta) y la resuelves
- [ ] Pasos 3 y 4: las pruebas con `fake-path` dan la salida esperada y `shellcheck` no avisa
- [ ] Paso 5: `show -sv copy-command` imprime una ruta absoluta que termina en `/copy.sh`, y explicas por qué con `-f starter/tmux.conf` no lo es
- [ ] Paso 6: copias en copy mode y pegas fuera de tmux con `Ctrl+V` (o, en el laboratorio, `xclip.data` tiene `hola`)

## Reto extra

Entra por SSH a otra máquina (o a `localhost`) y prueba allí `copy.sh`. ¿En
el portapapeles de qué máquina acaba el texto? El lab 06 lo resuelve.
