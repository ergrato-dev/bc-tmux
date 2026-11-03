# Lab 02 — tmux anidado

⏱ Duración estimada: ~60 min

## Objetivo

Manejar un tmux dentro de otro (fuera, tu portátil; dentro, el servidor al que entras por SSH) con el prefix doble y con un prefix distinto para el de dentro.

## Contexto

- Cada tecla que pulsas la lee primero el tmux de fuera. Si es su prefix, se la queda; el de dentro solo recibe lo que el de fuera deja pasar.
- `send-prefix` manda el prefix al programa del panel como una tecla normal. Por defecto `C-b` `C-b` hace eso: el segundo `C-b` llega al tmux de dentro.
- Por SSH no viaja la variable `TMUX`: el tmux remoto no sabe que está dentro de otro. Aquí simulas el remoto con `ssh localhost` y otro socket, `-L dentro`.

## Instrucciones

0. **Dónde.** Necesitas `sshd` y la clave del [lab 01](../lab-01-ssh-y-sesion-persistente/README.md),
   paso 0 (si hiciste `docker compose down`, repítelo). Terminal A dentro
   del laboratorio (`docker compose exec lab bash`) y fuera de tmux
   (`echo "$TMUX"` vacío):
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-02-tmux-anidado
   n() { echo "fuera=$(tmux -L fuera list-windows | wc -l) dentro=$(tmux -L dentro list-windows | wc -l)"; }
   ```
   ```
   (sin salida)
   ```
   `n` cuenta las ventanas de cada servidor: así ves a cuál le llegó cada
   tecla. Ninguno de los dos starters cambia el prefix: los dos usan `C-b`.

1. **TODO 1 y TODO 2 — dos barras distintas.** En `starter/fuera.conf`
   quita el `#   ` de las tres líneas del TODO 1. En `starter/dentro.conf`
   escribe el TODO 2 con `set -g status-style` y `set -g status-left`.
   Arranca el de fuera con un solo panel que entra por SSH y abre el de
   dentro:
   ```bash
   tmux -L fuera -f "$PWD/starter/fuera.conf" new -d -s fuera "ssh -t localhost tmux -L dentro -f '$PWD/starter/dentro.conf' new -A -s dentro"; echo $?
   sleep 2
   tmux -L dentro ls
   tmux -L dentro list-clients -F '#{client_termname} #{client_tty}'
   ```
   Algo como (cambian la fecha y el `pts`):
   ```
   0
   dentro: 1 windows (created Tue Nov  3 21:47:18 2026) (attached)
   tmux-256color /dev/pts/3
   ```
   El cliente del de dentro corre en un panel del de fuera: su terminal es
   `tmux-256color`, la que el de fuera da a sus paneles.

2. **Conéctate (terminal B).** Abre otra terminal en tu equipo, desde la
   raíz del repositorio: `docker compose exec lab bash`. Es la
   **terminal B**:
   ```bash
   tmux -L fuera attach -t fuera
   ```
   Ves dos barras: arriba la verde `[fuera]`, abajo la azul `[dentro]`.
   Pulsa `C-b` `c`. En la terminal A:
   ```bash
   n
   ```
   ```
   fuera=2 dentro=1
   ```
   La ventana nueva es del de fuera: estás en ella, con una shell normal.
   Vuelve a la ventana 0 (la del SSH) con `C-b` `0`.

3. **Prefix doble.** En B pulsa `C-b` `C-b` `c`. En A:
   ```bash
   n
   tmux -L fuera list-keys -T prefix C-b
   ```
   ```
   fuera=2 dentro=2
   bind-key -T prefix C-b send-prefix
   ```
   El primer `C-b` lo consume el de fuera; el segundo dispara su
   `send-prefix`, que escribe un `C-b` en el panel; la `c` ya no es del de
   fuera (no está en espera de prefix) y pasa tal cual. El de dentro recibe
   `C-b` `c`.

4. **TODO 3 — un prefix para cada uno.** En `starter/dentro.conf` escribe
   las tres líneas del TODO 3 (`set -g prefix C-a`, `unbind C-b`,
   `bind C-a send-prefix`). Recarga solo el de dentro:
   ```bash
   tmux -L dentro source-file "$PWD/starter/dentro.conf"
   tmux -L dentro show -gv prefix
   tmux -L dentro list-keys -T prefix C-b; echo $?
   tmux -L dentro list-keys -T prefix C-a
   ```
   ```
   C-a
   unknown key: C-b
   1
   bind-key -T prefix C-a send-prefix
   ```
   En B pulsa `C-a` `c` y luego `C-b` `c`. En A:
   ```bash
   n
   ```
   ```
   fuera=3 dentro=3
   ```
   `C-a` no es nada para el de fuera y llega tal cual; `C-b` sigue siendo
   del de fuera. Una tecla para cada uno, sin dobles.

5. **Por qué no avisa.** En B, ve a la ventana 0 (`C-b` `0`), donde está
   el de dentro, y en su shell intenta anidar el **mismo** servidor:
   ```bash
   tmux -L dentro new -s otra
   echo "$TMUX"
   ```
   Algo como (cambia el pid del servidor, `994`):
   ```
   sessions should be nested with care, unset $TMUX to force
   /tmp/tmux-1000/dentro,994,0
   ```
   tmux solo se niega cuando `TMUX` apunta al mismo socket. El de dentro
   no sabe nada del de fuera: `TMUX` no viaja por SSH, y con otro socket
   tampoco se queja. Ese aviso no te protege del anidado de este lab.

6. **Sal y limpia.** En B, `C-b` `d` (el prefix del de fuera):
   ```
   [detached (from session fuera)]
   ```
   El cliente del de dentro sigue vivo en el panel del de fuera. En A:
   ```bash
   tmux -L fuera kill-server; sleep 0.5
   tmux -L dentro ls
   tmux -L dentro kill-server
   ```
   Algo como (cambia la fecha):
   ```
   dentro: 3 windows (created Tue Nov  3 21:49:46 2026)
   ```
   Matar el de fuera cortó el SSH y con él el cliente del de dentro, pero
   su servidor siguió: ya no sale `(attached)`. Es el lab 01 visto desde
   el otro lado.

## Criterios de éxito

- [ ] `tmux -L dentro list-clients -F '#{client_termname}'` imprime `tmux-256color` (paso 1)
- [ ] Tras `C-b` `c`, `n` imprime `fuera=2 dentro=1` (paso 2)
- [ ] Tras `C-b` `C-b` `c`, `n` imprime `fuera=2 dentro=2` (paso 3)
- [ ] `tmux -L dentro show -gv prefix` imprime `C-a` y `C-a` `c` crea la ventana en el de dentro (paso 4)
- [ ] Explicas por qué `sessions should be nested with care` sale con `-L dentro` dentro de `-L dentro` y no en el anidado del paso 1 (paso 5)

## Reto extra

Anida un tercer nivel: en el de dentro abre `ssh -t localhost tmux -L tercero -f /dev/null new -A -s tercero`.
Con fuera en `C-b`, dentro en `C-a` y el tercero en `C-b`, ¿qué secuencia
crea una ventana en el tercero? Compruébalo con
`tmux -L tercero list-windows | wc -l`. Después piensa por qué el toggle
del lab 03 escala mejor que un prefix distinto por nivel.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 01 — SSH y sesión persistente](../lab-01-ssh-y-sesion-persistente/README.md) | [Lab 03 — Toggle de anidado](../lab-03-toggle-de-anidado/README.md) → |

[↑ Semana 12](../../README.md)
