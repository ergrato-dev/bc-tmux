# Semana 05 — Configuración y alcance de opciones

## Descripción

Tu config deja de ser un archivo de pruebas y pasa a ser tu entorno diario. Aprenderás qué archivos carga tmux y cuándo, en qué nivel vive cada opción (servidor, sesión, ventana, panel) y cómo se hereda, y a recargar sin cerrar nada ni duplicar valores. Cierras con tu `tmux-kit` dividido en módulos de `conf.d/` y un prefix elegido por ti.

## Objetivos de aprendizaje

Al terminar esta semana, podrás:

- Explicar qué archivos de config carga tmux, en qué orden y cuándo, y encontrar sus errores sin conectar un cliente
- Instalar tu config en `~/.config/tmux` sin pisar nada y detectar un `~/.tmux.conf` olvidado
- Elegir un prefix con criterio, liberar `C-b` y mantener `send-prefix`
- Fijar opciones en servidor, sesión, ventana y panel, leerlas con `show -A` y quitarlas con `-u`
- Averiguar de qué nivel sale el valor de una opción con un script
- Escribir una config que da el mismo resultado tras una recarga o tras diez
- Dividir la config en `conf.d/` con rutas absolutas, orden explícito y `local.conf` por máquina

## Prerrequisitos

- [Semana 04](../week-04-copy_mode_buffers_y_portapapeles/README.md) completada: copy mode, buffers y `tmux-kit` con `tmux.conf` y `kit-copy`
- Laboratorio Docker construido (`docker compose build`) y dos terminales para los labs 03 y 04
- `shellcheck` para el proyecto

## Contenido

| # | Tipo | Tema | Tiempo |
|---|------|------|--------|
| — | Teoría | [01-config-y-recarga.md](1-teoria/01-config-y-recarga.md) · [02-alcances-de-opciones.md](1-teoria/02-alcances-de-opciones.md) | 45 min |
| — | Conocimiento | [10 preguntas](rubrica-evaluacion.md#-conocimiento-30) | 15 min |
| 1 | Lab | [lab-01-donde-vive-la-config](2-practicas/lab-01-donde-vive-la-config/) | 60 min |
| 2 | Lab | [lab-02-prefix-propio](2-practicas/lab-02-prefix-propio/) | 60 min |
| 3 | Lab | [lab-03-alcances-y-herencia](2-practicas/lab-03-alcances-y-herencia/) | 60 min |
| 4 | Lab | [lab-04-recarga-en-caliente](2-practicas/lab-04-recarga-en-caliente/) | 60 min |
| 5 | Lab | [lab-05-config-modular](2-practicas/lab-05-config-modular/) | 60 min |
| 6 | Lab | [lab-06-config-rota](2-practicas/lab-06-config-rota/) | 60 min |
| — | Proyecto | [tmux-kit: config modular y recarga en caliente](3-proyecto/) | 3 h |

**Total: 10 horas**

## Distribución del tiempo

```
[45 min] Leer 1-teoria/ (config y recarga + alcances de opciones)
[15 min] Responder las 10 preguntas de Conocimiento
[60 min] lab-01 — Orden de carga, XDG, errores sin cliente e install.sh
[60 min] lab-02 — Elegir prefix, unbind C-b, send-prefix y prefix2
[60 min] lab-03 — Servidor, sesión, ventana y panel; show -A, -u y scope.sh
[60 min] lab-04 — prefix r, lo que la recarga no deshace, -ga y compare-reload.sh
[60 min] lab-05 — conf.d/, @lab-dir, orden del glob, local.conf, %if y check-modules.sh
[60 min] lab-06 — Depurar una config modular con cuatro errores
[3 h]    Proyecto: tmux.conf + conf.d/, prefix propio y kit-option
```

## Verificación de completitud

Desde la raíz del repositorio:

```bash
./scripts/verificar-semana.sh 05
```

Comprueba tu proyecto (`3-proyecto/starter/`) contra los 18 requisitos
verificables de la semana, dentro del laboratorio Docker. Al terminar deben
pasar todos, y tu kit debe cargar igual desde cualquier directorio:

```bash
(cd / && tmux -L kit -f "$OLDPWD/3-proyecto/starter/tmux.conf" new -d)
tmux -L kit show -gv prefix; tmux -L kit kill-server
```

## 🔗 Navegación

| Anterior | Actual | Siguiente |
|---|---|---|
| [← Semana 04 — Copy mode, buffers y portapapeles](../week-04-copy_mode_buffers_y_portapapeles/README.md) | **Semana 05 — Configuración y alcance de opciones** | Semana 06 — Key bindings, tablas y navegación |

[← Volver al índice del bootcamp](../README.md)
