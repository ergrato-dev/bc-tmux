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

1. **Desde tu home.** Arranca la config desde otro directorio y pregunta:
   ```bash
   (cd ~ && tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d -s s)
   tmux -L lab show -gv prefix \; show -gv base-index
   ```
   ```
   C-b
   0
   ```
   Ni el prefix ni nada: no cargó ningún módulo. El error (`No such file or
   directory`) llega tarde o nunca, según cómo arranques tmux.
   `source-file conf.d/*.conf` se resolvió desde `~`. **Error 1.** Usa
   `@lab-dir` y `source-file -F`, como en el lab 05. Recarga
   (`tmux -L lab kill-server` y arranca otra vez desde `~`): `C-a`.

2. **Ventanas desde 0.** `10-opciones.conf` dice `base-index 1` y
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
   starter/conf.d/10-opciones.conf
   starter/conf.d/20-bindings.conf
   starter/conf.d/5-base.conf
   ```
   `5-base.conf` iba a ser la base y es lo último que se carga. **Error 4**
   (lo verás antes que el 2 y el 3). Renómbralo a `05-base.conf`.

3. **La barra sin color.**
   ```bash
   tmux -L lab kill-server
   (cd ~ && tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d -s s)
   tmux -L lab show -A -t s status-style
   ```
   ```
   status-style* bg=green,fg=black
   ```
   El `*` dice que la sesión hereda el valor por defecto: la línea de
   `10-opciones.conf` no se aplicó. Cárgala a mano para ver el error:
   ```bash
   tmux -L lab -f /dev/null new -d -s vacia 2>/dev/null; tmux -L lab source-file starter/conf.d/10-opciones.conf
   ```
   Si no ves error es porque ahora sí hay una sesión actual: `set` sin `-g`
   la cambió a ella, solo a ella. Al arrancar no había ninguna (`no current
   session`). **Error 3.** Añade `-g`.

4. **`prefix` `r`.** Conéctate (`tmux -L lab attach -t s`) y pulsa `prefix`
   `r`: no aparece `config recargada`. Mira la tecla:
   ```bash
   tmux -L lab list-keys -T prefix r
   ```
   Recarga `~/.tmux.conf`, la config vieja. Si no existe, `source-file` falla
   y el `display` no se ejecuta; si existe, carga **otra** config encima de
   esta. **Error 2.** Recarga `"#{@lab-dir}/tmux.conf"` con `-F`.

5. **Comprueba todo desde `/`.**
   ```bash
   tmux -L lab kill-server
   (cd / && tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d -s s)
   tmux -L lab show -gv prefix \; show -gv base-index \; show -gv history-limit \; show -A -t s status-style
   ```
   ```
   C-a
   1
   50000
   status-style* bg=colour24,fg=colour255
   ```
   Ahora el `*` es correcto: la sesión hereda el global que fijaste. Conéctate
   y pulsa `prefix` `r`: `config recargada`. Si hiciste el lab 05,
   `verificar-modulos.sh starter` da `ok` en los tres módulos.

6. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Los cuatro errores identificados, con una línea por cada uno explicando el síntoma y la causa
- [ ] La config carga igual desde `~`, desde `/` y desde el directorio del lab
- [ ] `tmux -L lab show -gv base-index` imprime `1` y `history-limit`, `50000`
- [ ] `tmux -L lab show -A -t s status-style` muestra `bg=colour24` como valor global heredado
- [ ] `prefix` `r` recarga esta config y muestra `config recargada`

## Reto extra

El compañero quiere que los módulos de su portátil no se suban a git, pero sí
los comunes. Propón una convención de nombres en `conf.d/` y la línea de
`tmux.conf` que la soporta, sin romper el orden de carga.
