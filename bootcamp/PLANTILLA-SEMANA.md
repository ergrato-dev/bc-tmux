# PLANTILLA DE SEMANA — bc-tmux

> Archivo de referencia. Copia esta estructura al crear contenido nuevo.
> Reglas completas en `CLAUDE.md`; generación automática con `.claude/commands/gen-semana.md`.

---

## README.md de semana (plantilla)

~~~markdown
# Semana NN — Título del Tema

## Descripción

<2-3 oraciones. Qué aprenderá el estudiante. Por qué importa en la práctica real.>

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Escribir <concepto> usando <técnica>
- Depurar <problema común> con <herramienta>
- Construir <artefacto concreto> desde cero

## Prerrequisitos

- Semanas 01–NN-1 completadas
- tmux ≥ 3.4 (`tmux -V`) y el laboratorio Docker (`docker compose build`)
- <herramienta específica si aplica>

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-contexto.md](1-teoria/01-contexto.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-nombre](2-practicas/lab-01-nombre/) | 60 min |
| 2 | Lab | [lab-02-nombre](2-practicas/lab-02-nombre/) | 60 min |
| 3 | Lab | [lab-03-nombre](2-practicas/lab-03-nombre/) | 60 min |
| 4 | Lab | [lab-04-nombre](2-practicas/lab-04-nombre/) | 60 min |
| 5 | Lab | [lab-05-nombre](2-practicas/lab-05-nombre/) | 60 min |
| 6 | Lab | [lab-06-nombre](2-practicas/lab-06-nombre/) | 60 min |
| — | Proyecto | [Proyecto semanal](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — <tema>
...
[60 min] lab-06 — <tema>
[3 h]    Proyecto: <nombre>
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh NN
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [Semana NN-1 — Tema](../week-NN-1-slug/README.md) | **Semana NN — Tema** | [Semana NN+1 — Tema](../week-NN+1-slug/README.md) |

[← Volver al índice del bootcamp](../README.md)
~~~

---

## README.md de lab (plantilla)

~~~markdown
# Lab NN — Título del Lab

⏱ Duración estimada: ~60 min

## Objetivo

<Verbo en infinitivo> <qué> usando <qué técnica de tmux>.

## Contexto

<Máx. 3 párrafos o 5 bullets. Referencia al tema de la semana sin repetir la teoría.>

## Instrucciones

1. Arranca un servidor aislado con la config del starter:
   ```bash
   tmux -L lab -f starter/tmux.conf
   ```
2. Abre `starter/tmux.conf` y resuelve los comentarios `# TODO`
3. Recarga y verifica desde otra terminal:
   ```bash
   tmux -L lab source-file starter/tmux.conf
   tmux -L lab show -gv <opcion>
   ```
   Debes ver:
   ```
   <output esperado exacto>
   ```
4. Cierra el servidor del lab: `tmux -L lab kill-server`

## Criterios de éxito

- [ ] `tmux -L lab show -gv <opcion>` imprime `<valor>`
- [ ] `tmux -L lab list-keys -T prefix <tecla>` muestra `<comando>`
- [ ] La config carga sin errores: `tmux -L lab source-file starter/tmux.conf` sale con 0

## Reto extra

<Extensión opcional para ir más lejos.>
~~~

---

## tmux.conf starter (plantilla)

```tmux
# ============================================================
# Lab NN — Título
# Semana NN: Tema
# Pruébalo sin tocar tu sesión: tmux -L lab -f starter/tmux.conf
# ============================================================

# TODO: cambia el prefix a C-a y libera C-b

# TODO: activa los atajos de vi en copy-mode
```

---

## tmux.conf solución (plantilla)

```tmux
# ============================================================
# Lab NN — Título (SOLUCIÓN)
# ============================================================

set -g  prefix C-a
unbind  C-b
bind    C-a send-prefix

setw -g mode-keys vi
```

---

## Script bash (plantilla, `bin/` de tmux-kit)

```bash
#!/usr/bin/env bash
# dev-up — levanta (o reutiliza) la sesión de un proyecto.
set -euo pipefail

# El autograding exporta TMUX_SOCKET=bc-check; sin ella, tmux usa el servidor de siempre.
tmx() { tmux ${TMUX_SOCKET:+-L "$TMUX_SOCKET"} "$@"; }

name="${1:?uso: dev-up <sesion>}"

if ! tmx has-session -t "=$name" 2>/dev/null; then
  tmx new-session -d -s "$name" -n editor
fi
```
