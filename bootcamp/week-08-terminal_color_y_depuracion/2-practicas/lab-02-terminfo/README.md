# Lab 02 — terminfo

⏱ Duración estimada: ~60 min

## Objetivo

Leer con `infocmp` y `tput` qué promete una entrada terminfo y compilar con `tic`, en un directorio temporal, una entrada propia que le enseña a tmux que tu terminal tiene color de 24 bits.

## Contexto

- terminfo es una base de datos: un archivo por `TERM` con sus capacidades. Booleanas (`RGB,`), números (`colors#256`) y cadenas (`sitm=\E[3m`, la que activa la cursiva). `infocmp` las enseña; `tput` imprime una.
- Las entradas se buscan en `$TERMINFO`, luego en `~/.terminfo` y luego en las del sistema (`infocmp -D`). En este lab **solo** usas `TERMINFO=/tmp/lab08/terminfo`: el del sistema y tu `~/.terminfo` no se tocan.
- tmux lee la entrada del `TERM` de cada cliente al conectarse. Capacidades como `RGB` se convierten en features del cliente (`#{client_termfeatures}`).

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/2-practicas/lab-02-terminfo
   ```
   El servidor es `-L lab` y arranca con `-f /dev/null` (sin config): el
   prefix es **`C-b`**.

1. **Qué promete `tmux-256color`.** En la terminal A:
   ```bash
   infocmp -1x tmux-256color | grep -E '^\s(colors|sitm|Ms|Smulx|RGB|Tc|Setulc)[#=,]'
   ```
   ```
   	colors#0x100,
   	sitm=\E[3m,
   	Ms=\E]52;%p1%s;%p2%s\007,
   	Smulx=\E[4:%p1%dm,
   ```
   `-1` pone una capacidad por línea y `-x` incluye las extendidas
   (`Ms`, `Smulx`). `colors#0x100` es 256 en hexadecimal. `Ms` es el
   portapapeles por OSC 52 (semana 04) y `Smulx` el estilo de subrayado.
   No están `RGB`, `Tc` ni `Setulc`: `tmux-256color` no promete color de 24
   bits porque no sabe en qué terminal lo vas a usar.

2. **Una capacidad suelta con `tput`.**
   ```bash
   tput -T tmux-256color colors
   tput -T tmux-256color sitm | cat -v; echo
   tput -T screen-256color sitm; echo $?
   ```
   ```
   256
   ^[[3m
   1
   ```
   `screen-256color` no tiene cursiva: un programa que la pide no recibe
   nada (por eso la cursiva salía como vídeo inverso en tmux antiguos que
   usaban `screen-256color`).

3. **Dónde vive.**
   ```bash
   infocmp -D
   ls -l /usr/share/terminfo/t/tmux-256color
   dpkg -S /usr/share/terminfo/t/tmux-256color
   ```
   Algo como (cambia la fecha):
   ```
   /etc/terminfo
   /usr/share/terminfo
   -rw-r--r-- 1 root root 3458 Aug 31 11:36 /usr/share/terminfo/t/tmux-256color
   ncurses-base: /usr/share/terminfo/t/tmux-256color
   ```
   En Ubuntu 24.04 `tmux-256color` viene en `ncurses-base`, que siempre
   está instalado. Las entradas de terminales menos comunes
   (`alacritty`, `foot`...) están en `ncurses-term`
   (`sudo apt install ncurses-term`).

   **En macOS** el ncurses del sistema es antiguo y no trae
   `tmux-256color`: `/usr/bin/infocmp tmux-256color` falla. El arreglo
   habitual es exportar la entrada con el ncurses de Homebrew y compilarla
   en tu `~/.terminfo` (no lo hemos podido probar en el laboratorio, que es
   Linux; compruébalo con el último comando):
   ```bash
   brew install ncurses
   "$(brew --prefix ncurses)/bin/infocmp" -x tmux-256color > /tmp/tmux-256color.src
   /usr/bin/tic -x -o ~/.terminfo /tmp/tmux-256color.src
   /usr/bin/infocmp -x tmux-256color | head -2
   ```

4. **Compila la entrada del starter** (todavía sin los TODOs). `tic` crea
   el directorio que le digas en `TERMINFO`:
   ```bash
   mkdir -p /tmp/lab08
   TERMINFO=/tmp/lab08/terminfo tic -x starter/kit-256color.ti; echo $?
   find /tmp/lab08/terminfo -type f
   ```
   ```
   0
   /tmp/lab08/terminfo/k/kit-256color
   ```
   Una carpeta por primera letra y un archivo por nombre. Sin `TERMINFO`
   nadie la encuentra; con él, sí:
   ```bash
   infocmp kit-256color; echo $?
   TERMINFO=/tmp/lab08/terminfo infocmp -1x kit-256color | head -3
   TERMINFO=/tmp/lab08/terminfo tput -T kit-256color colors
   ```
   ```
   infocmp: couldn't open terminfo file /usr/share/terminfo/k/kit-256color.
   1
   #	Reconstructed via infocmp from file: /tmp/lab08/terminfo/k/kit-256color
   kit-256color|tmux-256color del lab 02 con color de 24 bits,
   	OTbs,
   256
   ```
   `colors` vale 256 sin escribirlo: lo hereda de `use=tmux-256color`.

5. **Conéctate con la entrada nueva.** En la terminal A:
   ```bash
   tmux -L lab -f /dev/null new -d -s api; echo $?
   ```
   ```
   0
   ```
   En la terminal B, primero normal:
   ```bash
   tmux -L lab attach -t api
   ```
   En la A:
   ```bash
   tmux -L lab list-clients -F '#{client_termname} #{client_termfeatures}'
   ```
   En el laboratorio Docker (en tu equipo puede salir alguna feature más:
   tmux pregunta a algunas terminales quiénes son y añade las suyas):
   ```
   xterm-256color bpaste,ccolour,clipboard,cstyle,focus,title
   ```
   Sal de la B con `C-b` `d` y vuelve a conectarte con tu entrada. El
   cliente es el que lee terminfo, así que `TERMINFO` va en su comando:
   ```bash
   TERMINFO=/tmp/lab08/terminfo TERM=kit-256color tmux -L lab attach -t api
   ```
   En la A:
   ```bash
   tmux -L lab list-clients -F '#{client_termname} #{client_termfeatures}'
   C=$(tmux -L lab list-clients -F '#{client_name}')
   tmux -L lab show-messages -T -t "$C" | grep -E ' (colors|RGB|Setulc|Smulx): '
   ```
   ```
   kit-256color bpaste,focus,title
     13: colors: (number) 256
    199: RGB: [missing]
    211: Setulc: [missing]
    221: Smulx: (string) \033[4:%p1%dm
   ```
   `show-messages -T` es la lista de capacidades que tmux cargó **para ese
   cliente**: lo que crees que tiene tu terminal no importa, importa esto.
   Ojo: sin el `TERMINFO=` delante, la B imprime
   `missing or unsuitable terminal: kit-256color` (lab-01).

6. **Los TODOs de `starter/kit-256color.ti`.** Tras cada uno, en la A,
   recompila (`tic` sobrescribe el archivo):
   `TERMINFO=/tmp/lab08/terminfo tic -x starter/kit-256color.ti; echo $?`
   (imprime `0`). Las capacidades van antes de `use=`, cada una con un
   tabulador delante y una coma al final.

   1. **TODO 1: `RGB`.** Pista: una línea `	RGB,`.
      ```bash
      TERMINFO=/tmp/lab08/terminfo infocmp -1x kit-256color | grep -E '^\sRGB,'
      ```
      ```
      	RGB,
      ```
   2. **TODO 2: `Setulc`.** Pista: copia la línea entera de la pista; los
      `:` del valor son literales.
      ```bash
      TERMINFO=/tmp/lab08/terminfo infocmp -1x kit-256color | grep Setulc
      ```
      ```
      	Setulc=\E[58:2::%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
      ```
   3. **Reconecta.** tmux leyó terminfo al conectarse la B: recompilar no
      cambia un cliente ya conectado. Sal de la B con `C-b` `d` y vuelve a
      conectarte con el mismo comando del paso 5. En la A:
      ```bash
      tmux -L lab list-clients -F '#{client_termname} #{client_termfeatures}'
      C=$(tmux -L lab list-clients -F '#{client_name}')
      tmux -L lab show-messages -T -t "$C" | grep -E ' (colors|RGB|Setulc|Smulx): '
      ```
      ```
      kit-256color bpaste,focus,RGB,title
        13: colors: (number) 256
       199: RGB: (flag) true
       211: Setulc: (string) \033[58:2::%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm
       221: Smulx: (string) \033[4:%p1%dm
      ```
      `RGB` aparece en las features sin tocar la config de tmux: la puso
      terminfo. En la B escribe
      `printf '\e[38;2;255;100;0mNARANJA\e[0m\n'`: tmux ya manda el color
      tal cual a tu terminal (lab-03 lo comprueba byte a byte).

7. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A, el servidor y la entrada temporal:
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab08/terminfo; infocmp kit-256color >/dev/null 2>&1; echo $?
   ```
   ```
   1
   ```

## Criterios de éxito

- [ ] Explicas qué significan `colors#0x100`, `sitm` y `Smulx` y por qué `tmux-256color` no trae `RGB` (paso 1)
- [ ] `TERMINFO=/tmp/lab08/terminfo infocmp kit-256color` funciona y sin `TERMINFO` falla (paso 4)
- [ ] `infocmp -1x kit-256color` muestra `RGB,` y `Setulc=...` (pasos 6.1 y 6.2)
- [ ] Con la B conectada como `kit-256color`, `#{client_termfeatures}` incluye `RGB` y `show-messages -T` dice `RGB: (flag) true` (paso 6.3)
- [ ] Explicas por qué hay que reconectar el cliente tras recompilar (paso 6.3)
- [ ] No has escrito nada en `/usr/share/terminfo`, `/etc/terminfo` ni `~/.terminfo` (todo en `/tmp/lab08`)

## Reto extra

Compara tu entrada con la de base: `TERMINFO=/tmp/lab08/terminfo infocmp -x
kit-256color tmux-256color` imprime solo las diferencias. Añade después
`sitm@,` (la `@` cancela una capacidad heredada), recompila y comprueba con
`tput -T kit-256color sitm; echo $?` que la cursiva ya no existe. ¿Qué le
pasaría a la cursiva de tu editor con esa entrada?
