# Lab 05 — Auditoría del kit

⏱ Duración estimada: ~60 min

## Objetivo

Escribir un `audit.sh` que revisa un kit (shellcheck, TODOs, tiempo de arranque, `#()` con `status-interval` corto) y dejar en verde el kit de ejemplo, usando `tmux -vvv` para encontrar qué lo frena.

## Contexto

- Antes de entregar o publicar el kit, una pasada mecánica: scripts limpios con `shellcheck`, ningún `TODO` olvidado, un arranque que no se nota y una barra que no lanza procesos sin parar.
- `starter/kit/` es un kit con cuatro defectos a propósito; `starter/audit.sh` tiene cinco TODOs. Primero escribes la auditoría, luego arreglas el kit hasta que salga todo ✅.
- Un `run-shell` sin `-b` en la config **bloquea el arranque** hasta que el comando termina. Un `#()` de la barra se relanza en cada refresco (`status-interval`).

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` vacío). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-05-auditoria-del-kit
   K="$PWD/starter/kit"
   ./starter/audit.sh "$K"; echo $?
   ```
   ```
   0
   ```
   Como en el lab 04, el starter no comprueba nada y sale con 0. Arranca su
   propio servidor (`-L kit-audit`) con un HOME vacío: tu tmux no se toca.

1. **TODO 1 — shellcheck.** Escribe el `if out=$(shellcheck ...)` del
   TODO 1:
   ```bash
   ./starter/audit.sh "$K"; echo $?
   ```
   ```
   ❌ shellcheck limpio en bin/: SC2162 
   0
   ```
   Mira el detalle a mano:
   ```bash
   shellcheck "$K/bin/kit-sessions" | head -3
   ```
   ```

   In /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-05-auditoria-del-kit/starter/kit/bin/kit-sessions line 5:
   tmx list-sessions -F '#S #{session_windows}' | while read name n; do
   ```
   No lo arregles aún: primero la auditoría completa.

2. **TODO 2 — TODOs olvidados.** Escribe el `if todo=$(...)` del TODO 2.
   `grep` sale con 0 si **encuentra** algo, así que aquí encontrar es
   fallar:
   ```bash
   ./starter/audit.sh "$K"; echo $?
   ```
   ```
   ❌ shellcheck limpio en bin/: SC2162 
   ❌ sin TODOs: ./conf.d/10-options.conf:4:# TODO: decidir si subo history-limit
   0
   ```

3. **TODO 3 — tiempo de arranque.** Primero mídelo a mano con `time`:
   ```bash
   H=$(mktemp -d)
   time env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab -f "$K/tmux.conf" new -d -s lab
   tmux -L lab kill-server
   ```
   Algo como (los milisegundos cambian):
   ```

   real	0m1.014s
   user	0m0.003s
   sys	0m0.003s
   ```
   Un segundo para un `new -d`. Escribe el TODO 3 con las cuatro líneas de
   la pista y el `if`:
   ```bash
   ./starter/audit.sh "$K"; echo $?
   ```
   Algo como:
   ```
   ❌ shellcheck limpio en bin/: SC2162 
   ❌ sin TODOs: ./conf.d/10-options.conf:4:# TODO: decidir si subo history-limit
   ❌ arranque en menos de 300 ms: 1014 ms
   0
   ```

4. **Quién frena el arranque: `tmux -vvv`.** Con `-vvv`, tmux escribe un
   log por proceso **en el directorio actual**. Lánzalo en uno temporal:
   ```bash
   D=$(mktemp -d); cd "$D"
   env -u XDG_CONFIG_HOME HOME="$H" tmux -vvv -L l13-v -f "$K/tmux.conf" new -d -s v
   tmux -L l13-v kill-server
   ls
   grep loading tmux-server-*.log | cut -c1-120
   ```
   Algo como (cambian los pid y las horas):
   ```
   tmux-client-9.log
   tmux-out-11.log
   tmux-server-11.log
   1793748233.270520 loading /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-05-auditoria-del-kit/st
   1793748233.270764 loading /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-05-auditoria-del-kit/st
   1793748233.270947 loading /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-05-auditoria-del-kit/st
   ```
   Cada línea empieza por la hora en segundos: los tres archivos se
   leen en menos de un milisegundo. El tiempo se va en un trabajo:
   ```bash
   grep -E 'run job|job died' tmux-server-*.log | cut -c1-100
   cd - > /dev/null; rm -rf "$D"
   ```
   Algo como:
   ```
   1793748246.782680 run job 0x5d0b6d0ef760: sleep 1; tmux set -g @kit-weather soleado, pid 12
   1793748247.788517 job died 0x5d0b6d0ef760: sleep 1; tmux set -g @kit-weather soleado, pid 12
   ```
   Un segundo entre `run job` y `job died`: es el `run-shell` de
   `conf.d/30-status.conf`, y sin `-b` la carga lo espera.

5. **TODO 4 — `#()` y `status-interval`.** Escribe el TODO 4:
   ```bash
   ./starter/audit.sh "$K"; echo $?
   ```
   Algo como:
   ```
   ❌ shellcheck limpio en bin/: SC2162 
   ❌ sin TODOs: ./conf.d/10-options.conf:4:# TODO: decidir si subo history-limit
   ❌ arranque en menos de 300 ms: 1012 ms
   ❌ status-interval >= 5 con #() en la barra: status-interval 1
   0
   ```
   `status-right` lanza `sleep 1; whoami` y la barra se refresca cada
   segundo: con un cliente conectado hay siempre un proceso de la barra
   corriendo.

6. **TODO 5 — el código de salida.** Cambia `exit 0` por
   `exit "$failed"` y borra las dos líneas de arriba del todo (el aviso y
   el `# shellcheck disable=...`):
   ```bash
   ./starter/audit.sh "$K"; echo $?
   ./starter/audit.sh "$PWD"; echo $?
   shellcheck starter/audit.sh; echo $?
   ```
   Algo como:
   ```
   ❌ shellcheck limpio en bin/: SC2162 
   ❌ sin TODOs: ./conf.d/10-options.conf:4:# TODO: decidir si subo history-limit
   ❌ arranque en menos de 300 ms: 1011 ms
   ❌ status-interval >= 5 con #() en la barra: status-interval 1
   1
   uso: audit.sh RUTA_DEL_KIT (la carpeta que tiene tmux.conf)
   2
   0
   ```
   La carpeta del lab no tiene `tmux.conf`: uso incorrecto, 2.

7. **Arregla el kit.** Cuatro cambios en `starter/kit/`:
   - `bin/kit-sessions`: `while read -r name n` (`-r` deja las `\` tal cual).
   - `conf.d/10-options.conf`: borra la línea `# TODO: ...` (decide: el
     `history-limit 5000` se queda).
   - `conf.d/30-status.conf`: `run-shell -b '...'`, en segundo plano.
   - `conf.d/30-status.conf`: `set -g status-interval 5`.

   ```bash
   ./starter/audit.sh "$K"; echo $?
   ```
   Algo como (los milisegundos cambian):
   ```
   ✅ shellcheck limpio en bin/
   ✅ sin TODOs
   ✅ arranque en 8 ms
   ✅ status-interval 5
   0
   ```

8. **El precio de `-b`.** El dato ya no está listo al arrancar:
   ```bash
   tmux -L lab -f "$K/tmux.conf" new -d -s lab
   tmux -L lab show -gv @kit-weather; echo $?
   sleep 1.5
   tmux -L lab show -gv @kit-weather
   tmux -L lab kill-server
   ```
   ```
   invalid option: @kit-weather
   1
   soleado
   ```
   Durante el primer segundo la opción no existe. Lo que la use (la
   barra, un script) tiene que soportar que aún no esté. A cambio, el
   arranque no espera.

9. **Limpia.**
   ```bash
   rm -rf "$H"
   ```
   (sin salida)

   Sal del laboratorio con `exit`.

## Criterios de éxito

- [ ] Sobre el kit sin arreglar, `audit.sh` imprime los cuatro ❌ y sale con 1 (paso 6)
- [ ] `audit.sh "$PWD"` sale con 2 y `shellcheck starter/audit.sh` con 0 (paso 6)
- [ ] El log de `tmux -vvv` muestra un segundo entre `run job` y `job died` (paso 4)
- [ ] Con el kit arreglado, cuatro ✅, arranque por debajo de 300 ms y salida 0 (paso 7)
- [ ] `show -gv @kit-weather` falla justo al arrancar e imprime `soleado` tras `sleep 1.5` (paso 8)

## Reto extra

Añade a `audit.sh` un punto "sin `~/.tmux.conf` en el kit": que falle si
algún archivo del kit menciona `~/.tmux.conf` o `$HOME/.tmux.conf` fuera de
un comentario. Pruébalo con una mutación en una copia del kit, como en el
lab 04.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 04 — Checks propios](../lab-04-checks-propios/README.md) | [Lab 06 — Instalador roto](../lab-06-instalador-roto/README.md) → |

[↑ Semana 13](../../README.md)
