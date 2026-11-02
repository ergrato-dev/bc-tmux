# Lab 05 — Portapapeles del sistema

⏱ Duración estimada: ~60 min

## Objetivo

Llevar lo que copias en tmux al portapapeles de tu sistema con la herramienta correcta para macOS, WSL, Wayland o X11, conectada a `copy-command`.

## Contexto

- Cada sistema tiene su herramienta y su trampa: `clip.exe` rompe la ñ, `xclip` sin opciones copia en la selección equivocada, WSL con WSLg también define `DISPLAY`.
- `copiar.sh` recibe el texto por stdin y elige la herramienta. tmux lo llama desde `copy-command`, así que `y`, `Enter` y el ratón copian al mismo sitio.
- Los pasos 1 a 4 se hacen **en tu máquina**, fuera del laboratorio: el contenedor no tiene portapapeles. Los pasos 5 y 6 funcionan en los dos sitios, con herramientas falsas que anotan lo que reciben (`3-proyecto/tests/path-falso`).

## Instrucciones

1. **¿Dónde estás?** En tu terminal, fuera de tmux y del laboratorio:
   ```bash
   uname; echo "WSL=${WSL_DISTRO_NAME:-} WAYLAND=${WAYLAND_DISPLAY:-} DISPLAY=${DISPLAY:-}"
   ```
   | Ves | Sistema | Herramienta |
   |---|---|---|
   | `Darwin` | macOS | `pbcopy` |
   | `WSL=Ubuntu...` | WSL | `win32yank.exe` o `clip.exe` |
   | `WAYLAND=wayland-0` | Linux con Wayland | `wl-copy` |
   | `DISPLAY=:0` y nada más | Linux con X11 | `xclip` o `xsel` |

   En WSL con WSLg verás las tres variables: por eso `copiar.sh` mira WSL
   primero.

2. Copia y pega con la herramienta de tu sistema, sin tmux. En macOS:
   `printf hola | pbcopy`, y `Cmd+V` en el navegador. Sigue en el paso que te
   toca.

3. **WSL: la ñ.** Copia con `clip.exe` y lee el portapapeles de Windows:
   ```bash
   printf 'año\n' | clip.exe
   powershell.exe -NoProfile -Command Get-Clipboard
   ```
   ```
   aÃ±o
   ```
   `clip.exe` interpreta los bytes con la página de códigos de Windows (si
   activaste la opción beta de UTF-8 de Windows, quizá salga bien). Si
   `clip.exe` no se encuentra, tu WSL no añade las rutas de Windows al `PATH`
   (`appendWindowsPath` en `/etc/wsl.conf`): está en
   `/mnt/c/Windows/System32/clip.exe`. Instala `win32yank.exe`, que respeta UTF-8:
   ```bash
   sudo apt install unzip
   curl -sLo /tmp/w.zip https://github.com/equalsraf/win32yank/releases/download/v0.1.1/win32yank-x64.zip
   mkdir -p ~/.local/bin && unzip -p /tmp/w.zip win32yank.exe > ~/.local/bin/win32yank.exe
   chmod +x ~/.local/bin/win32yank.exe
   printf 'año' | win32yank.exe -i; win32yank.exe -o      # año
   ```
   Resuelve el `TODO 1` de `starter/copiar.sh`: `win32yank.exe -i` si está,
   `clip.exe` si no.

4. **X11: dos portapapeles.** Copia con `xclip` sin opciones e intenta pegar
   con `Ctrl+V`:
   ```bash
   printf hola | xclip
   xclip -o                         # hola
   xclip -o -selection clipboard    # otra cosa: lo que copiaste antes
   ```
   Sin opciones, `xclip` escribe en **PRIMARY**, la selección que se pega con
   el botón central. `Ctrl+V` lee **CLIPBOARD**. Resuelve el `TODO 2`:
   `xclip -selection clipboard`, o `xsel --clipboard --input` si no hay
   `xclip`. (En Wayland, `wl-copy` ya escribe en el portapapeles correcto.)

5. **Pruébalo sin tu portapapeles.** `path-falso` crea un `PATH` donde las
   herramientas de portapapeles son falsas: guardan su entrada en
   `NOMBRE.datos` y sus argumentos en `NOMBRE.args`.
   ```bash
   F=../../3-proyecto/tests/path-falso
   f=$($F xclip); printf hola | env -i PATH="$f" DISPLAY=:0 ./starter/copiar.sh
   cat "$f/xclip.datos" "$f/xclip.args"
   f=$($F clip.exe win32yank.exe); printf año | env -i PATH="$f" WSL_DISTRO_NAME=Ubuntu ./starter/copiar.sh
   ls "$f" | grep datos
   f=$($F); printf x | env -i PATH="$f" DISPLAY=:0 ./starter/copiar.sh; echo $?
   ```
   ```
   hola-selection clipboard
   win32yank.exe.datos
   copiar.sh: instala xclip (sudo apt install xclip)
   1
   ```
   `env -i` vacía el entorno: así decides qué sistema "ve" el script.

6. **Conéctalo a tmux.** Resuelve el `TODO 3` de `starter/tmux.conf` y
   mira qué ruta queda:
   ```bash
   tmux -L lab -f starter/tmux.conf new -d \; show -sv copy-command
   ```
   ```
   starter/copiar.sh
   ```
   Relativa: `current_file` es la ruta que pasaste a `-f`, tal cual. Y
   `copy-command` se ejecuta desde tu `$HOME`, donde `starter/copiar.sh` no
   existe: copiarías sin error visible y sin resultado. Pasa siempre una ruta
   absoluta (al instalar el kit en `~/.config/tmux` ya lo es):
   ```bash
   tmux -L lab kill-server
   tmux -L lab -f "$PWD/starter/tmux.conf"
   tmux -L lab show -sv copy-command      # /ruta/completa/.../starter/copiar.sh
   ```
   En tu máquina: copia con `v` ... `y` en copy mode, o arrastrando con el
   ratón, y pega con `Ctrl+V` (`Cmd+V`) en el navegador. En el laboratorio,
   arranca el servidor con herramientas falsas y mira qué recibe `xclip`:
   ```bash
   tmux -L lab kill-server
   f=$(../../3-proyecto/tests/path-falso xclip)
   env -i PATH="$f" HOME="$HOME" TERM="$TERM" DISPLAY=:0 tmux -L lab -f "$PWD/starter/tmux.conf"
   # copia algo con v ... y, sal con prefix d
   cat "$f/xclip.datos"
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Explicas qué sistema tienes y por qué `copiar.sh` mira WSL antes que Wayland
- [ ] Reproduces el problema de tu sistema (la ñ con `clip.exe` o PRIMARY con `xclip`) y lo resuelves
- [ ] Las tres pruebas del paso 5 dan la salida esperada
- [ ] `tmux -L lab show -sv copy-command` imprime una ruta absoluta que termina en `/copiar.sh`, y explicas por qué con `-f starter/tmux.conf` no lo es
- [ ] Copias en copy mode y pegas fuera de tmux con `Ctrl+V` (o, en el laboratorio, `xclip.datos` tiene lo que copiaste)
- [ ] `shellcheck starter/copiar.sh` no muestra avisos

## Reto extra

Entra por SSH a otra máquina (o a `localhost`) y prueba allí `copiar.sh`. ¿En
el portapapeles de qué máquina acaba el texto? El lab 06 lo resuelve.
