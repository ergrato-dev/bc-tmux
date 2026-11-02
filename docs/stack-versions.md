# Versiones del stack

Revisado: 2026-11-01. Se actualiza al inicio de cada cohorte.

## tmux

| Versión | Fecha | Dónde la encuentras | Uso en el bootcamp |
|---|---|---|---|
| 3.2a | 2021 | Ubuntu 22.04 | **No soportada.** Actualiza a Ubuntu 24.04 |
| 3.4 | 2024-02 | Ubuntu 24.04 LTS, laboratorio Docker | **Mínimo.** Todo el contenido funciona aquí |
| 3.8 | 2026-09 | Homebrew, Arch, compilada desde el código fuente | Última versión. Las features posteriores a 3.4 van marcadas "tmux 3.5+" |

El laboratorio (`lab/Dockerfile`) fija tmux 3.4 a propósito: es lo que tiene
un estudiante con Ubuntu 24.04 y, por tanto, lo que se prueba.

Comprueba la tuya:

```bash
tmux -V
```

## Laboratorio Docker

| Pieza | Versión |
|---|---|
| Imagen base | `ubuntu:24.04` |
| tmux | 3.4 (apt de Ubuntu 24.04) |
| bash | 5.2 |
| jq | 1.7 |
| shellcheck | 0.9 |
| fzf | 0.44 |
| Neovim | 0.9.5 |
| uv | 0.12.2 (`COPY --from=ghcr.io/astral-sh/uv:0.12.2`) |
| Docker Engine | 27+ |
| Docker Compose | v2 (`docker compose`) |

## Ecosistema (semanas 10–12)

| Herramienta | Versión fijada | Notas |
|---|---|---|
| TPM | v3.1.0 | Se clona por tag, nunca `master` |
| tmux-resurrect / tmux-continuum | por commit | Fijados en `@plugin` con tag o commit |
| tmuxp | 1.76.x | `uv tool install tmuxp==1.76.*`. **Nunca pip** |
| sesh | 2.34.x | Binario de la release oficial |
| fzf | ≥ 0.44 | El popup de la semana 10 usa solo flags presentes en 0.44 |

Node.js no se usa en este bootcamp; si alguna vez hiciera falta, siempre con **pnpm**, nunca npm.
