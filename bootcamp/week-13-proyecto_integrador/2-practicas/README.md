# Labs — Semana 13: Proyecto integrador

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-enlaces-y-xdg](lab-01-enlaces-y-xdg/) | Instalar el kit con un enlace en un HOME de pruebas: `ln -s` contra `ln -sfn`, `#{config_files}`, `~/.tmux.conf` y `XDG_CONFIG_HOME` | ~60 min |
| 2 | [lab-02-instalador-idempotente](lab-02-instalador-idempotente/) | Un `install.sh` con ruta física del kit, XDG, backup con fecha, "ya instalado" y `--dry-run` | ~60 min |
| 3 | [lab-03-desinstalar-y-restaurar](lab-03-desinstalar-y-restaurar/) | `--uninstall` que solo borra su propio enlace (exit 1 con uno ajeno) y restaura el backup más reciente | ~60 min |
| 4 | [lab-04-checks-propios](lab-04-checks-propios/) | `tests/run` con servidor aislado, `TMUX_SOCKET` y `trap`, validado con mutaciones | ~60 min |
| 5 | [lab-05-auditoria-del-kit](lab-05-auditoria-del-kit/) | `audit.sh`: shellcheck, TODOs, tiempo de arranque y `#()` con `status-interval`; `tmux -vvv` para ver qué frena | ~60 min |
| 6 | [lab-06-instalador-roto](lab-06-instalador-roto/) | Arreglar cinco fallos de un instalador que "en su máquina funciona" (roto a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **El laboratorio.** Todos los labs corren en una sola terminal dentro
   del laboratorio. Desde la raíz del repositorio, en tu equipo:
   ```bash
   docker compose run --rm lab
   ```
   Cada `run --rm` es un contenedor nuevo que se borra al salir (`exit`):
   lo que crees en su `/tmp` desaparece con él. Lo que edites en el
   repositorio (`/bc-tmux`) se queda.
2. **Fuera de tmux.** La shell empieza fuera de tmux: `echo "$TMUX"` no
   imprime nada. El paso 0 de cada lab da la carpeta (`cd`).
3. **HOME de pruebas.** Instalar es tocar `~/.config/tmux`. Ningún lab
   toca el tuyo: todos crean uno con `H=$(mktemp -d)` y lanzan el
   instalador o tmux con `env -u XDG_CONFIG_HOME HOME="$H" ...`. El
   `-u XDG_CONFIG_HOME` importa: si tienes esa variable definida, tmux y
   el instalador la usarían antes que `HOME`.
4. **Servidores aparte.** Los labs usan `-L lab`, `-L l13-*` o los
   sockets propios de sus scripts (`kit-test`, `kit-audit`), siempre con
   `-L`: tu tmux de siempre no se toca. Si arrancas otro servidor en el
   mismo socket justo después de `kill-server`, deja un `sleep 0.5`
   entre medias.
5. **Lo que se instala es una carpeta del repo.** En los labs, el "kit"
   es la carpeta `starter/` del lab: el enlace apunta allí. Si un paso
   deja un enlace de más dentro de `starter/` (lab 01, paso 5; lab 06,
   fallo 3), el propio lab dice cómo borrarlo.

Completa los labs en orden: el `install.sh` del lab 02 es el starter del
lab 03, y el `tests/run` del lab 04 es el modelo del `audit.sh` del lab 05.
Después, el [Proyecto semanal](../3-proyecto/README.md), donde todo esto
entra en tu `tmux-kit`.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Probar y auditar el kit](../1-teoria/02-probar-y-auditar-el-kit.md) | [Lab 01 — Enlaces y XDG](lab-01-enlaces-y-xdg/README.md) → |

[↑ Semana 13](../README.md)
