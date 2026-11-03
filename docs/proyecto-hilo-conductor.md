# Proyecto hilo conductor: `tmux-kit`

Durante las 13 semanas construyes **tu propio kit de tmux**: la configuración,
los atajos, la status line, los scripts y el plugin que vas a usar a diario
cuando termines. No es un ejercicio que se tira: es tu entorno de trabajo.

## Cómo crece

Cada `3-proyecto/starter/` es la solución de la semana anterior con los TODOs
de la semana actual. Si prefieres seguir con tu propio kit en lugar del
starter, adelante: los checks solo miran el comportamiento.

| Semana | Lo que se añade a `tmux-kit` |
|---|---|
| 01 | Repositorio, `README.md`, `bin/check-version`, `bin/kit-tree` |
| 02 | Layout de trabajo de 3 paneles documentado |
| 03 | `bin/kit-sessions`: lista y salta entre sesiones |
| 04 | Copia al portapapeles en local y por SSH |
| 05 | `tmux.conf` modular con `conf.d/` y recarga en caliente |
| 06 | `conf.d/20-bindings.conf`: modo resize + navegación `C-h/j/k/l` agnóstica del editor |
| 07 | `conf.d/30-status.conf`: status line propia |
| 08 | `conf.d/40-terminal.conf` + `docs/diagnostico.md` |
| 09 | `bin/dev-up`: entorno de proyecto idempotente |
| 10 | Popup selector de proyectos, menú de acciones y hooks |
| 11 | `plugin/`: plugin propio con la convención de TPM |
| 12 | Pair programming con socket compartido + toggle para tmux anidado |
| 13 | `install.sh`, checks propios y README final |

## Estructura final

```
tmux-kit/
├── README.md
├── tmux.conf            # punto de entrada: solo source-file de conf.d/
├── conf.d/
│   ├── 10-options.conf
│   ├── 20-bindings.conf
│   ├── 30-status.conf
│   ├── 40-terminal.conf
│   └── 50-plugins.conf
├── bin/                 # dev-up, sesiones, popups...
├── plugin/              # plugin propio (semana 11)
├── docs/diagnostico.md  # guía de diagnóstico (semana 08)
└── install.sh           # enlaza tmux.conf en ~/.config/tmux (semana 13)
```

## Reglas

- **Versionado con git desde la semana 01.** Un commit por semana como mínimo.
- **Los scripts respetan `TMUX_SOCKET`** (`tmux ${TMUX_SOCKET:+-L "$TMUX_SOCKET"}`): así el autograding los prueba en un servidor aislado.
- **Nada de rutas absolutas a tu home** dentro de `tmux-kit`: usa `~` o variables, para que el kit funcione en cualquier máquina.
- **Dentro de la config no hay secretos ni hosts reales.**
