# Lab 01 — TPM desde cero

⏱ Duración estimada: ~60 min

## Objetivo

Instalar TPM fijado por versión, declarar e instalar tmux-resurrect sin teclado, comprobar qué cambió en el servidor y retirarlo después.

## Contexto

- TPM es un repositorio de scripts bash. `run-shell .../tpm/tpm` al final de la config crea tres teclas (`prefix` `I` instala, `prefix` `U` actualiza, `prefix` `M-u` limpia) y ejecuta cada plugin ya instalado.
- La lista de plugins no se la pide a tmux: TPM busca las líneas `set -g @plugin '...'` con `awk` dentro de `~/.config/tmux/tmux.conf`. Para tmux, `@plugin` es una opción normal y solo guarda la última.
- `usuario/repo#tag` fija la versión. Sin tag, cada máquina clona lo que haya ese día en la rama principal.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux** (`echo "$TMUX"` vacío), desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero
   ```
   Prepara el HOME aislado del lab: `home/.config/tmux` apunta a `starter/`,
   así que para TPM tu config es `starter/tmux.conf` y los plugins acaban en
   `starter/plugins/`. Tu `~/.config/tmux` real no se toca:
   ```bash
   mkdir -p home/.config && ln -s ../../starter home/.config/tmux
   ls -l home/.config | tail -1
   ```
   Algo como (cambian la fecha y el usuario):
   ```
   lrwxrwxrwx 1 alumno alumno 13 Nov  3 19:53 tmux -> ../../starter
   ```
   Arranca el servidor `-L lab` con ese HOME
   ([Antes de cada lab](../README.md#antes-de-cada-lab), paso 3) y define
   `lab_tpm`, que ejecuta un script de `tpm/bin/` contra este servidor:
   ```bash
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab; echo $?
   lab_tpm() { local s=$1; shift; env -u XDG_CONFIG_HOME HOME="$PWD/home" TMUX="$(tmux -L lab display -p '#{socket_path}'),0,0" "$PWD/starter/plugins/tpm/bin/$s" "$@"; }
   ```
   ```
   0
   ```
   TPM llama a `tmux` a secas: sin el `TMUX=...` hablaría con tu servidor
   de siempre, no con `-L lab`.

1. **Clona TPM fijado.** `--branch` acepta un tag; `--depth 1` baja solo esa
   versión:
   ```bash
   git -c advice.detachedHead=false clone -q --depth 1 --branch v3.1.0 https://github.com/tmux-plugins/tpm starter/plugins/tpm; echo $?
   git -C starter/plugins/tpm describe --tags
   tmux -L lab list-keys -T prefix I; echo $?
   ```
   ```
   0
   v3.1.0
   unknown key: I
   1
   ```
   Clonado no basta: hasta que la config ejecute `tpm`, no hay teclas.

2. **TODO 1 y TODO 2 — declara y ejecuta.** En `starter/tmux.conf` quita el
   `#   ` de las dos líneas `set -g @plugin` (TODO 1) y de la línea
   `run-shell` (TODO 2), que queda la última del archivo. Recarga:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab show -g @plugin
   tmux -L lab show-environment -g TMUX_PLUGIN_MANAGER_PATH
   tmux -L lab list-keys -T prefix | grep tpm
   ```
   Algo como (la ruta es la de tu carpeta del lab):
   ```
   0
   @plugin "tmux-plugins/tmux-resurrect#v4.0.0"
   TMUX_PLUGIN_MANAGER_PATH=/bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/
   bind-key    -T prefix I       run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tpm/bindings/install_plugins
   bind-key    -T prefix U       run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tpm/bindings/update_plugins
   bind-key    -T prefix M-u     run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tpm/bindings/clean_plugins
   ```
   `@plugin` solo guarda resurrect: la línea de TPM la pisó la siguiente. Da
   igual, porque TPM lee el archivo, no la opción. `tpm` dejó en el entorno
   global la carpeta donde instala (`~/.config/tmux/plugins/` del HOME del
   servidor).

   Si arrancaste el servidor con el `run-shell` ya descomentado y TPM sin
   clonar, el paso 3 dice `FATAL: Tmux Plugin Manager not configured in
   tmux.conf`: recarga después de clonar y repite.

3. **Instala sin teclado.** Es lo que hace `prefix` `I` en un cliente
   conectado (que además recarga la config antes y después):
   ```bash
   lab_tpm install_plugins; echo $?
   ls starter/plugins
   git -C starter/plugins/tmux-resurrect describe --tags
   ```
   ```
   Already installed "tpm"
   Installing "tmux-resurrect"
     "tmux-resurrect" download success
   0
   tmux-resurrect
   tpm
   v4.0.0
   ```

4. **Instalado no es cargado.** `install_plugins` solo clona. El plugin se
   ejecuta la próxima vez que corre `tpm`, es decir, al recargar:
   ```bash
   tmux -L lab list-keys -T prefix C-s; echo $?
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab list-keys -T prefix | grep resurrect
   tmux -L lab show -g | grep -E '^@resurrect-(save|restore)-script'
   ```
   ```
   unknown key: C-s
   1
   bind-key    -T prefix C-r     run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
   bind-key    -T prefix C-s     run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
   @resurrect-restore-script-path /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh
   @resurrect-save-script-path /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
   ```
   Todo lo que añadió el plugin son `bind-key` y `set -g` corrientes: no
   hay nada que no pudieras escribir tú.

5. **Por qué `run-shell` va al final.** resurrect elige la tecla de guardar
   leyendo `@resurrect-save` cuando se carga. Añade esta línea **al final**
   del archivo, debajo del `run-shell`:
   ```tmux
   set -g @resurrect-save 'S'
   ```
   Una recarga no borra la `C-s` que ya existe; reinicia el servidor para
   verlo limpio:
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   tmux -L lab show -gv @resurrect-save
   tmux -L lab list-keys -T prefix | grep save.sh
   ```
   ```
   S
   bind-key    -T prefix C-s     run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
   ```
   La opción vale `S`, pero llegó después de que el plugin se ejecutara.
   Mueve la línea **encima** del `run-shell` y repite los cuatro comandos:
   ```
   S
   bind-key    -T prefix S       run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-01-tpm-desde-cero/home/.config/tmux/plugins/tmux-resurrect/scripts/save.sh
   ```
   El `sleep 1` evita arrancar el servidor nuevo mientras el anterior aún
   se cierra.

6. **Actualizar algo fijado.** `update_plugins` hace `git pull` en cada
   plugin; un tag no se mueve:
   ```bash
   lab_tpm update_plugins all; echo $?
   git -C starter/plugins/tmux-resurrect describe --tags
   ```
   ```
   Updating all plugins!

     "tmux-resurrect" update success
     "tpm" update success
   0
   v4.0.0
   ```
   Para cambiar de versión cambias el tag en la config, borras la carpeta
   del plugin y vuelves a instalar: así la versión queda escrita en git.

7. **Limpia un plugin.** `clean_plugins` borra las carpetas de
   `starter/plugins/` que ya no están declaradas. Borra de
   `starter/tmux.conf` la línea `@plugin` de resurrect y la de
   `@resurrect-save`, recarga y limpia:
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   lab_tpm clean_plugins; echo $?
   ls starter/plugins
   tmux -L lab list-keys -T prefix | grep -c save.sh
   ```
   ```
   Removing "tmux-resurrect"
     "tmux-resurrect" clean success
   0
   tpm
   1
   ```
   La carpeta ya no está, pero la tecla `S` sigue en el servidor (apunta a
   un script que no existe): lo que un plugin hizo con `bind`/`set` solo
   desaparece al reiniciar el servidor.

8. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf home starter/plugins
   ```
   ```
   (sin salida)
   ```
   Para repetir el lab, vuelve a dejar las líneas de resurrect como en
   `solucion/tmux.conf`.

## Criterios de éxito

- [ ] `git -C starter/plugins/tpm describe --tags` imprime `v3.1.0` (paso 1)
- [ ] `lab_tpm install_plugins` imprime `"tmux-resurrect" download success` y `git -C starter/plugins/tmux-resurrect describe --tags` imprime `v4.0.0` (paso 3)
- [ ] Tras recargar, `tmux -L lab list-keys -T prefix | grep resurrect` muestra `C-r` y `C-s` (paso 4)
- [ ] Con `@resurrect-save 'S'` encima del `run-shell`, un servidor nuevo tiene `prefix` `S` y no `C-s` (paso 5)
- [ ] Explicas por qué `show -g @plugin` muestra un solo plugin y TPM instala los dos (paso 2)
- [ ] `lab_tpm clean_plugins` imprime `"tmux-resurrect" clean success` (paso 7)

## Reto extra

Instala dos plugins más de `tmux-plugins` (por ejemplo `tmux-sensible`),
cada uno fijado a su último tag (míralo con
`git ls-remote --tags https://github.com/tmux-plugins/tmux-sensible`).
Después lee su `*.tmux` y apunta qué opciones y teclas cambia: ¿alguna pisa
algo de tu config? ¿Cuántas de esas líneas escribirías tú en dos minutos?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — resurrect y continuum](../lab-02-resurrect-y-continuum/README.md) → |

[↑ Semana 11](../../README.md)
