# Lab 01 — SSH y sesión persistente

⏱ Duración estimada: ~60 min

## Objetivo

Entrar por SSH en un servidor tmux, cortar la conexión a lo bruto y volver a la misma sesión, con una barra que avisa cuando el servidor arrancó por SSH.

## Contexto

- El servidor tmux vive en la máquina remota. SSH solo transporta un cliente: si la conexión se corta, el cliente muere y la sesión sigue con todo lo que corría dentro.
- `new -A -s nombre` crea la sesión si no existe y se conecta si existe: una sola orden para "entrar" siempre. Necesita una terminal, por eso va con `ssh -t`.
- `SSH_CONNECTION` (IP y puerto de origen y de destino) solo existe en una shell abierta por SSH. Un format no lee variables de entorno; `if-shell` sí, al cargar la config.

## Instrucciones

0. **Dónde.** Este lab usa dos terminales dentro del laboratorio y el
   servidor SSH del contenedor ([Antes de cada lab](../README.md#antes-de-cada-lab)).
   Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose up -d lab
   docker compose exec -u root lab /usr/sbin/sshd
   docker compose exec lab bash
   ```
   `up -d` imprime el estado del contenedor (`Started`) y `sshd` no imprime
   nada.
   Esa última shell es la **terminal A**, fuera de tmux (`echo "$TMUX"`
   vacío). Crea una clave para entrar en `localhost` (solo se acepta clave)
   y comprueba que entras:
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-01-ssh-y-sesion-persistente
   ssh-keygen -q -t ed25519 -N "" -f ~/.ssh/id_ed25519
   cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
   ssh -o StrictHostKeyChecking=accept-new localhost 'echo "$SSH_CONNECTION"'
   ```
   Algo como (cambia el puerto de origen, `36218`):
   ```
   Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
   ::1 36218 ::1 22
   ```
   `~/.ssh` es el del contenedor, no el de tu equipo: desaparece con
   `docker compose down`. Si `ssh-keygen` pregunta si sobrescribe, ya la
   creaste antes: responde `n`.

1. **TODO 1 — el host en la barra.** En `starter/tmux.conf` escribe
   `set -g status-left "[#{host_short}] "`. `#{T:opción}` expande el format
   de una opción como lo vería la barra. Arranca un servidor local para
   comparar después:
   ```bash
   tmux -L local -f "$PWD/starter/tmux.conf" new -d -s trabajo; echo $?
   tmux -L local display -p '#{T:status-left}'
   ```
   ```
   0
   [bc-tmux-lab] 
   ```
   `bc-tmux-lab` es el hostname del contenedor. Aquí local y "remoto" son
   la misma máquina; en un servidor de verdad verías su nombre.

2. **TODO 2 — ¿arrancó por SSH?** Añade el `if-shell` del TODO 2 con sus
   dos bloques `{ }` y arranca otro servidor, `-L lab`, **a través de
   SSH**. Las comillas dobles hacen que `$PWD` se expanda aquí, antes de
   viajar:
   ```bash
   tmux -L local source-file "$PWD/starter/tmux.conf"
   tmux -L local show -gv @lab-remote
   ssh localhost "tmux -L lab -f '$PWD/starter/tmux.conf' new -d -s trabajo"; echo $?
   tmux -L lab show -gv @lab-remote
   tmux -L lab show -gv status-style
   tmux -L lab show-environment -g SSH_CONNECTION
   ```
   Algo como (cambia el puerto):
   ```
   off
   0
   on
   bg=#58a6ff,fg=#0d1117
   SSH_CONNECTION=::1 48804 ::1 22
   ```
   El servidor `-L lab` nació dentro de una sesión SSH y guardó su entorno.
   Desde la terminal A le hablas sin SSH: es el mismo usuario en la misma
   máquina, y `-L lab` es el mismo socket (`/tmp/tmux-1000/lab`) se llegue
   como se llegue.

3. **Conéctate por SSH (terminal B).** Abre otra terminal en tu equipo,
   desde la raíz del repositorio: `docker compose exec lab bash`. Esa es la
   **terminal B**. Conéctate:
   ```bash
   ssh -t localhost tmux -L lab new -A -s trabajo
   ```
   La barra sale azul con `[bc-tmux-lab]` a la izquierda. El prefix es
   `C-b`: el starter no lo cambia. Dentro, lanza algo que tarde:
   ```bash
   top
   ```
   En la terminal A:
   ```bash
   tmux -L lab list-clients -F '#{client_tty} #{session_name}'
   tmux -L lab ls
   ```
   Algo como (cambia el número de `pts`):
   ```
   /dev/pts/4 trabajo
   trabajo: 1 windows (created Tue Nov  3 21:45:14 2026) (attached)
   ```
   El cliente es la pseudo-terminal que abrió `sshd`.

4. **Corta la conexión.** En la terminal B pulsa `Enter`, después `~` y
   después `.`: es la secuencia de escape de `ssh` y cierra la conexión sin
   avisar a nadie, como un wifi que se cae. B imprime:
   ```
   Connection to localhost closed.
   ```
   En la terminal A:
   ```bash
   tmux -L lab list-clients
   tmux -L lab ls
   ```
   Algo como (cambia la fecha):
   ```
   trabajo: 1 windows (created Tue Nov  3 21:45:14 2026)
   ```
   Ningún cliente y la sesión sigue, sin `(attached)`.

5. **Vuelve.** En la terminal B, la misma orden del paso 3:
   ```bash
   ssh -t localhost tmux -L lab new -A -s trabajo
   ```
   `top` sigue corriendo donde lo dejaste. Ciérralo con `q` y sal bien,
   con `C-b` `d`. B imprime:
   ```
   [detached (from session trabajo)]
   Connection to localhost closed.
   ```
   Cada conexión SSH trae un `SSH_CONNECTION` nuevo. En la terminal A:
   ```bash
   tmux -L lab show-environment -g SSH_CONNECTION
   tmux -L lab show-environment -t trabajo SSH_CONNECTION
   ```
   Algo como:
   ```
   SSH_CONNECTION=::1 42354 ::1 22
   SSH_CONNECTION=::1 42358 ::1 22
   ```
   El global es el del arranque; el de la sesión lo actualiza cada
   `attach`, porque `SSH_CONNECTION` está en `update-environment`. Los
   paneles nuevos lo heredan de la sesión. `@lab-remote` no cambia: se
   decidió al cargar la config.

6. **Por qué `-t`.** Sin `-t`, `ssh` no reserva una terminal remota y el
   cliente no tiene dónde dibujar:
   ```bash
   ssh localhost tmux -L lab new -A -s trabajo; echo $?
   ssh localhost tmux -L lab new -s trabajo; echo $?
   ```
   ```
   open terminal failed: not a terminal
   1
   duplicate session: trabajo
   1
   ```
   Sin `-A`, una segunda entrada falla porque la sesión ya existe: `new -A`
   es lo que hace la orden repetible.

7. **Limpia** (terminal A):
   ```bash
   tmux -L lab kill-server
   tmux -L local kill-server
   ```
   ```
   (sin salida)
   ```
   Deja el laboratorio corriendo si sigues con el lab 02; la clave y `sshd`
   duran hasta `docker compose down`.

## Criterios de éxito

- [ ] `tmux -L local display -p '#{T:status-left}'` imprime `[bc-tmux-lab] ` (paso 1)
- [ ] `tmux -L local show -gv @lab-remote` imprime `off` y `tmux -L lab show -gv @lab-remote` imprime `on` (paso 2)
- [ ] Tras `Enter` `~` `.`, `tmux -L lab ls` muestra `trabajo` sin `(attached)` (paso 4)
- [ ] Al volver con `ssh -t localhost tmux -L lab new -A -s trabajo`, `top` sigue en marcha (paso 5)
- [ ] `show-environment -t trabajo SSH_CONNECTION` muestra un puerto distinto del global (paso 5)
- [ ] Explicas por qué `ssh localhost tmux ... new -A` sin `-t` falla con `not a terminal` (paso 6)

## Reto extra

Repite los pasos 3 a 5 con `mosh localhost -- tmux -L lab new -A -s trabajo`
en la terminal B (sales de mosh con `C-^` `.`). mosh mantiene la sesión
cuando cambias de red o el portátil se duerme, cosa que aquí no puedes
simular. Cierra la terminal B sin salir y abre otra: ¿qué recuperas con mosh
y qué te sigue dando solo tmux?

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Índice de labs](../README.md) | [Lab 02 — tmux anidado](../lab-02-tmux-anidado/README.md) → |

[↑ Semana 12](../../README.md)
