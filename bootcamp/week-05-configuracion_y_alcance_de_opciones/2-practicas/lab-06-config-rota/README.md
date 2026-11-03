# Lab 06 — La config rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de una config modular que "funciona en mi repo", usando `show -A`, `source-file` y `list-keys`.

## Contexto

Un compañero dividió su config en módulos y te la pasa: `starter/tmux.conf`
y tres archivos en `starter/conf.d/`. Dice que en su repositorio funciona. Tú
la arrancas desde tu home y no hay prefix nuevo, la barra no tiene su color,
las ventanas empiezan en 0 y `prefix` `r` no hace nada visible. Hay **cuatro
errores reales**, todos de esta semana.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-06-config-rota
   ```
   El servidor es `-L lab`. Para hacer de "tu home" sin tocar el real, la
   terminal A usa un `HOME` vacío: si tienes un `~/.tmux.conf` de verdad, el
   error 2 lo cargaría en el servidor del lab y te confundiría.
   ```bash
   export H=$(mktemp -d)
   arrancar() { (cd "$1" && env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d -s s); }
   ```
   ```
   (sin salida)
   ```
   `arrancar DIR` arranca el servidor desde `DIR` con la config del
   compañero (`$OLDPWD`, dentro del paréntesis, es la carpeta del lab). `H`
   y `arrancar` solo existen en la terminal A.

1. **Desde tu home.** En la terminal A:
   ```bash
   arrancar "$H"
   tmux -L lab show -gv prefix \; show -gv base-index
   tmux -L lab source-file /dev/null
   ```
   Algo como (la ruta es la de tu repositorio):
   ```
   C-b
   0
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-06-config-rota/starter/tmux.conf:9: conf.d/*.conf: No such file or directory
   ```
   Ni el prefix ni nada: no cargó ningún módulo. El error existía, pero con
   `new -d` se queda guardado hasta el primer cliente o el primer
   `source-file` (lab 01, paso 4). `source-file conf.d/*.conf` se resolvió
   desde el directorio de arranque (`$H`). **Error 1.** En
   `starter/tmux.conf`, guarda el directorio y úsalo con `-F`, como en el
   lab 05:
   ```tmux
   set -gF @lab-dir "#{d:current_file}"
   source-file -F "#{@lab-dir}/conf.d/*.conf"
   ```
   ```bash
   tmux -L lab kill-server
   arrancar "$H"
   tmux -L lab show -gv prefix
   ```
   ```
   C-a
   ```
   Desde aquí, el servidor del lab usa el prefix del compañero: **`C-a`**.

2. **Ventanas desde 0.** `10-options.conf` dice `base-index 1` y
   `history-limit 50000`, pero:
   ```bash
   tmux -L lab show -gv base-index \; show -gv history-limit
   ```
   ```
   0
   5000
   ```
   ¿Quién carga después? Lista los módulos en el orden del glob:
   ```bash
   printf '%s\n' starter/conf.d/*.conf
   ```
   ```
   starter/conf.d/10-options.conf
   starter/conf.d/20-bindings.conf
   starter/conf.d/5-base.conf
   ```
   `5-base.conf` iba a ser la base y es lo último que se carga. **Error 4**
   (lo ves antes que el 2 y el 3). Renómbralo y reinicia:
   ```bash
   mv starter/conf.d/5-base.conf starter/conf.d/05-base.conf
   tmux -L lab kill-server
   arrancar "$H"
   tmux -L lab show -gv base-index \; show -gv history-limit
   ```
   ```
   1
   50000
   ```

3. **La barra sin color.** Sobre el servidor recién arrancado:
   ```bash
   tmux -L lab show -A -t s status-style
   tmux -L lab source-file /dev/null
   ```
   Algo como:
   ```
   status-style* bg=green,fg=black
   /bc-tmux/bootcamp/week-05-configuracion_y_alcance_de_opciones/2-practicas/lab-06-config-rota/starter/conf.d/10-options.conf:8: no current session
   ```
   El `*` dice que la sesión hereda el valor por defecto: la línea 8 de
   `10-options.conf` (`set status-style ...`, sin `-g`) falló al arrancar,
   porque todavía no había ninguna sesión. Y cargada a mano, con el
   servidor vivo, parece que funciona:
   ```bash
   tmux -L lab source-file "$PWD/starter/conf.d/10-options.conf"; echo $?
   tmux -L lab show -A -t s status-style
   ```
   ```
   0
   status-style bg=colour24,fg=colour255
   ```
   Sin `*`: ahora sí había una sesión actual (`s`) y `set` sin `-g` la
   cambió a ella, solo a ella. Una sesión nueva seguiría sin color.
   **Error 3.** Añade `-g` a esa línea.

4. **`prefix` `r`.** Mira la tecla (terminal A):
   ```bash
   tmux -L lab list-keys -T prefix r
   ```
   Algo como (es tu `$H`):
   ```
   bind-key -T prefix r source-file /tmp/tmp.b4gDVV8Ge3/.tmux.conf \; display-message "config recargada"
   ```
   El `~` se expandió al leer la config, con el `HOME` del servidor: recarga
   `~/.tmux.conf`, la config vieja. En la terminal B:
   ```bash
   tmux -L lab attach -t s
   ```
   Pulsa `C-a` `r`. La barra muestra
   `/tmp/tmp.b4gDVV8Ge3/.tmux.conf: No such file or directory` y no
   `config recargada`: `source-file` falló y el `display` no se ejecutó. Si
   ese archivo existiera, cargaría **otra** config encima de esta. Sal con
   `C-a` `d`: `[detached (from session s)]`. **Error 2.** En
   `20-bindings.conf`, recarga el punto de entrada de este kit:
   ```tmux
   bind r source-file -F "#{@lab-dir}/tmux.conf" \; display "config recargada"
   ```

5. **Comprueba todo desde tres directorios.** En la terminal A, desde tu
   home falso, desde `/` y desde la carpeta del lab:
   ```bash
   for d in "$H" / "$PWD"; do
     tmux -L lab kill-server 2>/dev/null
     arrancar "$d"
     tmux -L lab show -gv prefix \; show -gv base-index \; show -gv history-limit \; show -A -t s status-style
     tmux -L lab source-file /dev/null
   done
   ```
   Las mismas cuatro líneas tres veces, sin ningún error:
   ```
   C-a
   1
   50000
   status-style* bg=colour24,fg=colour255
   C-a
   1
   50000
   status-style* bg=colour24,fg=colour255
   C-a
   1
   50000
   status-style* bg=colour24,fg=colour255
   ```
   Ahora el `*` es correcto: la sesión hereda el global que fijaste. En la
   terminal B, `tmux -L lab attach -t s` y pulsa `C-a` `r`:
   `config recargada`. Sal con `C-a` `d`.

   Si hiciste el lab 05, comprueba cada módulo por separado con tu script
   (o con el de la solución, `../lab-05-config-modular/solucion/check-modules.sh`):
   ```bash
   ../lab-05-config-modular/starter/check-modules.sh starter; echo $?
   ```
   ```
   ok     05-base.conf
   ok     10-options.conf
   ok     20-bindings.conf
   0
   ```

6. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server; rm -rf "$H"; unset H
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Los cuatro errores identificados, con una línea por cada uno explicando el síntoma y la causa (pasos 1-4)
- [ ] La config carga igual desde `$H`, desde `/` y desde el directorio del lab (paso 5)
- [ ] `tmux -L lab show -gv base-index` imprime `1` y `history-limit`, `50000` (paso 5)
- [ ] `tmux -L lab show -A -t s status-style` muestra `bg=colour24` como valor global heredado (paso 5)
- [ ] `C-a` `r` recarga esta config y muestra `config recargada` (paso 5)

## Reto extra

El compañero quiere que los módulos de su portátil no se suban a git, pero sí
los comunes. Propón una convención de nombres en `conf.d/` y la línea de
`tmux.conf` que la soporta, sin romper el orden de carga.
