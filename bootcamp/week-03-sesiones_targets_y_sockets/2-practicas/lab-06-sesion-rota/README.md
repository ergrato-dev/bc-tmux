# Lab 06 — La sesión rota

⏱ Duración estimada: ~60 min

## Objetivo

Encontrar y corregir los cuatro errores de un script que abre la sesión de un proyecto, usando nombres exactos y el comando correcto dentro y fuera de tmux.

## Contexto

Un compañero escribió `starter/proyecto.sh`: recibe el directorio de un
proyecto y te lleva a una sesión con su nombre, creándola si no existe. Lo
usa a diario y "va bien". Tú tienes más sesiones que él, algunas con nombres
parecidos, y trabajas siempre dentro de tmux. El script tiene **cuatro
errores reales**, todos de esta semana.

## Instrucciones

1. Prepara el escenario: una sesión vieja con un nombre parecido, dos
   proyectos y una sesión desde la que trabajar.
   ```bash
   mkdir -p /tmp/proy/api /tmp/proy/web.app
   tmux -L lab new -d -s api-vieja
   tmux -L lab new -s otra
   ```
   Los pasos siguientes se ejecutan **dentro** de `otra`.

2. Ejecuta el script:
   ```bash
   ./starter/proyecto.sh /tmp/proy/api
   ```
   Falla con `sessions should be nested with care`. Dentro de tmux no se
   conecta un cliente nuevo: se cambia el actual de sesión. **Error 1.**

3. Corrígelo (`switch-client` dentro de tmux, `attach-session` fuera) y vuelve
   a ejecutarlo. Ya no falla... pero mira en qué sesión estás: `api-vieja`. Y
   la sesión `api` ni siquiera se creó. Mira cómo decide el script si la
   sesión existe:
   ```bash
   tmux -L lab ls | grep -q api && echo "dice que existe"
   ```
   `grep` encuentra `api` dentro de `api-vieja: 1 windows...`. **Error 2.**
   Usa `has-session` en lugar de `ls | grep`.

4. Con `has-session -t "$nombre"`, sigue saltando a `api-vieja`. Recuerda el
   lab 02: sin `=` el target coincide por prefijo. **Error 3.** Usa
   `-t "=$nombre"` en **todos** los targets.

5. Prueba el segundo proyecto:
   ```bash
   ./starter/proyecto.sh /tmp/proy/web.app
   ./starter/proyecto.sh /tmp/proy/web.app
   tmux -L lab ls -F '#{session_name}'
   ```
   La primera vez crea `web_app`, pero no salta a ella: `can't find pane: app`.
   El target `=web.app` se lee como sesión `web.app`... y panel `app`. La
   segunda vez tampoco la encuentra e intenta crearla otra vez:
   `duplicate session: web_app`. **Error 4.** Convierte el nombre antes de
   usarlo: `${nombre//[.:]/_}`.

6. Cuando lo tengas, desde `otra`:
   ```bash
   ./starter/proyecto.sh /tmp/proy/api        # te lleva a api (nueva)
   ./starter/proyecto.sh /tmp/proy/web.app    # te lleva a web_app
   ./starter/proyecto.sh /tmp/proy/api        # vuelve a api, sin crear otra
   tmux -L lab ls -F '#{session_name}'
   ```
   ```
   api
   api-vieja
   otra
   web_app
   ```
   Y fuera de tmux, `./starter/proyecto.sh /tmp/proy/api` te conecta a `api`.

7. Limpia: `tmux -L lab kill-server; rm -rf /tmp/proy`.

## Criterios de éxito

- [ ] Los cuatro errores identificados, con una línea por cada uno explicando el síntoma y la causa
- [ ] El script funciona dentro y fuera de tmux
- [ ] Nunca salta a `api-vieja` ni crea una sesión duplicada
- [ ] Ejecutarlo dos veces con el mismo directorio no crea nada nuevo

## Reto extra

Haz que el script, si se le pasa un directorio que no existe, avise y salga
con 1 **antes** de tocar tmux. ¿Qué haría hoy `new-session -c` con un
directorio que no existe?
