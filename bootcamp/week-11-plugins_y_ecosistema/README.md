# Semana 11 — Plugins y ecosistema

## Descripción

Un plugin de tmux no es magia: es un script `*.tmux` que llama a `tmux set` y `tmux bind`, y TPM solo lo clona y lo ejecuta con `run-shell`. Esta semana instalas TPM, tmux-resurrect y tmux-continuum fijados por versión, escribes tus propios plugins sin TPM, pruebas tmuxp y depuras las trampas silenciosas: plugins que TPM no encuentra, que se duplican al recargar o que solo cargan la segunda vez. Cierras con un plugin propio en tu `tmux-kit` y `bin/kit-plugins` para instalar y auditar los de terceros.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Instalar TPM y plugins fijados por tag sin teclado (`bin/install_plugins`), comprobar qué cambiaron en el servidor y retirarlos con `clean_plugins`
- Explicar cómo encuentra TPM los plugins (`@plugin` en el texto de los archivos frente a `@tpm_plugins` en el servidor) y por qué su `run-shell` va al final
- Guardar y restaurar sesiones con tmux-resurrect y automatizarlo con tmux-continuum, sabiendo qué vuelve y qué no
- Escribir un plugin que respeta las opciones del usuario, interpola marcadores en la status line y es idempotente al recargar
- Declarar una sesión en YAML con tmuxp (`uv tool install`) y decidir cuándo prefieres un script o ningún plugin
- Cargar una config con plugins que funciona igual en una máquina sin TPM

## Prerrequisitos

- [Semana 10](../week-10-hooks_popups_y_menus/README.md) completada: `tmux-kit` con hooks, popup de proyectos y menú
- Laboratorio Docker construido (`docker compose build`), con red: los labs 01, 02 y 06 clonan de GitHub con `git` y el 05 instala tmuxp con `uv`
- **Dos terminales fuera de tmux** (`echo "$TMUX"` vacío): los labs 02 y 04 necesitan un cliente conectado para ver la barra
- `shellcheck` para los labs 03 y 04 y el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-que-es-un-plugin-y-tpm.md](1-teoria/01-que-es-un-plugin-y-tpm.md) · [02-resurrect-continuum-y-gestores.md](1-teoria/02-resurrect-continuum-y-gestores.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-tpm-desde-cero](2-practicas/lab-01-tpm-desde-cero/) | 60 min |
| 2 | Lab | [lab-02-resurrect-y-continuum](2-practicas/lab-02-resurrect-y-continuum/) | 60 min |
| 3 | Lab | [lab-03-anatomia-de-un-plugin](2-practicas/lab-03-anatomia-de-un-plugin/) | 60 min |
| 4 | Lab | [lab-04-interpolacion-en-la-status](2-practicas/lab-04-interpolacion-en-la-status/) | 60 min |
| 5 | Lab | [lab-05-tmuxp](2-practicas/lab-05-tmuxp/) | 60 min |
| 6 | Lab | [lab-06-plugins-rotos](2-practicas/lab-06-plugins-rotos/) | 60 min |
| — | Proyecto | [tmux-kit: plugin propio y plugins de terceros fijados](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (plugins y TPM + resurrect, continuum y gestores)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — TPM fijado por tag, install_plugins, qué cambió, clean_plugins
[60 min] lab-02 — Guardar y restaurar tres ventanas; continuum con y sin cliente
[60 min] lab-03 — Un plugin propio: opciones por defecto, una tecla, sin duplicar
[60 min] lab-04 — Marcadores en status-right cambiados por #(script)
[60 min] lab-05 — Una sesión en YAML con tmuxp: load -d, freeze, frente a dev-up
[60 min] lab-06 — Arreglar los seis fallos de una config con TPM y un plugin
[3 h]    Proyecto: plugin/tmux-kit.tmux, conf.d/60-plugins.conf y bin/kit-plugins
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 11
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker y en un servidor
aislado (`TMUX_SOCKET=bc-check`), sin red y sin TPM instalado. Al terminar
deben pasar todos, y `kit-plugins check` debe aceptar tus plugins (desde la
carpeta de la semana):

```bash
tmux -L kit -f "$PWD/3-proyecto/starter/tmux.conf" new -d
TMUX_SOCKET=kit 3-proyecto/starter/bin/kit-plugins check; echo $?; tmux -L kit kill-server
```

```
kit-plugins: 3 plugins fijados
0
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 10 — Hooks, popups y menús](../week-10-hooks_popups_y_menus/README.md) | **Semana 11 — Plugins y ecosistema** | Semana 12 — Remoto, colaboración y control mode |

[← Volver al índice del bootcamp](../README.md)
