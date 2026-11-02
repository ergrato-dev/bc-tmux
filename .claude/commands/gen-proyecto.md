# /gen-proyecto

Genera el proyecto semanal integrador de una semana del bootcamp.

## Uso

```
/gen-proyecto <semana-carpeta> "<Título del proyecto>" "<contexto técnico en una línea>"
```

**Ejemplo:**
```
/gen-proyecto week-09-scripting_de_tmux_desde_shell "dev-up idempotente" "bin/dev-up crea o reutiliza la sesión de un proyecto con tres ventanas"
```

---

## Instrucciones para Claude

Lee `CLAUDE.md`. El proyecto debe integrar **todos** los conceptos de la semana, no solo uno.

### Archivos a crear

**`bootcamp/<semana>/3-proyecto/README.md`**

Secciones obligatorias:
1. `# Proyecto Semana NN — Título`
2. `## Contexto` — situación concreta (empresa ficticia, caso técnico real), 2-3 párrafos
3. `## Estructura del proyecto` — árbol de archivos que el estudiante recibirá en `starter/`
4. `## Lo que debes construir` — lista numerada de entregables concretos
5. `## Verificación` — comandos exactos que deben funcionar al terminar:
   ```bash
   tmux -L kit -f starter/tmux.conf          # la config carga sin errores
   tmux -L kit show -gv <opción>             # valores esperados
   TMUX_SOCKET=kit starter/bin/<script>      # scripts contra el servidor aislado
   ./scripts/verificar-semana.sh NN          # autograding
   ```
6. `## Rúbrica del proyecto` — tabla con los 30 puntos distribuidos por criterio
7. `## Entrega` — instrucciones de commit y qué archivos entregar

**`bootcamp/<semana>/3-proyecto/starter/`** (el `tmux-kit` de la semana anterior)

- Copia exacta de `../week-(NN-1)-*/3-proyecto/solucion/` (ver `docs/proyecto-hilo-conductor.md`) más los TODOs de esta semana
- La config carga sin error con los TODOs sin completar; los scripts pasan `bash -n`
- Scripts que respetan `TMUX_SOCKET` (`tmux ${TMUX_SOCKET:+-L "$TMUX_SOCKET"}`)

**`bootcamp/<semana>/3-proyecto/solucion/`** (el `tmux-kit` al terminar esta semana)

- Solución completa al 100%
- Código profesional, sin atajos
- Comentarios explicando decisiones de diseño no obvias
- `shellcheck` limpio en `bin/`; scripts idempotentes

### Criterio de calidad del proyecto

- Debe tomar ~3h para alguien que completó los labs de la semana
- Si se puede completar en 1h, es demasiado simple — agregar complejidad
- Escribe primero (o actualiza) `checks.json` de la semana; el README del proyecto copia sus `descripcion` en `✅ Requisitos verificables`
- El contexto debe ser real (no "configura un tmux.conf de ejemplo")
- Los criterios de éxito deben ser binarios: funciona o no funciona
