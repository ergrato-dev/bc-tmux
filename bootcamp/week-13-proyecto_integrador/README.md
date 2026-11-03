# Semana 13 — Proyecto integrador

## Descripción

Tu `tmux-kit` ya hace todo lo que necesitas; esta semana lo conviertes en algo que se instala, se desinstala y se comprueba solo. Escribes un `install.sh` idempotente que enlaza el kit en `${XDG_CONFIG_HOME:-$HOME/.config}/tmux` sin perder la config que había, que se puede ensayar con `--dry-run` y deshacer con `--uninstall`, y una batería de checks propios (`tests/run`) que demuestra su valor fallando cuando rompes el kit a propósito. Cierras con el README final y una auditoría: shellcheck, tiempo de arranque y cero TODOs.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Instalar un directorio de config con `ln -sfn` y explicar por qué `ln -s` sin `-n` crea un enlace dentro del destino
- Escribir un instalador idempotente que hace backup con fecha, respeta `XDG_CONFIG_HOME` y avisa de un `~/.tmux.conf` heredado
- Deshacer una instalación solo cuando el enlace apunta a tu kit, y restaurar el backup más reciente
- Construir checks propios sobre un servidor y un HOME aislados, con `trap` que limpia y códigos de salida útiles
- Comprobar con mutaciones que tus checks fallan cuando el kit se rompe
- Auditar el kit: shellcheck, coste de arranque, `#()` caros, `show-messages` y documentación como contrato

## Prerrequisitos

- [Semana 12](../week-12-remoto_colaboracion_y_control_mode/README.md) completada: `tmux-kit` con toggle de anidado y `bin/kit-pair`
- El laboratorio Docker de siempre (`docker compose run --rm lab`); esta semana no necesita SSH ni segundo usuario
- `shellcheck` para el lab 05 y el proyecto (`sudo apt install shellcheck` / `brew install shellcheck`)
- Ningún paso toca tu `$HOME` real: todo se ensaya con `H=$(mktemp -d)` y `env -u XDG_CONFIG_HOME HOME="$H" ...`

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-instalar-el-kit.md](1-teoria/01-instalar-el-kit.md) · [02-probar-y-auditar-el-kit.md](1-teoria/02-probar-y-auditar-el-kit.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-enlaces-y-xdg](2-practicas/lab-01-enlaces-y-xdg/) | 60 min |
| 2 | Lab | [lab-02-instalador-idempotente](2-practicas/lab-02-instalador-idempotente/) | 60 min |
| 3 | Lab | [lab-03-desinstalar-y-restaurar](2-practicas/lab-03-desinstalar-y-restaurar/) | 60 min |
| 4 | Lab | [lab-04-checks-propios](2-practicas/lab-04-checks-propios/) | 60 min |
| 5 | Lab | [lab-05-auditoria-del-kit](2-practicas/lab-05-auditoria-del-kit/) | 60 min |
| 6 | Lab | [lab-06-instalador-roto](2-practicas/lab-06-instalador-roto/) | 60 min |
| — | Proyecto | [tmux-kit final: install.sh, tests/run y README](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (instalar el kit + probar y auditar el kit)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — ln -s frente a ln -sfn, readlink, config_files y el ~/.tmux.conf heredado
[60 min] lab-02 — install.sh pequeño: backup con fecha, enlace, segunda ejecución y --dry-run
[60 min] lab-03 — --uninstall que solo borra su enlace y restaura el último backup
[60 min] lab-04 — tests/run con ok/fail, servidor aislado, trap y una mutación
[60 min] lab-05 — shellcheck, TODOs, tiempo de arranque, #() lento y show-messages
[60 min] lab-06 — Arreglar un instalador con cinco fallos a propósito
[3 h]    Proyecto: install.sh, tests/run y README final del kit
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 13
```

Comprueba tu proyecto (`3-proyecto/starter/`) dentro del laboratorio Docker,
en un servidor aislado (`TMUX_SOCKET=bc-check`) y con HOME temporales, sin red
ni git: instala, reinstala, desinstala y ensaya con `--dry-run`, arranca tmux
con la config instalada y lanza tus `tests/run` sobre el kit intacto y sobre
copias rotas a propósito. Al terminar deben pasar todos.

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 12 — Remoto, colaboración y control mode](../week-12-remoto_colaboracion_y_control_mode/README.md) | **Semana 13 — Proyecto integrador** | — |

[← Volver al índice del bootcamp](../README.md)
