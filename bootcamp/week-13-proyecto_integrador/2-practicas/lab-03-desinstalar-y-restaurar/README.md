# Lab 03 — Desinstalar y restaurar

⏱ Duración estimada: ~60 min

## Objetivo

Añadir `--uninstall` al instalador para que borre el enlace solo si apunta a este kit y deje la config anterior como estaba.

## Contexto

- `starter/install.sh` es la solución del lab 02 con dos cambios: lee las opciones en un bucle (admite `--dry-run --uninstall` juntas) y la comprobación "¿es mi enlace?" vive en `is_ours`. La función `uninstall` tiene cinco TODOs.
- Desinstalar es lo contrario de instalar: borrar el enlace y devolver el backup más reciente a su sitio. Repetirlo no debe romper nada.
- Regla de oro: **solo se borra lo que creaste tú**. Una config real o el enlace de otro kit salen con 1 y quedan intactos.

## Instrucciones

0. **Dónde.** Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Estás fuera de tmux (`echo "$TMUX"` vacío). Dentro:
   ```bash
   cd /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-03-desinstalar-y-restaurar
   H=$(mktemp -d); I="$PWD/starter/install.sh"
   inst() { env -u XDG_CONFIG_HOME HOME="$H" "$I" "$@"; }
   ```
   (sin salida)

   Igual que en el lab 02: `H` es el HOME de pruebas y `inst` lanza el
   instalador con él. `/tmp/tmp.mvWg74oTxt` es un ejemplo: tu `H` tiene
   otro nombre.

1. **TODO 1 — la opción.** Prepara un HOME con config propia, instala y
   pide desinstalar:
   ```bash
   mkdir -p "$H/.config/tmux"
   echo 'set -g status-style bg=red' > "$H/.config/tmux/tmux.conf"
   inst
   inst --uninstall; echo $?
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.mvWg74oTxt/.config/tmux ya existe, lo muevo a /tmp/tmp.mvWg74oTxt/.config/tmux.bak.20261103-231723
   install.sh: /tmp/tmp.mvWg74oTxt/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-03-desinstalar-y-restaurar/starter
   install.sh: opción desconocida: --uninstall
   2
   ```
   Añade bajo el TODO 1 la rama `--uninstall) mode=uninstall ;;`. Repite:
   ```bash
   inst --uninstall; echo $?
   ```
   ```
   install.sh: --uninstall sin implementar
   0
   ```

2. **TODO 2 — nada que desinstalar.** Escribe el `if` del TODO 2. Pruébalo
   con un `XDG_CONFIG_HOME` que no existe (así no tocas lo instalado en el
   paso 1):
   ```bash
   env HOME="$H" XDG_CONFIG_HOME="$H/vacio" "$I" --uninstall; echo $?
   ```
   Algo como:
   ```
   install.sh: no hay nada que desinstalar en /tmp/tmp.mvWg74oTxt/vacio/tmux
   0
   ```
   Pedir dos veces el mismo estado final no es un error: sale con 0.

3. **TODO 3 — lo que no es tuyo.** Un enlace que apunta a otro sitio:
   ```bash
   mkdir -p "$H/otro"
   ln -s /tmp "$H/otro/tmux"
   env HOME="$H" XDG_CONFIG_HOME="$H/otro" "$I" --uninstall; echo $?
   ```
   ```
   install.sh: --uninstall sin implementar
   0
   ```
   Sale con 0 sin hacer nada: una vez escrito el TODO 4, lo borraría.
   Escribe el `if ! is_ours` del TODO 3 (mensaje a stderr con `>&2`,
   `return 1`). Repite, y prueba también con un directorio real:
   ```bash
   env HOME="$H" XDG_CONFIG_HOME="$H/otro" "$I" --uninstall; echo $?
   readlink "$H/otro/tmux"
   mkdir -p "$H/real/tmux"
   env HOME="$H" XDG_CONFIG_HOME="$H/real" "$I" --uninstall; echo $?
   rm -rf "$H/otro" "$H/real"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.mvWg74oTxt/otro/tmux no es un enlace a este kit, no lo toco
   1
   /tmp
   install.sh: /tmp/tmp.mvWg74oTxt/real/tmux no es un enlace a este kit, no lo toco
   1
   ```
   Como `uninstall` es lo último antes de `exit`, su `return 1` es el
   código de salida del script.

4. **TODO 4 — borrar el enlace.** `run rm "$target"` y el `echo`; borra el
   `echo "... sin implementar"`. Usa `run`: así `--dry-run` también vale
   aquí. Luego comprueba que tmux ya no carga el kit:
   ```bash
   inst --uninstall; echo $?
   ls "$H/.config"
   env -u XDG_CONFIG_HOME HOME="$H" tmux -L lab new -d -s lab
   tmux -L lab show -gv prefix
   tmux -L lab kill-server
   ```
   Algo como:
   ```
   install.sh: enlace borrado: /tmp/tmp.mvWg74oTxt/.config/tmux
   0
   tmux.bak.20261103-231723
   C-b
   ```
   El kit ya no se carga, pero la config de antes sigue en el backup: el
   usuario se queda sin ninguna.

5. **TODO 5 — restaurar.** Escribe el bloque del TODO 5. Vuelve a
   instalar, ensaya y desinstala de verdad:
   ```bash
   inst
   inst --dry-run --uninstall; echo $?
   inst --uninstall; echo $?
   ls "$H/.config"
   cat "$H/.config/tmux/tmux.conf"
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.mvWg74oTxt/.config/tmux -> /bc-tmux/bootcamp/week-13-proyecto_integrador/2-practicas/lab-03-desinstalar-y-restaurar/starter
   haría: rm /tmp/tmp.mvWg74oTxt/.config/tmux
   install.sh: enlace borrado: /tmp/tmp.mvWg74oTxt/.config/tmux
   haría: mv /tmp/tmp.mvWg74oTxt/.config/tmux.bak.20261103-231723 /tmp/tmp.mvWg74oTxt/.config/tmux
   install.sh: restaurado /tmp/tmp.mvWg74oTxt/.config/tmux.bak.20261103-231723
   0
   install.sh: enlace borrado: /tmp/tmp.mvWg74oTxt/.config/tmux
   install.sh: restaurado /tmp/tmp.mvWg74oTxt/.config/tmux.bak.20261103-231723
   0
   tmux
   set -g status-style bg=red
   ```
   La instalación no hizo backup (el paso 4 ya había dejado el sitio
   libre) y la desinstalación devolvió el que había. Con varios backups,
   el glob los ordena por nombre y la fecha `AAAAMMDD-HHMMSS` deja el más
   reciente al final.

6. **Repetir y el caso sin backup.**
   ```bash
   inst --uninstall; echo $?
   rm -rf "$H"; H=$(mktemp -d)
   inst > /dev/null
   inst --uninstall; echo $?
   ls -A "$H/.config"
   shellcheck starter/install.sh; echo $?
   ```
   Algo como:
   ```
   install.sh: /tmp/tmp.mvWg74oTxt/.config/tmux no es un enlace a este kit, no lo toco
   1
   install.sh: enlace borrado: /tmp/tmp.HMqtSdXjoS/.config/tmux
   0
   0
   ```
   La segunda desinstalación ve una config real (la restaurada) y no la
   toca. En un HOME sin backup, `nullglob` deja la lista vacía y no se
   restaura nada: `ls -A` no imprime nada. Sin `nullglob`, el glob sin
   coincidencias se queda como el texto literal `tmux.bak.*` y el `mv`
   fallaría.

7. **Limpia.**
   ```bash
   rm -rf "$H"
   ```
   (sin salida)

   Sal del laboratorio con `exit`.

## Criterios de éxito

- [ ] `--uninstall` sobre un `XDG_CONFIG_HOME` vacío imprime `no hay nada que desinstalar` y sale con 0 (paso 2)
- [ ] Sobre un enlace a `/tmp` o un directorio real sale con 1 y `readlink` sigue imprimiendo `/tmp` (paso 3)
- [ ] Tras `--uninstall`, tmux arranca con `C-b` (paso 4)
- [ ] `--dry-run --uninstall` solo imprime `haría:` y la desinstalación real deja `tmux.conf` con `set -g status-style bg=red` (paso 5)
- [ ] Una segunda desinstalación sale con 1 y `shellcheck` con 0 (paso 6)

## Reto extra

Hoy instalar → desinstalar → instalar → desinstalar deja un único
backup, pero si el usuario instala dos veces sobre configs distintas se
acumulan. Añade `--list-backups` que imprima los `tmux.bak.*` existentes,
del más nuevo al más viejo, y salga con 0 aunque no haya ninguno.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — Instalador idempotente](../lab-02-instalador-idempotente/README.md) | [Lab 04 — Checks propios](../lab-04-checks-propios/README.md) → |

[↑ Semana 13](../../README.md)
