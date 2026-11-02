# Semana 01 — Primeros pasos y modelo cliente-servidor

## Descripción

Abrirás tmux por primera vez y entenderás qué pasa por debajo: un servidor que guarda tus sesiones y clientes que se conectan y desconectan sin matar nada. Es la base de todo el bootcamp: sin este modelo, los atajos son magia; con él, son comandos que puedes automatizar.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Comprobar que usas tmux ≥ 3.4 y trabajar en un servidor aislado con `-L`
- Explicar qué hacen el servidor, el cliente y el socket, y por qué un trabajo sobrevive al cierre de la terminal
- Crear, desconectar (`detach`), reconectar (`attach`) y cerrar sesiones
- Distinguir sesión, ventana y panel, e identificar cada uno por su id (`$`, `@`, `%`)
- Ejecutar el mismo comando con un atajo, desde el prompt de tmux y desde una shell
- Diferenciar los comandos que arrancan un servidor de los que solo preguntan
- Empezar tu `tmux-kit` con dos scripts: `check-version` y `kit-tree`

## Prerrequisitos

- Soltura con la terminal: navegar, pipes, procesos y bash básico
- Ubuntu 24.04 (nativo o WSL2) o macOS, con tmux ≥ 3.4 (`tmux -V`)
- Laboratorio Docker construido (`docker compose build`): ver [docs/setup-entorno.md](../../docs/setup-entorno.md)
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-multiplexor-y-modelo-cliente-servidor.md](1-teoria/01-multiplexor-y-modelo-cliente-servidor.md) · [02-prefix-y-comandos.md](1-teoria/02-prefix-y-comandos.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-primera-sesion](2-practicas/lab-01-primera-sesion/) | 60 min |
| 2 | Lab | [lab-02-detach-y-attach](2-practicas/lab-02-detach-y-attach/) | 60 min |
| 3 | Lab | [lab-03-prefix-y-linea-de-comandos](2-practicas/lab-03-prefix-y-linea-de-comandos/) | 60 min |
| 4 | Lab | [lab-04-sesion-ventana-panel](2-practicas/lab-04-sesion-ventana-panel/) | 60 min |
| 5 | Lab | [lab-05-servidores-y-sockets](2-practicas/lab-05-servidores-y-sockets/) | 60 min |
| 6 | Lab | [lab-06-sobrevivir-a-una-desconexion](2-practicas/lab-06-sobrevivir-a-una-desconexion/) | 60 min |
| — | Proyecto | [tmux-kit: check-version y kit-tree](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (modelo cliente-servidor + prefix y comandos)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Versión, primera sesión y sesión en segundo plano
[60 min] lab-02 — Detach, attach y dos clientes en la misma sesión
[60 min] lab-03 — Cada atajo es un comando: prompt y línea de comandos
[60 min] lab-04 — Sesión, ventana y panel, a mano y con un script
[60 min] lab-05 — Varios servidores, sockets y el error de anidado
[60 min] lab-06 — Un trabajo largo que sobrevive al cierre de la terminal
[3 h]    Proyecto: tmux-kit con check-version y kit-tree
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 01
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los 16 requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y estos comandos deben funcionar en tu equipo:

```bash
3-proyecto/starter/bin/check-version
tmux -L kit new -d -s prueba && TMUX_SOCKET=kit 3-proyecto/starter/bin/kit-tree
tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| — | **Semana 01 — Primeros pasos y modelo cliente-servidor** | Semana 02 — Ventanas y paneles |

[← Volver al índice del bootcamp](../README.md)
