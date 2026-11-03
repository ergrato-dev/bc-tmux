# Semana 06 — Key bindings, tablas y navegación

## Descripción

Dejas de vivir con las teclas de serie y decides tú cuáles existen. Aprenderás en qué tabla busca tmux cada tecla, a crear, pisar, quitar y documentar bindings, a construir un modo propio con su tabla y a moverte entre paneles con `C-h/j/k/l` sin quitarle esas teclas a los programas que las usan. Cierras con tu `tmux-kit` documentado tecla a tecla, con un modo resize y un script que lista tus teclas.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Explicar por qué tabla pasa cada tecla (`root`, `prefix`, `copy-mode-vi`, una propia) y comprobarlo con `#{client_key_table}`
- Crear, pisar, quitar y documentar bindings con `bind`, `unbind`, `-N` y `list-keys`
- Decidir cuándo una tecla merece `-r` o `-n`, y deshacer una que roba teclas a la shell
- Construir un modo propio con `switch-client -T` que se repite hasta que sales
- Escribir bindings de copy mode con `send -X`, bloques `{ }` e `if -F`
- Moverte entre paneles con `C-h/j/k/l` decidiendo con `#{alternate_on}`, y recuperar lo que eso cuesta
- Depurar una config de teclas rota con `list-keys`, `source-file` y `show-messages`

## Prerrequisitos

- [Semana 05](../week-05-configuracion_y_alcance_de_opciones/README.md) completada: `tmux-kit` modular con `conf.d/`, prefix propio y `kit-option`
- Laboratorio Docker construido (`docker compose build`) y dos terminales para los labs 03 y 05
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-tablas-y-bindings.md](1-teoria/01-tablas-y-bindings.md) · [02-teclas-que-deciden.md](1-teoria/02-teclas-que-deciden.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-bind-unbind-y-list-keys](2-practicas/lab-01-bind-unbind-y-list-keys/) | 60 min |
| 2 | Lab | [lab-02-repeticion-y-tabla-root](2-practicas/lab-02-repeticion-y-tabla-root/) | 60 min |
| 3 | Lab | [lab-03-tablas-propias](2-practicas/lab-03-tablas-propias/) | 60 min |
| 4 | Lab | [lab-04-copy-mode-a-medida](2-practicas/lab-04-copy-mode-a-medida/) | 60 min |
| 5 | Lab | [lab-05-navegacion-consciente](2-practicas/lab-05-navegacion-consciente/) | 60 min |
| 6 | Lab | [lab-06-teclas-rotas](2-practicas/lab-06-teclas-rotas/) | 60 min |
| — | Proyecto | [tmux-kit: modo resize, navegación y kit-keys](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (tablas y bindings + teclas que deciden)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — bind, unbind, -N, list-keys y el bind que pisa sin avisar
[60 min] lab-02 — -r y repeat-time; -n en root y la tecla robada a la shell
[60 min] lab-03 — Modo resize con switch-client -T y client_key_table
[60 min] lab-04 — copy-mode-vi con send -X, bloques { } e if -F
[60 min] lab-05 — C-h/j/k/l con alternate_on y prefix C-l para limpiar
[60 min] lab-06 — Depurar una config de teclas con cinco errores
[3 h]    Proyecto: notas kit:, splits con directorio, modo resize, navegación y kit-keys
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 06
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y tus teclas deben estar documentadas:

```bash
tmux -L kit -f "$PWD/3-proyecto/starter/tmux.conf" new -d
tmux -L kit list-keys -N | grep 'kit:'; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 05 — Configuración y alcance de opciones](../week-05-configuracion_y_alcance_de_opciones/README.md) | **Semana 06 — Key bindings, tablas y navegación** | Semana 07 — Formats y status line |

[← Volver al índice del bootcamp](../README.md)
