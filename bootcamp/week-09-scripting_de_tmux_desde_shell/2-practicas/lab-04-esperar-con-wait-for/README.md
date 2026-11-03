# Lab 04 — Esperar con wait-for

⏱ Duración estimada: ~60 min

## Objetivo

Ejecutar un comando en la shell de un panel y esperar desde fuera a que termine, con un límite de tiempo y recuperando su código de salida, sin bucles de `sleep`.

## Contexto

- `wait-for CANAL` bloquea hasta que alguien ejecuta `wait-for -S CANAL`. Si la señal llega antes de que nadie espere, queda guardada: no hay carrera.
- Dentro de un panel, `tmux` sin `-L` habla con el servidor de `$TMUX`, el mismo del panel.
- `wait-for` no tiene límite de tiempo: se lo pone `timeout`, que sale con 124 si se agota. `timeout` ejecuta programas, no funciones de bash.

## Instrucciones

0. **Dónde.** Terminal A **fuera de tmux**, desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-09-scripting_de_tmux_desde_shell/2-practicas/lab-04-esperar-con-wait-for
   ```
   Arranca el servidor `-L lab` como dice [Antes de cada lab](../README.md#antes-de-cada-lab)
   (paso 3).

1. **El panel conoce su servidor:**
   ```bash
   tmux -L lab new-session -d -s api -c /tmp/lab09 -x 80 -y 20
   tmux -L lab send-keys -t api 'clear; echo "$TMUX"' Enter
   sleep 0.5; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 2
   ```
   Algo como (cambian el uid y el PID del servidor):
   ```
   /tmp/tmux-1000/lab,180,0
   alumno@bc-tmux-lab:/tmp/lab09$
   ```
   Socket, PID y número de sesión. Por eso el `tmux wait-for -S` que se
   ejecute dentro del panel llega al servidor `lab` sin `-L`.

2. **Esperar una señal.** El panel duerme 2 s y avisa; fuera, esperas:
   ```bash
   tmux -L lab send-keys -t api 'sleep 2; tmux wait-for -S listo' Enter; time tmux -L lab wait-for listo; echo $?
   ```
   Algo como:
   ```
   real	0m2.006s
   user	0m0.004s
   sys	0m0.000s
   0
   ```

3. **La señal que llega primero queda guardada:**
   ```bash
   tmux -L lab wait-for -S antes; tmux -L lab wait-for antes; echo $?
   ```
   ```
   0
   ```
   Vuelve en el acto. Si el comando del panel termina antes de que tu
   script llegue a `wait-for`, no se queda colgado.

4. **Un límite de tiempo.** Nadie manda `nunca`:
   ```bash
   timeout 2 tmux -L lab wait-for nunca; echo $?
   tmx() { tmux -L lab "$@"; }; timeout 2 tmx list-sessions; echo $?
   ```
   ```
   124
   timeout: failed to run command ‘tmx’: No such file or directory
   127
   ```
   `timeout` busca un programa llamado `tmx` y no lo hay: en el script se
   escribe el binario y el socket a mano.

5. **Completa `starter/run-and-wait`.** Ya valida el target y guarda el id
   del panel. Sin tocar nada:
   ```bash
   tmux -L lab send-keys -t api clear Enter
   ./starter/run-and-wait api 'sleep 2; echo compilado'; echo $?
   ```
   Algo como (el número del canal es el PID del script):
   ```
   sin implementar: %0 kit-run-210 sleep 2; echo compilado
   1
   ```

   1. **TODO 1 — mandar el comando y el aviso.** Descomenta las dos líneas
      `tmx send-keys` del TODO. La primera, con `-l --`, teclea
      `COMANDO; tmux set -p @kit-run-rc $?; tmux wait-for -S CANAL`: al
      terminar, el panel guarda el código en una opción propia (`set -p`:
      la del panel donde se ejecuta) y manda la señal. El `\$?` lleva barra
      para que lo expanda la shell del panel, no la tuya.
      ```bash
      ./starter/run-and-wait api 'sleep 2; echo compilado'; echo $?
      sleep 3; tmux -L lab capture-pane -p -t api | grep -v '^$' | tail -n 3
      ```
      Algo como (la línea larga se parte en el panel de 80 columnas):
      ```
      sin implementar: %0 kit-run-216 sleep 2; echo compilado
      1
      $?; tmux wait-for -S kit-run-216
      compilado
      alumno@bc-tmux-lab:/tmp/lab09$
      ```
      El script no esperó: sale en el acto.
   2. **TODO 2 — esperar con límite.** Descomenta el bloque
      `if ! timeout ... wait-for "$channel"; then ... exit 124; fi`.
      ```bash
      tmux -L lab send-keys -t api clear Enter
      time ./starter/run-and-wait api 'sleep 2; echo compilado'; echo $?
      WAIT_SECONDS=1 ./starter/run-and-wait api 'sleep 3; echo tarde'; echo $?
      sleep 3
      ```
      Algo como:
      ```
      sin implementar: %0 kit-run-234 sleep 2; echo compilado

      real	0m2.022s
      user	0m0.005s
      sys	0m0.014s
      1
      run-and-wait: sin respuesta tras 1 s; el comando sigue en %0
      124
      ```
      Ahora espera los 2 s. El `sleep 3` final deja terminar el comando
      tardío antes de seguir.
   3. **TODO 3 — el código de salida.** Borra el `echo "sin implementar..."`
      y su `exit 1`, y descomenta
      `exit "$(tmx display -p -t "$pane" '#{@kit-run-rc}')"`.
      ```bash
      tmux -L lab send-keys -t api clear Enter
      ./starter/run-and-wait api 'sleep 2; echo compilado'; echo $?
      ./starter/run-and-wait api 'sleep 1; false'; echo $?
      tmux -L lab display -p -t api '#{@kit-run-rc}'
      ./starter/run-and-wait nada 'true'; echo $?
      ```
      ```
      0
      1
      1
      run-and-wait: no existe el target 'nada'
      1
      ```
      El script sale con el código del comando del panel: lo puedes usar en
      un `if` o en `&&`.

6. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf /tmp/lab09
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] Explicas por qué `tmux wait-for -S` funciona dentro del panel sin `-L` (paso 1)
- [ ] Explicas por qué no hay carrera si la señal llega antes que la espera (paso 3)
- [ ] Explicas por qué `timeout 2 tmx ...` sale con 127 (paso 4)
- [ ] `./starter/run-and-wait api 'sleep 2; echo compilado'` tarda ~2 s y sale con 0; con `'sleep 1; false'` sale con 1 (paso 5.3)
- [ ] Con `WAIT_SECONDS=1` y un comando de 3 s sale con 124 (paso 5.2)

## Reto extra

Tras un 124, el comando sigue y su `wait-for -S` llega cuando ya nadie
espera: la señal queda guardada en el servidor para siempre. Compruébalo con
un nombre de canal fijo y dos ejecuciones seguidas: la segunda vuelve antes
de tiempo. ¿Por qué el `$$` en el nombre del canal lo evita?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Enviar teclas con cuidado](../lab-03-enviar-teclas-con-cuidado/README.md) | [Lab 05 — Idempotencia](../lab-05-idempotencia/README.md) → |

[↑ Semana 09](../../README.md)
