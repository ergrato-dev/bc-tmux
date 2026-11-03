# Proyecto Semana 12 — tmux-kit: toggle de anidado, barra remota y sesión compartida

⏱️ 3 horas

## Contexto

En Norte Datos trabajas desde tu portátil, con tu tmux-kit, y entras por SSH a
`build-01`, donde también corre tmux. Con dos tmux uno dentro del otro, el
`C-a` lo captura siempre el de fuera y no sabes qué barra es de quién.

Además, los jueves haces pair programming con Lucía en `build-01`: ella mira
tu sesión desde su usuario. Hasta ahora le pasabas la sesión con un socket en
`/tmp` con permisos 777, y cualquiera de la máquina podía escribir en tus
paneles, es decir, en tu shell.

Esta semana el kit aprende las dos cosas: `F12` apaga el tmux exterior para
que las teclas lleguen al de dentro, la barra dice cuándo el servidor es
remoto, y `bin/kit-pair` comparte una sesión con permisos por grupo y
`server-access`, solo lectura salvo que digas lo contrario.

## Estructura del proyecto

```
starter/                     # tu tmux-kit de la semana 11
├── tmux.conf
├── conf.d/
│   ├── 10-options.conf … 60-plugins.conf
│   ├── 30-status.conf       # ya pone #{E:@kit-remote-label} al principio de status-right
│   └── 70-remote.conf       # TODO 1–4: toggle F12, SSH e indicadores
├── bin/
│   ├── kit-pair             # TODO 5–8: start, allow, deny, list, stop
│   └── …                    # los scripts de semanas anteriores, sin cambios
├── plugin/tmux-kit.tmux
├── docs/diagnostico.md
└── README.md                # paso 10: sección nueva y fila 12 de la bitácora
```

## Lo que debes construir

| Archivo | Qué hace |
|---|---|
| `conf.d/70-remote.conf` | `F12` (tabla root) deja la sesión sin prefix y en la tabla `off`; `F12` en la tabla `off` vuelve a heredar los valores globales. `@kit-remote` vale `on` si el servidor arrancó por SSH, y entonces el acento es azul. `@kit-remote-label` muestra `OFF`, `SSH` y `PAIR` |
| `bin/kit-pair` | `start`: directorio 710 y socket 660 del grupo compartido, sesión `pair`, idempotente. `allow USUARIO [-w]`: `server-access`, solo lectura por defecto. `deny`, `list`, `stop`. Sale con 1 sin sesión compartida o con un usuario que no existe, 2 con uso incorrecto o un nombre no válido |
| `README.md` del kit | Sección `## Remoto y compartir`, fila de `kit-pair` en la tabla de scripts y fila 12 de la bitácora |

`kit-pair` no usa `-L "$TMUX_SOCKET"` como los demás scripts: `-L` deja el
socket en `/tmp/tmux-UID/`, un directorio 0700 al que nadie más puede entrar.
Su servidor vive en `KIT_PAIR_DIR` (por defecto `/tmp/kit-pair-USUARIO`) y se le
habla con `tmux -S`. El grupo sale de `KIT_PAIR_GROUP` (por defecto `pair`).

## Paso a paso

0. **Dónde.** El proyecto necesita un segundo usuario y el grupo `pair`: se
   hace en el laboratorio. Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose up -d lab
   docker compose exec lab bash
   ```
   Estás en la **terminal A** como `alumno`, fuera de tmux (`echo "$TMUX"` no
   imprime nada). Entra en el starter:
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/3-proyecto/starter
   ```
   (sin salida)

   Los pasos 1–4 usan un servidor aparte, `-L kit`, con tu config: su prefix
   es `C-a`. Los pasos 5–9 usan el servidor de `kit-pair`. Si algo se queda a
   medias: `tmux -L kit kill-server` o `bin/kit-pair stop`.

1. **Punto de partida.** La config carga, `kit-pair` ya analiza sus
   argumentos y `F12` todavía no existe:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
   bin/kit-pair; echo $?
   bin/kit-pair start; echo $?
   tmux -L kit list-keys -T root F12; echo $?
   tmux -L kit kill-server
   ```
   ```
   0
   Uso: kit-pair start                 crea (o reutiliza) el socket compartido y la sesión pair
        kit-pair allow USUARIO [-w]    deja entrar a USUARIO: solo lectura; con -w, también escribe
        kit-pair deny USUARIO          le quita el acceso y desconecta sus clientes
        kit-pair list                  quién entra: (R) solo lectura, (W) escritura
        kit-pair stop                  cierra el servidor compartido y borra su directorio
   2
   kit-pair: start sin implementar
   1
   unknown key: F12
   1
   ```
   Borra cada `die "... sin implementar"` (y el `: "$kit" "$group"` de `start`)
   cuando escribas esa función.

   Para probar `F12` necesitas un cliente conectado. En el autograding es un
   cliente de **control mode** (`tmux -C`), que recibe teclas con
   `send-keys -K -c CLIENTE`; tú puedes usar una segunda terminal. Abre la
   **terminal B** en tu equipo con `docker compose exec lab bash` y deja ahí,
   en los pasos 2–4, la sesión conectada:
   ```bash
   tmux -L kit attach -t kit
   ```
   Para salir de ella: `C-a` `d` → `[detached (from session kit)]`, o con el
   toggle apagado, `F12` y después `C-a` `d`.

2. **F12 apaga el tmux (TODO 1, `conf.d/70-remote.conf`).** Del
   lab-03-toggle-de-anidado:
   ```tmux
   bind -N "kit: ..." -n F12 set prefix None \; set key-table off
   ```
   Sin `-g`: cambia la opción de **la sesión**, no la global. Pruébalo en la
   terminal A:
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit
   tmux -L kit list-keys -T root F12
   ```
   ```
   bind-key -T root F12 set-option prefix None \; set-option key-table off
   ```
   Conéctate en la terminal B (paso 1) y pulsa `F12`. En la terminal A:
   ```bash
   tmux -L kit show -v prefix
   tmux -L kit show -v key-table
   tmux -L kit show -gv prefix
   ```
   ```
   None
   off
   C-a
   ```
   El global sigue en `C-a`: las demás sesiones no se enteran. En la terminal
   B ya no funciona ninguna tecla de tmux, ni `C-a` `d`: hace falta el TODO 2.
   Mientras, cierra desde la terminal A: `tmux -L kit kill-server` (la
   terminal B muestra `[server exited]`).

3. **F12 lo enciende otra vez (TODO 2).**
   ```tmux
   bind -N "kit: ..." -T off F12 set -u prefix \; set -u key-table
   ```
   `set -u` borra el valor de la sesión y vuelve a heredar el global, sea el
   que sea. La tabla `off` no lleva más teclas: todas las demás tienen que
   llegar al programa del panel. Arranca el servidor otra vez
   (`tmux -L kit -f "$PWD/tmux.conf" new -d -s kit`), conéctate en la terminal
   B y pulsa `F12` dos veces. En la terminal A:
   ```bash
   tmux -L kit list-keys -T off
   tmux -L kit show -v prefix; echo "[$?]"
   tmux -L kit show -v key-table; echo "[$?]"
   ```
   ```
   bind-key -T off F12 set-option -u prefix \; set-option -u key-table
   [0]
   [0]
   ```
   Sin salida: la sesión ya no tiene valor propio. Pulsa `F12` una vez más
   (apagado) y recarga dos veces: el toggle no cambia, porque la config solo
   pone valores globales.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"; tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -v key-table
   ```
   ```
   off
   ```
   Pulsa `F12` en la terminal B para volver y deja el servidor así.

4. **¿Servidor remoto? (TODO 3).** Del lab-01-ssh-y-sesion-persistente. Un
   format no lee variables de entorno; `if-shell` sí, al cargar la config:
   ```tmux
   if-shell '[ -n "$SSH_CONNECTION" ]' {
     set -g @kit-remote on
     set -g @kit-color-accent "#58a6ff"
   } {
     set -g @kit-remote off
   }
   ```
   `SSH_CONNECTION` existe en las shells de una sesión SSH; aquí la simulas en
   el entorno con el que arranca el servidor. En la terminal A, con un
   servidor aparte para no tocar el de la terminal B:
   ```bash
   SSH_CONNECTION='192.0.2.1 50000 192.0.2.2 22' tmux -L remoto -f "$PWD/tmux.conf" new -d
   tmux -L remoto show -gv @kit-remote; tmux -L remoto show -gv @kit-color-accent
   tmux -L remoto kill-server
   env -u SSH_CONNECTION tmux -L remoto -f "$PWD/tmux.conf" new -d
   tmux -L remoto show -gv @kit-remote
   tmux -L remoto kill-server
   ```
   ```
   on
   #58a6ff
   off
   ```

5. **Indicadores (TODO 4).** `@kit-remote-label` va al principio de
   `status-right` (ya lo pone `30-status.conf`). Tres condicionales, uno por
   indicador:
   - `#{?#{==:#{key-table},off},#[fg=#{@kit-color-bg}#,bg=#{@kit-color-warn}#,bold] OFF #[default] ,}`
   - lo mismo con `#{==:#{@kit-remote},on}` para `SSH ` (con `fg=#{@kit-color-accent}`)
   - y con `#{!=:#{@kit-pair-socket},}` para `PAIR ` (con `fg=#{@kit-color-alert}`)

   `key-table` es una opción: el format la lee por su nombre, sin necesidad de
   cliente. Recarga en la terminal A, pulsa `F12` en la terminal B (la barra
   muestra `OFF` en amarillo) y en la terminal A:
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit display -p '#{E:@kit-remote-label}'
   ```
   ```
   #[fg=#161b22,bg=#e3b341,bold] OFF #[default]
   ```
   Con el servidor de `SSH_CONNECTION` del paso 4 sale
   `#[fg=#58a6ff,bold]SSH #[default]`. Pulsa `F12`, sal de la terminal B con
   `C-a` `d` y cierra: `tmux -L kit kill-server`.

6. **`kit-pair start` (TODO 5, `bin/kit-pair`).** Del lab-04-socket-compartido.
   En orden:
   1. `[[ " $(id -Gn) " == *" $group "* ]] || die "no perteneces al grupo $group: ..."`
   2. `mkdir -p "$dir"` y `[[ -O "$dir" && ! -L "$dir" ]] || die ...`: en
      `/tmp` alguien puede crear el directorio antes que tú.
   3. `chgrp "$group" "$dir"` y `chmod 0710 "$dir"`: el grupo lo atraviesa
      pero no lo lista.
   4. `tmx has-session -t "=pair" 2>/dev/null` o
      `tmx -f "$kit/tmux.conf" new-session -d -s pair`.
   5. `chgrp "$group" "$sock"`, `chmod g+rw,o= "$sock"` (relativo: tmux añade
      la `x` cuando hay clientes y la respeta) y
      `tmx set -g @kit-pair-socket "$sock"`.
   6. Imprime los dos `attach` (el socket con `printf '%q'`).
   ```bash
   bin/kit-pair start; echo $?
   bin/kit-pair start >/dev/null; tmux -S /tmp/kit-pair-alumno/pair ls
   ls -ld /tmp/kit-pair-alumno /tmp/kit-pair-alumno/pair
   KIT_PAIR_GROUP=noexiste bin/kit-pair start; echo $?
   ```
   ```
   kit-pair: sesión pair en /tmp/kit-pair-alumno/pair
     tú:       tmux -S /tmp/kit-pair-alumno/pair attach -t pair
     invitado: tmux -S /tmp/kit-pair-alumno/pair attach -t pair   (después de kit-pair allow USUARIO)
   0
   pair: 1 windows (created Tue Nov  3 21:38:15 2026)
   drwx--x--- 2 alumno pair 4096 Nov  3 21:38 /tmp/kit-pair-alumno
   srw-rw---- 1 alumno pair    0 Nov  3 21:38 /tmp/kit-pair-alumno/pair
   kit-pair: no perteneces al grupo noexiste: sudo groupadd noexiste; sudo usermod -aG noexiste alumno (y vuelve a entrar), o usa KIT_PAIR_GROUP
   1
   ```
   La fecha y la hora cambian. Una sola sesión `pair` aunque lo ejecutes dos veces.

7. **`kit-pair allow` (TODOs 6).** Primero `check_user`: sale con 2 si el
   nombre no casa con `^[A-Za-z_][A-Za-z0-9._-]{0,31}$`. Sin él, `-d` o `-l`
   llegarían a `server-access` como opciones. Después, en `allow`:
   `check_user`, `need_server`, `id -u "$user" >/dev/null 2>&1 || die "no existe el usuario $user"`,
   y si el usuario ya está en `server-access -l` (compáralo con
   `awk -v u="$user" '$1 == u'`), `tmx server-access "$mode" "$user"`; si no,
   `tmx server-access -a "$mode" "$user"`. **`server-access -a` sin `-r` da
   escritura**: por eso el modo por defecto es `-r`. Termina imprimiendo la
   línea del usuario.
   ```bash
   bin/kit-pair allow invitado; echo $?
   bin/kit-pair allow invitado -w; echo $?
   bin/kit-pair allow invitado; echo $?
   bin/kit-pair allow nadie; echo $?
   bin/kit-pair allow -l; echo $?
   ```
   ```
   kit-pair: invitado (R)
   0
   kit-pair: invitado (W)
   0
   kit-pair: invitado (R)
   0
   kit-pair: no existe el usuario nadie
   1
   kit-pair: nombre de usuario no válido: -l
   2
   ```

8. **`deny` y `list` (TODO 7).** `server-access -d` también desconecta los
   clientes del usuario. Quitar a quien no estaba sale con 0.
   ```bash
   bin/kit-pair list; echo $?
   bin/kit-pair deny invitado; echo $?
   bin/kit-pair deny invitado; echo $?
   bin/kit-pair list
   ```
   ```
   alumno (W)
   invitado (R)
   0
   kit-pair: invitado ya no tiene acceso
   0
   kit-pair: invitado no tenía acceso
   0
   alumno (W)
   ```
   El dueño (`alumno`) sale siempre como `(W)` y no se puede cambiar.

9. **`stop` (TODO 8) y prueba con el invitado.** `tmx kill-server`, después
   `rm -f "$sock"` (kill-server vuelve antes de que el servidor borre su
   socket) y `rmdir "$dir" 2>/dev/null || true`. Sin servidor, avisa y sale
   con 0.
   ```bash
   bin/kit-pair stop; echo $?
   bin/kit-pair stop; echo $?
   bin/kit-pair list; echo $?
   ```
   ```
   kit-pair: servidor compartido cerrado
   0
   kit-pair: no había sesión compartida
   0
   kit-pair: no hay sesión compartida: ejecuta kit-pair start
   1
   ```
   Ahora con una persona de verdad. En la terminal A: `bin/kit-pair start`.
   Abre la **terminal C** en tu equipo como invitado:
   ```bash
   docker compose exec -u invitado lab bash
   ls /tmp/kit-pair-alumno
   tmux -S /tmp/kit-pair-alumno/pair attach -t pair; echo $?
   ```
   ```
   ls: cannot open directory '/tmp/kit-pair-alumno': Permission denied
   access not allowed
   0
   ```
   El socket le deja llegar (grupo `pair`), pero `server-access` lo frena.
   Ojo: sale con 0. En la terminal A, `bin/kit-pair allow invitado`; en la
   terminal C repite el `attach`: ve la sesión, pero lo que escribe no llega.
   En la terminal A:
   ```bash
   tmux -S /tmp/kit-pair-alumno/pair list-clients -F '#{client_user} #{client_flags}'
   ```
   ```
   invitado attached,focused,read-only,UTF-8
   ```
   El invitado sale con `C-a` `d` (el prefix es el de tu kit) →
   `[detached (from session pair)]`. Prueba también `bin/kit-pair deny invitado`
   con él conectado: su terminal vuelve a la shell. Al terminar,
   `bin/kit-pair stop`.

10. **README del kit.** Añade la fila de `bin/kit-pair` a la tabla de
    scripts, la nota de que `kit-pair` usa `-S` y no `TMUX_SOCKET`, los
    indicadores `OFF`/`SSH`/`PAIR` en la zona derecha de la barra, una sección
    `## Remoto y compartir` (qué hace `F12`, cómo compartir y por qué `-w`
    regala tu shell) y la fila 12 de la bitácora. Sal del laboratorio
    (`exit`) y verifica desde tu equipo (paso siguiente).

## Verificación

Desde la raíz del repositorio, en tu equipo:

```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 12
```
```
Semana 12 — Remoto, colaboración y control mode

  ✅ tmux.conf carga sin errores con conf.d/70-remote.conf
  ✅ F12 deja la sesión sin prefix
  ✅ F12 pone la sesión en la tabla off
  ✅ Con el toggle apagado, la barra muestra OFF
  ✅ Un segundo F12 deja la sesión exactamente como estaba
  ✅ El toggle sigue funcionando después de recargar la config dos veces
  ✅ La barra marca SSH solo si el servidor arrancó por SSH
  ✅ bin/kit-pair sale con 2 ante un uso incorrecto
  ✅ kit-pair start deja el directorio en 710 y el socket en 660, del grupo compartido
  ✅ Ejecutar kit-pair start dos veces deja una sola sesión pair
  ✅ kit-pair allow sin sesión compartida sale con 1 y lo dice
  ✅ kit-pair allow da solo lectura por defecto
  ✅ kit-pair allow USUARIO -w pasa a escritura a quien ya tenía acceso
  ✅ kit-pair allow rechaza un usuario que no existe
  ✅ kit-pair allow rechaza con 2 un nombre que tmux leería como opción o ruta
  ✅ kit-pair deny quita el acceso
  ✅ kit-pair stop cierra el servidor compartido y borra su directorio
  ✅ tmux.conf, conf.d/, bin/ y plugin/ no tienen TODOs y bin/ y plugin/ pasan shellcheck

18/18 comprobaciones superadas.
```

Al terminar la semana: `docker compose down`.

## ✅ Requisitos verificables

- [ ] tmux.conf carga sin errores con conf.d/70-remote.conf
- [ ] F12 deja la sesión sin prefix
- [ ] F12 pone la sesión en la tabla off
- [ ] Con el toggle apagado, la barra muestra OFF
- [ ] Un segundo F12 deja la sesión exactamente como estaba
- [ ] El toggle sigue funcionando después de recargar la config dos veces
- [ ] La barra marca SSH solo si el servidor arrancó por SSH
- [ ] bin/kit-pair sale con 2 ante un uso incorrecto
- [ ] kit-pair start deja el directorio en 710 y el socket en 660, del grupo compartido
- [ ] Ejecutar kit-pair start dos veces deja una sola sesión pair
- [ ] kit-pair allow sin sesión compartida sale con 1 y lo dice
- [ ] kit-pair allow da solo lectura por defecto
- [ ] kit-pair allow USUARIO -w pasa a escritura a quien ya tenía acceso
- [ ] kit-pair allow rechaza un usuario que no existe
- [ ] kit-pair allow rechaza con 2 un nombre que tmux leería como opción o ruta
- [ ] kit-pair deny quita el acceso
- [ ] kit-pair stop cierra el servidor compartido y borra su directorio
- [ ] tmux.conf, conf.d/, bin/ y plugin/ no tienen TODOs y bin/ y plugin/ pasan shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la [rúbrica](../rubrica-evaluacion.md)):

- **El toggle no guarda estado**: valores de sesión con `set` sin `-g` y vuelta con `set -u`; la tabla `off` solo tiene `F12`; ninguna tecla del kit deja de funcionar al volver.
- **Seguridad por capas en `kit-pair`**: directorio propio comprobado con `-O`, permisos por grupo (nunca `o+rw`), `server-access` en solo lectura por defecto, nombres validados antes de llegar a tmux.
- **Idempotencia**: `start`, `deny` y `stop` se pueden repetir; `allow` cambia el modo de quien ya estaba.
- Comentarios del porqué: `-S` y no `-L`, `chmod` relativo en el socket, `rm -f` tras `kill-server`, `if-shell` porque un format no lee el entorno, qué SSH detecta (el del arranque del servidor).
- Cabecera con uso y códigos de salida en `kit-pair`; errores por stderr con el nombre del script; `shellcheck bin/*` sin avisos.
- README del kit al día: scripts, barra, sección `## Remoto y compartir` y bitácora.

## Entrega

Commit con el mensaje:
```
feat(week-12): toggle de anidado, barra remota y kit-pair
```
Entrega `conf.d/70-remote.conf`, `bin/kit-pair` y `README.md` de tu `starter/`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — Colaboración rota](../2-practicas/lab-06-colaboracion-rota/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 12](../README.md)
