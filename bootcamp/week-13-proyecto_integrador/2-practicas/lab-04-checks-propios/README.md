# Lab 04 — Checks propios

⏱ Duración estimada: ~60 min

## Objetivo

Escribir un `tests/run` que comprueba el kit en un servidor aislado y demostrar, rompiendo el kit a propósito, que cada check sabe fallar.

## Contexto

- Los checks del autograding son de otros; `tests/run` es del dueño del kit: lo lanzas antes de cada commit y te dice en segundos si rompiste algo.
- Tres reglas: servidor propio (`-L`, configurable con `TMUX_SOCKET`), HOME vacío (ninguna config tuya se cuela) y un `trap` que lo limpia todo aunque el script falle a medias.
- Un check que nunca falla no prueba nada. **Mutación**: rompes el kit a propósito y el check tiene que ponerse en ❌.

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` vacío). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-04-checks-propios
   ls starter starter/conf.d
   ```
   ```
   starter:
   conf.d
   tests
   tmux.conf

   starter/conf.d:
   10-options.conf
   20-bindings.conf
   ```
   El kit (`tmux.conf` + `conf.d/`, prefix `C-a`) y `tests/run` con seis
   TODOs. `tests/run` arranca su propio servidor con `-f /dev/null` y
   carga el kit con `source-file`: tu sesión de tmux no se toca.

1. **Un test que siempre pasa.** Lanza el starter:
   ```bash
   ./starter/tests/run; echo $?
   tmux -L kit-test ls
   tmux -L kit-test kill-server
   ```
   Algo como (cambia la fecha):
   ```
   0
   test: 1 windows (created Tue Nov  3 23:19:46 2026)
   ```
   No comprueba nada, sale con 0 y deja un servidor vivo. Las dos cosas
   se arreglan en los TODOs.

2. **TODO 1 — `TMUX_SOCKET`.** Cambia `socket="kit-test"` por
   `socket="${TMUX_SOCKET:-kit-test}"`. Así el socket se elige desde fuera
   (el autograding exporta `TMUX_SOCKET=bc-check`):
   ```bash
   TMUX_SOCKET=l13-otro ./starter/tests/run; echo $?
   tmux -L l13-otro ls
   tmux -L l13-otro kill-server
   ```
   Algo como:
   ```
   0
   test: 1 windows (created Tue Nov  3 23:19:46 2026)
   ```
   El servidor está ahora en `l13-otro`, pero sigue vivo.

3. **TODO 2 — `trap`.** Quita el `#` del `trap` del TODO 2. Las comillas
   simples importan: el texto se evalúa al salir, cuando `tmx` y `$home`
   ya existen. Repite:
   ```bash
   ./starter/tests/run; echo $?
   tmux -L kit-test ls; echo $?
   ```
   ```
   0
   no server running on /tmp/tmux-1000/kit-test
   1
   ```
   `trap ... EXIT` corre en cualquier salida, también si `set -e` corta el
   script por un error.

4. **TODO 3 — la config carga.** Escribe el `if out=$(...)` del TODO 3.
   `$(... 2>&1)` guarda el mensaje de error y el `if` mira el código de
   salida de `source-file` a la vez:
   ```bash
   ./starter/tests/run; echo $?
   ```
   ```
   ✅ la config carga sin errores
   0
   ```

5. **TODO 4 — prefix.** Escribe el check del TODO 4:
   ```bash
   ./starter/tests/run; echo $?
   ```
   ```
   ✅ la config carga sin errores
   ✅ prefix C-a
   0
   ```

6. **TODO 5 y TODO 6 — recarga y código de salida.** El TODO 5 guarda
   `tmx show -g`, carga el kit otra vez (lo que hace `prefix` `r`) y
   compara. El TODO 6 cambia `exit 0` por `exit "$failed"`; borra también
   las dos líneas de arriba del todo (el aviso y el
   `# shellcheck disable=...`):
   ```bash
   ./starter/tests/run; echo $?
   shellcheck starter/tests/run; echo $?
   ```
   ```
   ✅ la config carga sin errores
   ✅ prefix C-a
   ✅ recargar dos veces no cambia nada
   0
   0
   ```
   Todo en verde. Falta saber si esos checks sirven.

7. **Mutación 1 — el prefix.** No rompas `starter/`: copia el kit a un
   directorio temporal y rompe la copia. `tests/run` comprueba el kit
   donde vive, así que comprueba la copia:
   ```bash
   M=$(mktemp -d); cp -r starter/. "$M"
   sed -i 's/prefix C-a/prefix C-b/' "$M/conf.d/10-options.conf"
   "$M/tests/run"; echo $?
   rm -rf "$M"
   ```
   ```
   ✅ la config carga sin errores
   ❌ prefix C-a: es C-b
   ✅ recargar dos veces no cambia nada
   1
   ```
   Solo cae el check que toca, y con un mensaje que dice qué encontró.

8. **Mutación 2 — una errata.** Una opción mal escrita:
   ```bash
   M=$(mktemp -d); cp -r starter/. "$M"
   echo 'set -g status-rigth " #H "' >> "$M/conf.d/10-options.conf"
   "$M/tests/run"; echo $?
   ```
   ```
   ❌ la config carga sin errores: invalid option: status-rigth
   ✅ prefix C-a
   ✅ recargar dos veces no cambia nada
   1
   ```
   ¿Y si el check arrancara tmux con `-f`, como haces a mano?
   ```bash
   tmux -L l13-m -f "$M/tmux.conf" new -d -s m; echo $?
   tmux -L l13-m show -gv prefix
   tmux -L l13-m kill-server
   rm -rf "$M"
   ```
   ```
   0
   C-a
   ```
   Con `-f`, tmux se salta la línea mala, arranca y sale con 0: el error
   no se ve. Por eso el check usa `-f /dev/null` y luego `source-file`, que
   sí sale con 1.

9. **Mutación 3 — algo que crece al recargar.** `set -ga` añade a una
   lista; en cada recarga, otra vez:
   ```bash
   M=$(mktemp -d); cp -r starter/. "$M"
   echo 'set -ga update-environment KIT_DEMO' >> "$M/conf.d/10-options.conf"
   "$M/tests/run"; echo $?
   rm -rf "$M"
   ```
   ```
   ✅ la config carga sin errores
   ✅ prefix C-a
   ❌ recargar dos veces no cambia nada: > update-environment[9] KIT_DEMO
   1
   ```
   La primera carga añade `KIT_DEMO` y la segunda lo vuelve a añadir en
   otra posición. Un `set -ga` en `status-right` no lo detectaría: el
   `set -g status-right` de antes lo reinicia en cada carga.

10. **Tu servidor está a salvo.** El `trap` hace `kill-server` en su
    socket. Con `TMUX_SOCKET` puedes elegir uno que no sea el tuyo:
    ```bash
    tmux -L kit-test new -d -s mio
    TMUX_SOCKET=l13-otro ./starter/tests/run > /dev/null
    tmux -L kit-test ls
    tmux -L kit-test kill-server
    ```
    Algo como:
    ```
    mio: 1 windows (created Tue Nov  3 23:19:47 2026)
    ```
    Sin `TMUX_SOCKET`, `tests/run` habría matado `mio`: el socket por
    defecto tiene que ser uno que nadie use para trabajar. Sal del
    laboratorio con `exit`.

## Criterios de éxito

- [ ] Tras el TODO 2, `tmux -L kit-test ls` imprime `no server running on ...` y sale con 1 (paso 3)
- [ ] `./starter/tests/run` imprime tres ✅ y sale con 0; `shellcheck` sale con 0 (paso 6)
- [ ] Con el prefix mutado, solo cae `❌ prefix C-a: es C-b` y sale con 1 (paso 7)
- [ ] Con `status-rigth`, `❌ la config carga sin errores: invalid option: status-rigth`, mientras `-f` arranca con 0 (paso 8)
- [ ] Con `set -ga update-environment`, cae el check de recarga (paso 9)
- [ ] Con `TMUX_SOCKET=l13-otro`, la sesión `mio` de `-L kit-test` sigue viva (paso 10)

## Reto extra

Añade un check "`prefix` `r` está definido": `tmx list-keys -T prefix r`
sale con 1 si la tecla no existe. Escribe su mutación (borra
`conf.d/20-bindings.conf` en la copia) y comprueba que cae solo ese check.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 03 — Desinstalar y restaurar](../lab-03-desinstalar-y-restaurar/README.md) | [Lab 05 — Auditoría del kit](../lab-05-auditoria-del-kit/README.md) → |

[↑ Semana 13](../../README.md)
