# Labs — Semana 08: Terminal, color y depuración

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-dos-term](lab-01-dos-term/) | El `TERM` de fuera (`#{client_termname}`) y el de dentro (`default-terminal`), y qué se rompe si el de dentro miente | ~60 min |
| 2 | [lab-02-terminfo](lab-02-terminfo/) | `infocmp`, `tput` y una entrada propia con `RGB` compilada con `tic` en un directorio temporal | ~60 min |
| 3 | [lab-03-color-de-24-bits](lab-03-color-de-24-bits/) | La feature `RGB` en `terminal-features`, comprobada en pantalla y en los bytes (`38;2` frente a `38;5`) | ~60 min |
| 4 | [lab-04-teclas-extendidas](lab-04-teclas-extendidas/) | `C-Enter` distinta de `Enter`: binding, `extended-keys` y la feature `extkeys` | ~60 min |
| 5 | [lab-05-passthrough-y-estilos](lab-05-passthrough-y-estilos/) | `allow-passthrough` y la envoltura `\ePtmux;`, subrayado ondulado con `usstyle` | ~60 min |
| 6 | [lab-06-depurar-una-terminal-rota](lab-06-depurar-una-terminal-rota/) | Depurar una config con cinco fallos (rota a propósito) con `-vvv`, `show-messages -T` y `-f /dev/null` | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Dos terminales fuera de tmux.** Todos los labs usan una
   **terminal A** para los comandos y una **terminal B** para conectarte al
   servidor del lab. Ninguna de las dos puede estar dentro de tmux:
   `echo "$TMUX"` no imprime nada en ellas.
   - En tu equipo: dos pestañas o ventanas de tu terminal.
   - En el laboratorio Docker, desde la raíz del repositorio:
     ```bash
     docker compose up -d lab        # una sola vez
     docker compose exec lab bash    # en la terminal A y otra vez en la B
     ```
     Dentro del contenedor ya estás en la raíz del repositorio (`/bc-tmux`).
     Al terminar la semana: `docker compose down`.
2. **Esta semana la B es tu terminal de verdad.** Colores, subrayado
   ondulado, títulos y teclas los dibuja o los manda **tu** emulador, también
   a través de `docker compose exec`. Cada lab dice qué deberías ver en la B y
   cómo comprobarlo sin fiarte de la vista: `#{client_termfeatures}`,
   `show-messages -T`, `cat -v` o una grabación con `script` de los bytes que
   tmux manda a tu terminal. Si tu terminal no sabe hacer algo, la
   comprobación lo enseña igual.
3. **La carpeta del lab.** En las dos terminales, desde la raíz del
   repositorio, `cd` a la carpeta del lab (el paso 0 de cada lab da la ruta).
   Todos los comandos se escriben desde ahí.
4. **Un servidor aparte y nada del sistema.** Todo va contra `tmux -L lab`:
   tu tmux de siempre no se toca. Lo temporal (grabaciones, terminfo, logs)
   va a `/tmp/lab08`; nunca se escribe en `/usr/share/terminfo` ni en tu
   `~/.terminfo`.
5. **Las features se leen al conectarse.** Tras cambiar
   `terminal-features` o terminfo, sal de la B con `C-b` `d` y vuelve a
   conectarte: un cliente ya conectado no cambia.
6. **Conectarte y salir.** Ningún lab cambia el prefix: es `C-b`. Para salir
   sin cerrar nada, `C-b` `d`; la B imprime `[detached (from session api)]`.
7. **Al terminar cada lab:** `tmux -L lab kill-server` en la terminal A. Si
   la B seguía conectada, imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
