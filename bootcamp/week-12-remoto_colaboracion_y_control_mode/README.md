# Semana 12 — Remoto, colaboración y control mode

## Descripción

tmux sobrevive a una conexión caída porque el servidor vive en la máquina remota: el cliente es lo único que pierdes. Esta semana entras por SSH al propio laboratorio, anidas un tmux dentro de otro sin pelearte con el prefix, compartes una sesión con otro usuario sin regalarle tu shell (socket, permisos y `server-access`) y hablas con tmux en control mode, el protocolo que usan iTerm2 y los scripts. Cierras con un toggle `F12`, una barra que sabe si es remota y `bin/kit-pair` en tu `tmux-kit`.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Entrar y volver a la misma sesión por SSH con `ssh -t host tmux new -A -s nombre`, y explicar qué aporta mosh y qué no
- Decidir qué tmux recibe cada tecla en un anidado y mandar el prefix al de dentro con `send-prefix`
- Construir un toggle que apaga el tmux exterior con la tabla `off` y vuelve con `set -u`, sin guardar estado
- Detectar al cargar la config si el servidor arrancó por SSH y distinguir su barra
- Compartir un servidor con `-S`, permisos por grupo y `server-access` en solo lectura, y explicar por qué `attach -r` no protege
- Leer el protocolo de control mode (`%begin`/`%end`, notificaciones) y procesar sus eventos desde bash

## Prerrequisitos

- [Semana 11](../week-11-plugins_y_ecosistema/README.md) completada: `tmux-kit` con plugin propio y `bin/kit-plugins`
- **Imagen ampliada del laboratorio**: esta semana trae `openssh-server`, `mosh` y un segundo usuario, `invitado`, en el grupo `pair`. Reconstrúyela con `docker compose build` antes de empezar y lee [setup § Dos usuarios y SSH](../../docs/setup-entorno.md#dos-usuarios-y-ssh-semana-12) (sección 4)
- **Dos terminales fuera de tmux** (`echo "$TMUX"` vacío) con el contenedor de larga vida: `docker compose up -d lab` y `docker compose exec lab bash` (o `-u invitado`)
- `shellcheck` para el lab 05 y el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-remoto-y-anidado.md](1-teoria/01-remoto-y-anidado.md) · [02-compartir-y-control-mode.md](1-teoria/02-compartir-y-control-mode.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-ssh-y-sesion-persistente](2-practicas/lab-01-ssh-y-sesion-persistente/) | 60 min |
| 2 | Lab | [lab-02-tmux-anidado](2-practicas/lab-02-tmux-anidado/) | 60 min |
| 3 | Lab | [lab-03-toggle-de-anidado](2-practicas/lab-03-toggle-de-anidado/) | 60 min |
| 4 | Lab | [lab-04-socket-compartido](2-practicas/lab-04-socket-compartido/) | 60 min |
| 5 | Lab | [lab-05-control-mode](2-practicas/lab-05-control-mode/) | 60 min |
| 6 | Lab | [lab-06-colaboracion-rota](2-practicas/lab-06-colaboracion-rota/) | 60 min |
| — | Proyecto | [tmux-kit: toggle de anidado, barra remota y sesión compartida](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (remoto y anidado + compartir y control mode)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — SSH al laboratorio, new -A, cortar con ~. y volver; barra que sabe si es SSH
[60 min] lab-02 — Un tmux dentro de otro: prefix doble y prefix distinto
[60 min] lab-03 — F12 con la tabla off, set -u para volver y aviso en la barra
[60 min] lab-04 — Socket compartido con el invitado: -S, grupo pair, server-access R y W
[60 min] lab-05 — tmux -C a mano y un script que traduce eventos
[60 min] lab-06 — Arreglar una sesión compartida y un anidado rotos a propósito
[3 h]    Proyecto: conf.d/70-remote.conf y bin/kit-pair
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 12
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker y en servidores
aislados (`TMUX_SOCKET=bc-check` y un socket `-S` temporal para
`kit-pair`), sin red, sin `sshd` y sin segundo usuario: el `F12` se prueba
con `send-keys -K` y SSH se simula con `SSH_CONNECTION`. Al terminar deben
pasar todos.

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 11 — Plugins y ecosistema](../week-11-plugins_y_ecosistema/README.md) | **Semana 12 — Remoto, colaboración y control mode** | Semana 13 — Proyecto integrador |

[← Volver al índice del bootcamp](../README.md)
