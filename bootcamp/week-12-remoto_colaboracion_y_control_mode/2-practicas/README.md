# Labs — Semana 12: Remoto, colaboración y control mode

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-ssh-y-sesion-persistente](lab-01-ssh-y-sesion-persistente/) | Entrar por SSH con `new -A`, cortar la conexión con `~.` y volver a la misma sesión; una barra que sabe si el servidor arrancó por SSH | ~60 min |
| 2 | [lab-02-tmux-anidado](lab-02-tmux-anidado/) | Un tmux dentro de otro por SSH: prefix doble con `send-prefix` y un prefix distinto para el de dentro | ~60 min |
| 3 | [lab-03-toggle-de-anidado](lab-03-toggle-de-anidado/) | `F12` apaga el tmux de fuera con la tabla `off` y `set -u` lo enciende, con aviso en la barra y probado con `send-keys -K` | ~60 min |
| 4 | [lab-04-socket-compartido](lab-04-socket-compartido/) | Compartir una sesión con otro usuario: `-S`, grupo `pair`, permisos y `server-access` en solo lectura y en escritura | ~60 min |
| 5 | [lab-05-control-mode](lab-05-control-mode/) | `tmux -C` a mano (`%begin`/`%end`, `%window-add`, `%output`) y un script que traduce eventos con `timeout` | ~60 min |
| 6 | [lab-06-colaboracion-rota](lab-06-colaboracion-rota/) | Arreglar cinco fallos de una sesión compartida y un anidado (rota a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **El laboratorio corriendo, con varias terminales.** Esta semana casi
   todos los labs usan dos terminales a la vez, a veces con usuarios
   distintos ([setup § Dos usuarios y SSH](../../../docs/setup-entorno.md#dos-usuarios-y-ssh-semana-12)).
   Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose up -d lab                   # una sola vez
   docker compose exec lab bash               # terminal A (alumno)
   docker compose exec lab bash               # terminal B (alumno), labs 01-03
   docker compose exec -u invitado lab bash   # terminal B (invitado), labs 04 y 06
   ```
   Al terminar la semana: `docker compose down` (borra también la clave SSH
   y el `sshd` del lab 01).
2. **SSH al propio contenedor.** Los labs 01, 02, 03 y 06 entran por SSH
   en `localhost` para simular un servidor remoto. El paso 0 del lab 01
   arranca `sshd` y crea la clave; tras un `docker compose down` hay que
   repetirlo.
3. **Fuera de tmux.** Cada terminal empieza fuera de tmux: `echo "$TMUX"`
   no imprime nada. Los comandos se escriben desde la carpeta del lab (el
   paso 0 de cada uno da la ruta).
4. **Servidores aparte.** Cada lab usa sus propios sockets (`-L lab`,
   `-L fuera`, `-L dentro`, `-L cm`, o `-S /tmp/lab-...` para compartir) y
   carga la config con `-f`: tu tmux de siempre y tu `~/.config/tmux` no
   se tocan. Cada lab dice qué prefix tiene cada servidor.
5. **Al terminar cada lab**, su último paso mata sus servidores, siempre
   con `-L` o `-S`. Un cliente conectado a un servidor que muere imprime
   `[server exited]`. Si arrancas otro servidor en el mismo socket justo
   después de `kill-server`, deja un `sleep 0.5` entre medias: el anterior
   puede no haber terminado y dar `server exited unexpectedly`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Compartir una sesión y control mode](../1-teoria/02-compartir-y-control-mode.md) | [Lab 01 — SSH y sesión persistente](lab-01-ssh-y-sesion-persistente/README.md) → |

[↑ Semana 12](../README.md)
