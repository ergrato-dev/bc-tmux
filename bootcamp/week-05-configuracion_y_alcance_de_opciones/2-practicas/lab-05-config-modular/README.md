# Lab 05 — Config modular

⏱ Duración estimada: ~60 min

## Objetivo

Dividir una config en un punto de entrada y módulos de `conf.d/` que cargan en orden desde cualquier directorio, y comprobar con un script que cada módulo carga por sí solo.

## Contexto

- `tmux.conf` queda como punto de entrada: guarda su directorio en `@lab-dir` y carga `conf.d/*.conf`. El glob se ordena por nombre.
- `#{d:current_file}` es el directorio del archivo **que se está leyendo**: en un módulo de `conf.d/`, es `conf.d/`.
- Un `local.conf` opcional, fuera de git, guarda lo propio de cada máquina.

## Instrucciones

1. Lee `starter/tmux.conf`: opciones, prefix y teclas en un solo archivo. Al
   terminar el lab tendrás:
   ```
   starter/
   ├── tmux.conf              # solo @lab-dir y source-file
   ├── conf.d/
   │   ├── 10-opciones.conf
   │   └── 20-bindings.conf
   └── bin/copiar
   ```

2. **Divide.** Crea `starter/conf.d/` y mueve las líneas: las opciones a
   `10-opciones.conf`; prefix y teclas a `20-bindings.conf`. En
   `tmux.conf` resuelve el `TODO 1` y, para el `TODO 2`, empieza por lo
   evidente:
   ```tmux
   source-file conf.d/*.conf
   ```
   Desde el directorio del lab, funciona:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index    # 1
   tmux -L lab kill-server
   ```

3. **Desde otro directorio.** Repite desde `/`:
   ```bash
   (cd / && tmux -L lab -f "$OLDPWD/starter/tmux.conf" new -d)
   tmux -L lab show -gv base-index; tmux -L lab kill-server
   ```
   ```
   0
   ```
   Al arrancar, ni un aviso: no cargó ningún módulo. La ruta relativa se resuelve desde el
   directorio en el que arrancas tmux, no desde el archivo. Usa `@lab-dir`:
   ```tmux
   source-file -F "#{@lab-dir}/conf.d/*.conf"
   ```
   Repite: `1`.

4. **Rutas dentro de un módulo.** `copy-command` vino de `tmux.conf` con
   `#{d:current_file}`. Mira a dónde apunta ahora:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -sv copy-command
   ```
   ```
   /ruta/a/starter/conf.d/bin/copiar
   ```
   `current_file` ya es `conf.d/10-opciones.conf`, y `conf.d/bin/copiar` no
   existe: copiar no haría nada, sin error. Cambia la ruta a
   `"#{@lab-dir}/bin/copiar"` y comprueba que `test -x` sobre ella sale con 0.
   `tmux -L lab kill-server`.

5. **El orden.** Crea `starter/conf.d/5-prueba.conf` con
   `set -g base-index 5`:
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d \; show -gv base-index    # 5
   tmux -L lab kill-server
   ```
   Querías que fuera una base que `10-opciones.conf` afina, pero `5-` va
   **después** de `20-` en orden alfabético y gana. Renómbralo a
   `05-prueba.conf`: ahora carga primero y sale `1`. Siempre dos cifras.
   Borra el archivo de prueba.

6. **Lo de cada máquina.** Añade al final de `tmux.conf`:
   ```tmux
   source-file -qF "#{@lab-dir}/local.conf"
   ```
   Sin `local.conf`, `-q` no se queja. Crea uno con
   `set -g status-style bg=colour22`, arranca y verás la barra verde. Añade
   `local.conf` a un `.gitignore` en `starter/`: no se versiona.

7. **Por versión.** En `10-opciones.conf`, un bloque que solo se aplica en
   tmux 3.5 o posterior:
   ```tmux
   %if "#{>=:#{version},3.5}"
   set -g @lab-moderno on
   %else
   set -g @lab-moderno off
   %endif
   ```
   `tmux -L lab show -gv @lab-moderno` imprime `off` en el laboratorio (3.4).
   Se evalúa al leer el archivo, sin lanzar ninguna shell.

8. **Cada módulo, por separado.** Completa `starter/verificar-modulos.sh`:
   carga cada archivo de `conf.d/` en un servidor limpio y dice cuáles fallan.
   ```bash
   ./starter/verificar-modulos.sh starter
   echo 'set -g base-indx 5' > starter/conf.d/30-roto.conf
   ./starter/verificar-modulos.sh starter; echo $?
   rm starter/conf.d/30-roto.conf
   ```
   ```
   ok     10-opciones.conf
   ok     20-bindings.conf
   ok     10-opciones.conf
   ok     20-bindings.conf
   error  30-roto.conf: invalid option: base-indx
   1
   ```

9. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] `starter/tmux.conf` no tiene ningún `set` salvo el de `@lab-dir`, ni ningún `bind`
- [ ] Arrancando desde `/`, `show -gv base-index` imprime `1`
- [ ] `show -sv copy-command` apunta a un `bin/copiar` que existe
- [ ] Explicas por qué `5-prueba.conf` ganaba a `10-opciones.conf`
- [ ] Con y sin `local.conf`, la config carga sin errores
- [ ] `verificar-modulos.sh` da las salidas del paso 8 y `shellcheck` no muestra avisos

## Reto extra

Haz que `prefix` `R` (mayúscula) abra en una ventana nueva `$EDITOR` sobre
`conf.d/` y recargue al cerrar el editor. Pista: `new-window` acepta un
comando, y `source-file` puede ir detrás con `;`.
