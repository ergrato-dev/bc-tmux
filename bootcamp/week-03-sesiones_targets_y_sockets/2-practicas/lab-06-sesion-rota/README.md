# Lab 06 — La sesión rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de un script que abre la sesión de un proyecto, usando nombres exactos y el comando correcto dentro y fuera de tmux.

## Contexto

Un compañero escribió `starter/project.sh`: recibe el directorio de un
proyecto y te lleva a una sesión con su nombre, creándola si no existe. Lo
usa a diario y "va bien". Tú tienes más sesiones que él, algunas con nombres
parecidos, y trabajas siempre dentro de tmux. El script tiene **cuatro
errores reales**, todos de esta semana. Anota cada uno en una línea (síntoma
y causa) a medida que lo encuentres.

## Instrucciones

0. Abre dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime nada en
   ninguna). En las dos, entra en la carpeta del lab:
   ```bash
   cd bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-06-sesion-rota
   ```
   La **terminal A** se conectará a tmux; la **terminal B** se queda fuera. El
   servidor del lab (`-L lab`) arranca con `-f /dev/null`: el prefix es `C-b`.

1. **El escenario.** El script te cambiará de sesión, y cada sesión tiene su
   propio panel en su propio directorio: `./starter/project.sh` dejará de
   existir en cuanto saltes a `/tmp/proy/api`. Por eso guardas la ruta
   absoluta en `S` **antes** de arrancar el servidor: tmux copia el entorno de
   la terminal que lo arranca, y todos sus paneles heredan `S`. En la
   terminal B:
   ```bash
   export S="$PWD/starter/project.sh"
   mkdir -p /tmp/proy/api /tmp/proy/web.app
   tmux -L lab -f /dev/null new -d -s api-vieja
   tmux -L lab new -d -s otra
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   api-vieja
   otra
   ```
   En la terminal A, conéctate a `otra` y comprueba que el panel tiene `S`:
   ```bash
   tmux -L lab attach -t =otra
   echo "$S"
   ```
   ```
   /ruta/a/bc-tmux/bootcamp/week-03-sesiones_targets_y_sockets/2-practicas/lab-06-sesion-rota/starter/project.sh
   ```
   (Algo como: el principio depende de dónde clonaste el repo.) Desde aquí,
   los comandos `"$S" ...` se escriben en el panel de la terminal A.

2. **Error 1.** Ejecuta el script tal como viene:
   ```bash
   "$S" /tmp/proy/api; echo $?
   ```
   ```
   sessions should be nested with care, unset $TMUX to force
   1
   ```
   Dentro de tmux no se conecta un cliente nuevo: se cambia el actual de
   sesión. Abre `starter/project.sh` con tu editor y sustituye la última
   línea (`tmx attach-session -t "$name"`) por:
   ```bash
   if [[ -n "${TMUX:-}" ]]; then
     tmx switch-client -t "$name"
   else
     tmx attach-session -t "$name"
   fi
   ```

3. **Error 2.** Vuelve a ejecutarlo:
   ```bash
   "$S" /tmp/proy/api; echo $?
   ```
   Ya no falla (no imprime nada), pero mira la barra: `[api-vieja]`. Y la
   sesión `api` ni siquiera se creó. En la terminal B:
   ```bash
   tmux -L lab ls -F '#{session_name}'
   tmux -L lab ls | grep -q api && echo "dice que existe"
   ```
   ```
   api-vieja
   otra
   dice que existe
   ```
   `grep` encuentra `api` dentro de `api-vieja: 1 windows...`. Cambia la
   comprobación del script por una pregunta concreta a tmux:
   ```bash
   if ! tmx has-session -t "$name" 2>/dev/null; then
   ```
   Vuelve a `otra` desde el panel de la terminal A:
   ```bash
   tmux -L lab switch-client -t =otra
   ```

4. **Error 3.** Ejecútalo otra vez:
   ```bash
   "$S" /tmp/proy/api; echo $?
   ```
   La barra sigue diciendo `[api-vieja]`. Recuerda el lab 02: sin `=`, el
   target coincide por prefijo, y `has-session -t api` encuentra `api-vieja`.
   Pon `-t "=$name"` en **los tres** targets del script (`has-session`,
   `switch-client` y `attach-session`). Vuelve a `otra` y prueba:
   ```bash
   tmux -L lab switch-client -t =otra
   "$S" /tmp/proy/api
   pwd
   ```
   ```
   /tmp/proy/api
   ```
   La barra dice `[api]`, y estás en el panel de la sesión nueva, en el
   directorio del proyecto: aquí `./starter/project.sh` no existe, `"$S"` sí.

5. **Error 4.** Prueba el segundo proyecto, dos veces:
   ```bash
   "$S" /tmp/proy/web.app; echo $?
   "$S" /tmp/proy/web.app; echo $?
   ```
   ```
   can't find pane: app
   1
   duplicate session: web_app
   1
   ```
   En la terminal B:
   ```bash
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   api
   api-vieja
   otra
   web_app
   ```
   La primera vez creó `web_app` (tmux cambia `.` por `_`), pero no saltó a
   ella: el target `=web.app` se lee como sesión `web`, panel `app`. La
   segunda vez `has-session -t =web.app` tampoco la encontró e intentó crearla
   otra vez. Convierte el nombre antes de usarlo; justo después de la línea
   `name=$(basename "$dir")`, añade:
   ```bash
   name=${name//[.:]/_}
   ```
   `${var//patrón/reemplazo}` sustituye todas las apariciones.

6. **Todo junto.** Empieza con un servidor sin `api` ni `web_app`. En el panel
   de la terminal A vuelve a `otra` (si cierras la sesión en la que estás, tu
   cliente sale de tmux):
   ```bash
   tmux -L lab switch-client -t =otra
   ```
   En la terminal B:
   ```bash
   tmux -L lab kill-session -t =api \; kill-session -t =web_app
   ```
   ```
   (sin salida)
   ```
   En el panel de la terminal A:
   ```bash
   "$S" /tmp/proy/api        # la barra dice [api] (nueva)
   "$S" /tmp/proy/web.app    # la barra dice [web_app]
   "$S" /tmp/proy/api        # vuelve a [api], sin crear otra
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   api
   api-vieja
   otra
   web_app
   ```
   Desconéctate con `C-b` `d`:
   ```
   [detached (from session api)]
   ```

7. **Fuera de tmux.** En la terminal B (fuera de tmux, con `S` exportada en el
   paso 1):
   ```bash
   "$S" /tmp/proy/api
   ```
   Te conecta a `api` (`[api]` en la barra). Sal con `C-b` `d`:
   ```
   [detached (from session api)]
   ```

8. Limpia, en la terminal B:
   ```bash
   tmux -L lab kill-server; rm -rf /tmp/proy
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Anotaste los cuatro errores, una línea por cada uno con el síntoma y la causa (pasos 2 a 5)
- [ ] El script funciona dentro (paso 6) y fuera de tmux (paso 7)
- [ ] Nunca salta a `api-vieja` ni crea una sesión duplicada: el `ls` del paso 6 da las cuatro sesiones
- [ ] Ejecutarlo dos veces con el mismo directorio no crea nada nuevo (paso 6)

## Reto extra

Haz que el script, si se le pasa un directorio que no existe, avise y salga
con 1 **antes** de tocar tmux. ¿Qué haría hoy `new-session -c` con un
directorio que no existe?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 05 — Sockets y la variable TMUX](../lab-05-sockets-y-la-variable-tmux/README.md) | [Proyecto — tmux-kit: sesiones](../../3-proyecto/README.md) → |

[↑ Semana 03](../../README.md)
