# Lab 06 — Plugins rotos

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y arreglar los seis fallos de una config modular con TPM y un plugin propio que arranca sin errores pero no carga lo que promete.

## Contexto

- `starter/` es la config de un compañero, rota a propósito: `tmux.conf` lee `conf.d/*.conf` con `source-file -F`, `conf.d/60-plugins.conf` declara los plugins y `plugin/sessions.tmux` es su plugin propio. Arrancar con `-f` sale con 0 aunque algo falle por dentro.
- Cada paso da un síntoma, cómo observarlo y una pista. Arregla solo ese fallo, comprueba y pasa al siguiente.
- Repasa los labs 01 a 03: cómo encuentra TPM los plugins, dónde va el `run-shell` y cómo se hace idempotente un plugin.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux** (`echo "$TMUX"` vacío), desde la
   raíz del repositorio:
   ```bash
   cd bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-06-plugins-rotos
   C="$PWD/starter/tmux.conf"
   ```
   HOME aislado con `home/.config/tmux` apuntando a `starter/` (como en el
   lab 01) y TPM clonado donde lo espera el compañero:
   ```bash
   mkdir -p home/.config && ln -s ../../starter home/.config/tmux
   git -c advice.detachedHead=false clone -q --depth 1 --branch v3.1.0 https://github.com/tmux-plugins/tpm starter/plugins/tpm; echo $?
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   lab_tpm() { local s=$1; shift; env -u XDG_CONFIG_HOME HOME="$PWD/home" TMUX="$(tmux -L lab display -p '#{socket_path}'),0,0" "$PWD/starter/plugins/tpm/bin/$s" "$@"; }
   tmux -L lab show -gv @lab-dir
   ```
   Algo como (la ruta es la de tu carpeta del lab):
   ```
   0
   0
   /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-06-plugins-rotos/starter
   ```
   Arrancó con 0. El prefix es `C-b`: la config no lo cambia.

1. **Fallo 1 — el plugin propio no hace nada.** `status-right` debería
   terminar en `N ses (M creadas)`:
   ```bash
   tmux -L lab show -gv status-right
   tmux -L lab source-file "$C"; echo $?
   tmux -L lab run-shell "$PWD/starter/plugin/sessions.tmux"; echo $?
   ```
   ```
   %H:%M
   126
   126
   ```
   Arrancando con `-f` ese error no se ve; `source-file` desde la terminal
   sí devuelve el código. **Pista:** 127 es "no existe", 126 es "existe
   pero no se puede ejecutar". Mira `ls -l starter/plugin`. Arréglalo y
   recarga:
   ```bash
   chmod +x starter/plugin/sessions.tmux
   tmux -L lab source-file "$C"; echo $?
   tmux -L lab show -gv status-right
   ```
   ```
   0
   %H:%M #{server_sessions} ses (#{@sessions-created} creadas)
   ```
   Si el plugin vive en un repositorio git, haz commit del archivo ya
   ejecutable: git guarda ese bit.

2. **Fallo 2 — las sesiones se cuentan de más.** Crea una sesión, recarga
   dos veces y crea otra:
   ```bash
   tmux -L lab show-hooks -g session-created
   tmux -L lab new -d -s a; tmux -L lab show -gv @sessions-created
   tmux -L lab source-file "$C"; tmux -L lab source-file "$C"
   tmux -L lab show-hooks -g session-created
   tmux -L lab new -d -s b; tmux -L lab show -gv @sessions-created
   ```
   ```
   session-created[0] set-option -Fg @sessions-created "#{e|+:#{@sessions-created},1}"
   1
   session-created[0] set-option -Fg @sessions-created "#{e|+:#{@sessions-created},1}"
   session-created[1] set-option -Fg @sessions-created "#{e|+:#{@sessions-created},1}"
   session-created[2] set-option -Fg @sessions-created "#{e|+:#{@sessions-created},1}"
   4
   ```
   Una sesión, tres sumas. El segmento de `status-right` no se duplica
   (cada recarga vuelve a poner `'%H:%M'` y el plugin comprueba antes de
   añadir), pero el hook sí. **Pista:** semana 10, lab 01, paso 4. Cambia
   en `starter/plugin/sessions.tmux` el `set-hook -ga session-created` por
   `set-hook -g 'session-created[10]'`, borra las entradas viejas y recarga
   dos veces:
   ```bash
   tmux -L lab set-hook -gu session-created
   tmux -L lab source-file "$C"; tmux -L lab source-file "$C"
   tmux -L lab show-hooks -g session-created
   tmux -L lab new -d -s otra; tmux -L lab display -p "$(tmux -L lab show -gv status-right)"
   ```
   Algo como (cambia la hora):
   ```
   session-created[10] set-option -Fg @sessions-created "#{e|+:#{@sessions-created},1}"
   20:26 4 ses (5 creadas)
   ```
   Cuatro sesiones (`lab`, `a`, `b`, `otra`); `otra` sumó 1. La primera,
   `lab`, nunca contó: cuando nació, el plugin aún fallaba.

3. **Fallo 3 — TPM no se ejecuta.** El compañero jura que TPM está
   instalado, y lo está (paso 0). Pero:
   ```bash
   tmux -L lab list-keys -T prefix I; echo $?
   ```
   ```
   unknown key: I
   1
   ```
   **Pista:** `if-shell` pasa su primer argumento a `sh -c`. Ejecuta tú
   ese test dentro del servidor, tal cual y sin las comillas dobles:
   ```bash
   tmux -L lab run-shell 'test -x "~/.config/tmux/plugins/tpm/tpm"'; echo $?
   tmux -L lab run-shell 'test -x ~/.config/tmux/plugins/tpm/tpm'; echo $?
   ```
   ```
   1
   0
   ```
   La shell solo cambia la `~` al principio de una palabra **sin
   comillas**. En `starter/tmux.conf` cambia `"~/.config/...` por
   `"$HOME/.config/...` (`$HOME` sí se expande entre comillas dobles) y
   recarga:
   ```bash
   tmux -L lab source-file "$C"; echo $?
   tmux -L lab list-keys -T prefix I
   ```
   ```
   0
   bind-key -T prefix I run-shell /bc-tmux/bootcamp/week-11-plugins_y_ecosistema/2-practicas/lab-06-plugins-rotos/home/.config/tmux/plugins/tpm/bindings/install_plugins
   ```

4. **Fallo 4 — TPM no instala nada.** Con TPM ya activo:
   ```bash
   lab_tpm install_plugins; echo $?
   ls starter/plugins
   tmux -L lab show -gv @plugin
   ```
   ```
   0
   tpm
   tmux-plugins/tmux-resurrect
   ```
   Sale con 0, no imprime nada y resurrect no aparece, aunque el servidor
   sí tiene `@plugin`. **Pista:** TPM no le pregunta al servidor; busca las
   líneas `set -g @plugin` con `awk` en `~/.config/tmux/tmux.conf` y en los
   `source-file` de ese archivo cuya ruta pueda leer tal cual:
   ```bash
   grep -c '@plugin' starter/tmux.conf; grep -n '^source-file' starter/tmux.conf
   ```
   ```
   0
   20:source-file -F "#{@lab-dir}/conf.d/*.conf"
   ```
   Para TPM, la ruta es el texto `-F "#{@lab-dir}/conf.d/*.conf"`: ni
   expande el format ni encuentra el archivo. TPM 3.1.0 también lee la
   opción `@tpm_plugins` **del servidor**, que funciona desde cualquier
   archivo. En `starter/conf.d/60-plugins.conf` cambia las dos líneas
   `set -g @plugin` por una sola opción (la `\` al final de línea continúa
   la cadena; TPM separa por espacios):
   ```tmux
   set -g @tpm_plugins '                 \
     tmux-plugins/tpm#v3.1.0             \
     tmux-plugins/tmux-resurrect         \
   '
   ```
   ```bash
   tmux -L lab source-file "$C"; echo $?
   tmux -L lab show -gv @tpm_plugins | tr -s ' ' '\n' | grep .
   lab_tpm install_plugins; echo $?
   ```
   ```
   0
   tmux-plugins/tpm#v3.1.0
   tmux-plugins/tmux-resurrect
   Already installed "tpm"
   Installing "tmux-resurrect"
     "tmux-resurrect" download success
   0
   ```

5. **Fallo 5 — una versión que nadie eligió.** ¿Qué versión de resurrect
   se instaló?
   ```bash
   git -C starter/plugins/tmux-resurrect describe --tags
   tmux -L lab show -gv @tpm_plugins | tr -s ' ' '\n' | grep . | grep -v '#'
   ```
   Algo como (cambian el número y el hash según el día):
   ```
   v4.0.0-18-gcff343c
   tmux-plugins/tmux-resurrect
   ```
   18 commits después de `v4.0.0`: lo que había hoy en la rama principal.
   Otra máquina, otro día, otra cosa. El segundo comando lista los plugins
   sin `#tag`. Añade `#v4.0.0` a resurrect en `@tpm_plugins` y reinstala:
   ```bash
   tmux -L lab source-file "$C"; lab_tpm install_plugins
   ```
   ```
   Already installed "tpm"
   Already installed "tmux-resurrect"
   ```
   TPM no cambia de versión un plugin que ya está. Borra la carpeta e
   instala otra vez:
   ```bash
   rm -rf starter/plugins/tmux-resurrect; lab_tpm install_plugins
   git -C starter/plugins/tmux-resurrect describe --tags
   ```
   ```
   Already installed "tpm"
   Installing "tmux-resurrect"
     "tmux-resurrect" download success
   v4.0.0
   ```

6. **Fallo 6 — funciona al recargar, no al arrancar.** Recarga y luego
   arranca de cero:
   ```bash
   tmux -L lab source-file "$C"; tmux -L lab list-keys -T prefix | grep -c resurrect
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   tmux -L lab list-keys -T prefix | grep -c resurrect
   tmux -L lab source-file "$C"; tmux -L lab list-keys -T prefix | grep -c resurrect
   ```
   ```
   2
   0
   0
   2
   ```
   Recién arrancado, ni `C-s` ni `C-r`; tras una recarga, sí. Es el fallo
   que más tarda en descubrirse: casi siempre se prueba recargando.
   **Pista:** al arrancar, ¿existe ya `@tpm_plugins` cuando se ejecuta
   `tpm`? Mira en qué orden están el bloque `if-shell` y el `source-file`
   en `starter/tmux.conf`. Pon el bloque `if-shell` **después** del
   `source-file` y arranca de cero:
   ```bash
   tmux -L lab kill-server; sleep 1
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$C" new -d -s lab; echo $?
   tmux -L lab list-keys -T prefix | grep -c resurrect
   ```
   ```
   0
   2
   ```

7. **Comprueba y limpia** (terminal A). Compara tus archivos con
   `solucion/` (los comentarios de la solución explican cada arreglo) y
   cierra:
   ```bash
   tmux -L lab source-file -n "$C"; echo $?
   tmux -L lab kill-server
   rm -rf home starter/plugins
   ```
   ```
   0
   ```

## Criterios de éxito

- [ ] `tmux -L lab source-file "$C"; echo $?` imprime `0` y `status-right` termina en ` #{server_sessions} ses (#{@sessions-created} creadas)` (fallo 1)
- [ ] Tras dos recargas, `show-hooks -g session-created` muestra una sola entrada `[10]` (fallo 2)
- [ ] Explicas por qué `test -x "~/..."` falla y `test -x "$HOME/..."` no (fallo 3)
- [ ] Explicas por qué TPM no veía los `@plugin` de `conf.d/` y por qué `@tpm_plugins` sí funciona (fallo 4)
- [ ] `git -C starter/plugins/tmux-resurrect describe --tags` imprime `v4.0.0` exacto (fallo 5)
- [ ] Un servidor recién arrancado tiene `prefix` `C-s` y `prefix` `C-r` sin recargar (fallo 6)

## Reto extra

El kit de la semana tiene el mismo problema que el fallo 4 y lo resuelve
igual. Escribe un `check-plugins.sh` (bash, `set -euo pipefail`,
shellcheck limpio) que imprima los plugins de `@tpm_plugins` del servidor
`-L lab` sin `#tag` y salga con 1 si hay alguno. Compáralo después con lo
que hace `bin/kit-plugins check` en el proyecto.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — tmuxp](../lab-05-tmuxp/README.md) | [Proyecto — tmux-kit: plugin propio y plugins de terceros fijados](../../3-proyecto/README.md) → |

[↑ Semana 11](../../README.md)
