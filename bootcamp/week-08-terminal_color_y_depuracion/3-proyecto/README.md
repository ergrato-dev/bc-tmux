# Proyecto Semana 08 — tmux-kit: terminal, color y diagnóstico

⏱ Duración estimada: ~3 h

## Contexto

Tu status line de la semana 07 usa colores hex (`#3fb950`), pero según dónde la abras se ve distinta: en el portátil, verde vivo; por SSH desde el equipo de un compañero, un verde apagado. Neovim tarda medio segundo en salir de insertar, el subrayado ondulado de los errores del LSP sale recto y `C-Enter` hace lo mismo que `Enter`. Nada de eso es un fallo de tu config de la status line: es cómo habla tmux con la terminal.

Esta semana el kit aprende a hablar con tu terminal en un módulo nuevo, `conf.d/40-terminal.conf`: el `TERM` de dentro, lo que sabe hacer la terminal de fuera (color de 24 bits, undercurl, teclas extendidas), el foco y el passthrough. Y como la próxima vez que algo se vea raro no quieres repetir la investigación, escribes **`bin/kit-doctor`**, un diagnóstico que no toca nada, y **`docs/diagnostico.md`**, la guía síntoma → causa → comando.

```
ok     version           tmux 3.4 >= 3.4: ok
ok     terminfo          tmux-256color instalado
ok     servidor          /tmp/tmux-1000/kit (tmux 3.4)
fallo  escape-time       500 ms: el Esc llega tarde, baja a 10-50
aviso  color             sin RGB para screen-256color: los colores hex se aproximan a 256
```

## Estructura del proyecto

Se trabaja **sobre `3-proyecto/starter/`**: es lo que corrige el autograding.

```
starter/                   ← tu tmux-kit de la semana 07 + lo nuevo
├── README.md              ← añade la sección Terminal, kit-doctor y la bitácora
├── .gitignore             ← local.conf
├── tmux.conf              ← sin cambios: carga conf.d/*.conf
├── conf.d/
│   ├── 10-options.conf    ← sin cambios
│   ├── 20-bindings.conf   ← sin cambios
│   ├── 30-status.conf     ← sin cambios
│   └── 40-terminal.conf   ← TODOs 1-4 (nuevo)
├── bin/
│   ├── check-version, kit-tree, kit-layout, kit-sessions, kit-copy, kit-option, kit-keys, kit-git-branch   (semanas 01-07)
│   └── kit-doctor         ← TODOs 5-8 (nuevo)
└── docs/
    └── diagnostico.md     ← TODO 9 (nuevo)
```

## Lo que debes construir

1. **TERM de dentro**: `default-terminal tmux-256color`, explícito aunque ya sea el valor por defecto de 3.4.
2. **Features de la terminal de fuera**: `RGB`, `usstyle` y `extkeys` para `xterm*` en `terminal-features`, sin que recargar duplique la lista.
3. **Teclas y foco**: `extended-keys on` y `focus-events on`.
4. **Passthrough**: `allow-passthrough on` (no `all`), con su riesgo explicado.
5. **`bin/kit-doctor`**: una línea `ok|aviso|fallo  tema  detalle` por comprobación, sin efectos secundarios:

   | Tema | ok | aviso | fallo |
   |---|---|---|---|
   | `version` | tmux ≥ 3.4 (con `bin/check-version`) | | más vieja o no está |
   | `terminfo` | `infocmp tmux-256color` funciona | no está `infocmp` | falta `tmux-256color` |
   | `servidor` | hay servidor en el socket | no hay: termina aquí | |
   | `default-terminal` | `tmux-256color` | otro valor | `xterm*` |
   | `escape-time` | ≤ 50 ms | | > 50 ms |
   | `extended-keys` | `on` o `always` | `off` | |
   | `cliente` | hay cliente (el más reciente) | no hay: termina aquí | |
   | `term-fuera` | cualquier otro | `tmux*` o `screen*` | |
   | `color` | `RGB` en `#{client_termfeatures}` | sin `RGB` | |

   Sale con **0** sin fallos (los avisos no cuentan), **1** con algún fallo y **2** si recibe argumentos. Respeta `TMUX_SOCKET` y `TMUX_BIN` y **nunca arranca un servidor**.
6. **`docs/diagnostico.md`**: cómo aislar el problema y una sección por síntoma (colores, undercurl, Esc, C-Enter, portapapeles) con causa, comando y arreglo.
7. **README del kit** con una sección Terminal, `kit-doctor` en la tabla de scripts, `40-terminal.conf` y `docs/diagnostico.md` en la de estructura y la bitácora de la semana.

## Paso a paso

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En la A,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-08-terminal_color_y_depuracion/3-proyecto/starter
   ```
   Todo va contra un servidor aparte, `-L kit`, con ruta absoluta. Las salidas
   son las del laboratorio (`TERM=xterm-256color`); con tu terminal, la lista
   de features y el `TERM` de fuera pueden cambiar.

1. **Punto de partida.**
   ```bash
   tmux -L kit -f "$PWD/tmux.conf" new -d -s api
   tmux -L kit show -sv extended-keys
   tmux -L kit show -gwv allow-passthrough
   tmux -L kit show -s terminal-features
   TMUX_SOCKET=kit bin/kit-doctor; echo $?
   TMUX_SOCKET=kit bin/kit-doctor de-mas; echo $?
   ```
   ```
   off
   off
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   kit-doctor: sin implementar
   1
   Uso: kit-doctor
        TMUX_SOCKET=kit kit-doctor     el servidor de tmux -L kit
   Imprime una línea por comprobación: "ok|aviso|fallo  tema  detalle".
   Salida: 0 sin fallos (puede haber avisos), 1 algún fallo, 2 uso incorrecto.
   2
   ```
   Esas tres entradas de `terminal-features` son las de fábrica de tmux 3.4.
   Conéctate en la B y mira qué sabe tmux de tu terminal. En la A:
   ```bash
   tmux -L kit list-clients -F '#{client_termname} #{client_termfeatures}'
   ```
   ```
   xterm-256color bpaste,ccolour,clipboard,cstyle,focus,title
   ```
   Sin `RGB`: los hex de la paleta se aproximan a 256 colores. Deja el
   servidor arrancado; después de cada TODO de `conf.d/` recarga con
   `tmux -L kit source-file "$PWD/tmux.conf"; echo $?` (tiene que salir `0`).

2. **TERM de dentro (TODO 1, `conf.d/40-terminal.conf`).** Del
   lab-01-dos-term. `set -s default-terminal tmux-256color`: es opción de
   **servidor**. El comentario explica por qué no `xterm-256color` (los
   programas mandarían secuencias de xterm) y por qué escribirlo si ya es el
   valor por defecto.
   ```bash
   tmux -L kit set -s default-terminal xterm-256color
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -sv default-terminal
   ```
   ```
   tmux-256color
   ```
   Solo lo ven los paneles **nuevos**: en uno abierto antes, `echo $TERM`
   sigue con el valor viejo.

3. **Features de la terminal de fuera (TODO 2).** Del
   lab-03-color-de-24-bits. `terminal-features` es una **lista**:
   `set -sa terminal-features "xterm*:RGB:usstyle:extkeys"` añade una entrada
   cada vez que recargas. Delante, `set -su terminal-features` la devuelve a
   las tres de fábrica: el mismo patrón que `update-environment` en
   `10-options.conf`.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -s terminal-features
   ```
   ```
   terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
   terminal-features[1] screen*:title
   terminal-features[2] rxvt*:ignorefkeys
   terminal-features[3] xterm*:RGB:usstyle:extkeys
   ```
   Si ves `[4]` y `[5]`, falta el `-u`. Las features se calculan **al
   conectarse**: desconecta la B (`prefix` `d`), vuelve con
   `tmux -L kit attach -t api` y repite el `list-clients` del paso 1:
   ```
   xterm-256color bpaste,ccolour,clipboard,cstyle,extkeys,focus,RGB,title,usstyle
   ```
   En la B, `printf '\e[38;2;255;100;0mnaranja\e[0m\n'` sale naranja de
   verdad si tu terminal tiene 24 bits (eso solo lo ves en tu equipo).

4. **Teclas y foco (TODO 3).** Del lab-04-teclas-extendidas.
   `set -s extended-keys on` y `set -s focus-events on`. El comentario dice
   por qué `on` y no `always`.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -sv extended-keys
   tmux -L kit show -sv focus-events
   ```
   ```
   on
   on
   ```

5. **Passthrough (TODO 4).** Del lab-05-passthrough-y-estilos.
   `allow-passthrough` es de **panel**: `setw -g allow-passthrough on`. El
   comentario explica qué deja pasar y por qué no `all`.
   ```bash
   tmux -L kit source-file "$PWD/tmux.conf"
   tmux -L kit show -gwv allow-passthrough
   ```
   ```
   on
   ```

6. **`kit-doctor` sin servidor (TODO 5 y primera mitad del 6).** Del
   lab-02-terminfo. El uso y la función `report` ya están: `report ok version
   "detalle"` imprime la línea alineada y `report fallo ...` marca la salida.
   - TODO 5: `if out=$("$(dirname "$0")/check-version" 3.4 2>&1); then report ok version "$out"; else report fallo version "$out"; fi`.
     Después, `command -v infocmp` (si no está, aviso) e
     `infocmp tmux-256color >/dev/null 2>&1`.
   - TODO 6, primera parte: `if ! tmx list-sessions >/dev/null 2>&1; then report aviso servidor "..."; exit "$failed"; fi`.
     `list-sessions` solo pregunta; `show-options` o `display-message`
     **arrancarían** un servidor vacío.

   Para probar antes de terminar, borra ya las dos líneas del TODO 8 y pon
   `exit "$failed"` al final.
   ```bash
   TMUX_SOCKET=nadie bin/kit-doctor; echo $?
   tmux -L nadie list-sessions
   ```
   ```
   ok     version           tmux 3.4 >= 3.4: ok
   ok     terminfo          tmux-256color instalado
   aviso  servidor          no hay servidor tmux en ese socket: arráncalo y repite
   0
   error connecting to /tmp/tmux-1000/nadie (No such file or directory)
   ```
   La última línea es la prueba de que el doctor no arrancó nada.

7. **`kit-doctor` con servidor (resto del TODO 6).** Del
   lab-06-depurar-una-terminal-rota. `tmx show -sv` de `default-terminal`,
   `escape-time` y `extended-keys`, con un `case` para `xterm*` y
   `(( escape <= 50 ))`. Rompe el servidor a propósito con lo que rompía el
   lab 06 (desconecta antes la B con `prefix` `d`):
   ```bash
   tmux -L kit set -s escape-time 500
   tmux -L kit set -s default-terminal xterm-256color
   tmux -L kit set -s extended-keys off
   TMUX_SOCKET=kit bin/kit-doctor; echo $?
   ```
   ```
   ok     version           tmux 3.4 >= 3.4: ok
   ok     terminfo          tmux-256color instalado
   ok     servidor          /tmp/tmux-1000/kit (tmux 3.4)
   fallo  default-terminal  xterm-256color: dentro de tmux va tmux-256color
   fallo  escape-time       500 ms: el Esc llega tarde, baja a 10-50
   aviso  extended-keys     off: los programas no reciben C-Enter ni S-Enter
   1
   ```
   (Hasta el TODO 7, sin la línea `cliente`.) Arréglalo recargando la config:
   `tmux -L kit source-file "$PWD/tmux.conf"`.

8. **`kit-doctor` con cliente (TODOs 7 y 8).**
   - TODO 7: `tmx list-clients -F '#{client_activity} #{client_name} #{client_termname} #{client_termfeatures}' | sort -rn | head -n 1`
     da el cliente usado por última vez; `read -r _ name outer features <<<"$client"`
     lo separa. Sin cliente, aviso y `exit "$failed"`. Para buscar `RGB` sin
     confundirlo con otra palabra: `[[ ",$features," == *,RGB,* ]]`.
   - TODO 8: `exit "$failed"` al final (si no lo pusiste ya en el paso 6).

   Conecta la B y en la A:
   ```bash
   TMUX_SOCKET=kit bin/kit-doctor; echo $?
   ```
   ```
   ok     version           tmux 3.4 >= 3.4: ok
   ok     terminfo          tmux-256color instalado
   ok     servidor          /tmp/tmux-1000/kit (tmux 3.4)
   ok     default-terminal  tmux-256color
   ok     escape-time       10 ms
   ok     extended-keys     on
   ok     cliente           /dev/pts/1
   ok     term-fuera        xterm-256color
   ok     color             24 bits (RGB)
   0
   ```
   Ahora una terminal que no tiene 24 bits: desconecta la B y conéctala con
   `TERM=screen-256color tmux -L kit attach -t api`. En la A:
   ```bash
   TMUX_SOCKET=kit bin/kit-doctor | tail -3
   ```
   ```
   ok     cliente           /dev/pts/1
   aviso  term-fuera        screen-256color: ¿tmux dentro de tmux?
   aviso  color             sin RGB para screen-256color: los colores hex se aproximan a 256
   ```
   Son avisos, no fallos: sale con 0. Desconecta la B y vuelve a conectarla
   sin el `TERM=`. Y `shellcheck bin/kit-doctor; echo $?` tiene que dar `0`.

9. **`docs/diagnostico.md` (TODO 9).** Del lab-06-depurar-una-terminal-rota.
   Una primera sección para **aislar** (`bin/kit-doctor`,
   `tmux -L limpio -f /dev/null`, `tmux -vvv` y dónde deja los logs,
   `show-messages`) y una sección `## ...` por síntoma, con el nombre del
   síntoma en el título: colores lavados, undercurl ausente, Esc que llega
   tarde, C-Enter que no llega y portapapeles roto. Cada una con la causa, un
   comando para comprobarlo con lo que tiene que salir y el arreglo. Escríbela
   con lo que **viste** en los labs, no de memoria: el autograding solo mira
   los títulos; la rúbrica, que cada comando funcione.
   ```bash
   grep '^## ' docs/diagnostico.md
   ```

10. **README del kit.** En `starter/README.md`: una sección `## Terminal` que
    diga qué fija `40-terminal.conf` y que remita a `kit-doctor` y a la guía;
    la fila de `bin/kit-doctor` en la tabla de scripts; `conf.d/40-terminal.conf`
    y `docs/diagnostico.md` en la de estructura; y la fila `08` en la
    bitácora.

11. **Cierra y verifica.** En la terminal A:
    ```bash
    tmux -L kit kill-server
    cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 08
    ```
    ```
    Semana 08 — Terminal, color y depuración

      ✅ tmux.conf carga sin errores
      ✅ conf.d/40-terminal.conf fija default-terminal en tmux-256color
      ✅ Un cliente xterm-256color tiene la feature RGB
      ✅ Un cliente xterm-256color tiene la feature usstyle
      ✅ Un cliente xterm-256color tiene la feature extkeys
      ✅ Recargar la config no duplica terminal-features
      ✅ extended-keys vale on
      ✅ focus-events vale on
      ✅ allow-passthrough vale on, no all
      ✅ kit-doctor sale con 2 si recibe argumentos
      ✅ Sin servidor, kit-doctor avisa en la línea servidor y no arranca uno
      ✅ Cada línea de kit-doctor es «ok|aviso|fallo  tema  detalle»
      ✅ Con la config del kit y un cliente xterm-256color, kit-doctor sale con 0
      ✅ Con default-terminal xterm-256color, kit-doctor da fallo en default-terminal
      ✅ Con escape-time 500, kit-doctor da fallo en escape-time y sale con 1
      ✅ Con un cliente sin RGB, kit-doctor avisa en la línea color
      ✅ docs/diagnostico.md tiene secciones para colores, undercurl, Esc, C-Enter y portapapeles
      ✅ tmux.conf, conf.d/, bin/ y docs/ no tienen TODOs y bin/ pasa shellcheck

    18/18 comprobaciones superadas.
    ```
    Tarda algo más de un minuto: varias comprobaciones conectan un cliente
    con un `TERM` concreto. Lo que depende de **tu** terminal (si el naranja
    es naranja, si el undercurl ondula, si `C-Enter` llega) no lo ve el
    laboratorio: repásalo en la B con `docs/diagnostico.md` y
    `./scripts/verificar-semana.sh --host 08`.

## Verificación

Al terminar, desde la raíz del repositorio y fuera de tmux:

```bash
cd "$(git rev-parse --show-toplevel)/bootcamp/week-08-terminal_color_y_depuracion/3-proyecto/starter"
tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?
tmux -L kit show -sv extended-keys
tmux -L kit show -s terminal-features | tail -1
TMUX_SOCKET=kit bin/kit-doctor | tail -1
tmux -L kit kill-server
```
```
0
on
terminal-features[3] xterm*:RGB:usstyle:extkeys
aviso  cliente           sin clientes: conéctate para revisar tu terminal
```
```bash
cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh 08
```
```
18/18 comprobaciones superadas.
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 08` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] conf.d/40-terminal.conf fija default-terminal en tmux-256color
- [ ] Un cliente xterm-256color tiene la feature RGB
- [ ] Un cliente xterm-256color tiene la feature usstyle
- [ ] Un cliente xterm-256color tiene la feature extkeys
- [ ] Recargar la config no duplica terminal-features
- [ ] extended-keys vale on
- [ ] focus-events vale on
- [ ] allow-passthrough vale on, no all
- [ ] kit-doctor sale con 2 si recibe argumentos
- [ ] Sin servidor, kit-doctor avisa en la línea servidor y no arranca uno
- [ ] Cada línea de kit-doctor es «ok|aviso|fallo  tema  detalle»
- [ ] Con la config del kit y un cliente xterm-256color, kit-doctor sale con 0
- [ ] Con default-terminal xterm-256color, kit-doctor da fallo en default-terminal
- [ ] Con escape-time 500, kit-doctor da fallo en escape-time y sale con 1
- [ ] Con un cliente sin RGB, kit-doctor avisa en la línea color
- [ ] docs/diagnostico.md tiene secciones para colores, undercurl, Esc, C-Enter y portapapeles
- [ ] tmux.conf, conf.d/, bin/ y docs/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- `40-terminal.conf` agrupado por tema (TERM de dentro, features, teclas y foco, passthrough), cada opción con su alcance explícito (`-s` o `setw -g`).
- Comentarios del porqué: los dos `TERM`, por qué `tmux-256color` y no `xterm-256color`, qué aporta cada feature, por qué `-u` antes de `-a`, por qué `on` y no `always` en `extended-keys`, y el riesgo de `allow-passthrough` y por qué no `all`.
- `kit-doctor` sin efectos secundarios (nunca arranca un servidor ni cambia una opción), reutiliza `check-version` y documenta en la cabecera los códigos de salida y el formato de línea.
- `docs/diagnostico.md` con comandos que funcionan pegados tal cual y lo que tiene que salir; lo que solo se ve en una terminal real, dicho.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.

## Entrega

Commit con el mensaje:
```
feat(week-08): 40-terminal.conf, kit-doctor y guía de diagnóstico
```

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 06 — Depurar una terminal rota](../2-practicas/lab-06-depurar-una-terminal-rota/README.md) | [Rúbrica de evaluación](../rubrica-evaluacion.md) → |

[↑ Semana 08](../README.md)
