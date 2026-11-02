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

Lee `CLAUDE.md` y aplica entero § Estándar paso a paso. El proyecto debe integrar **todos** los conceptos de la semana, no solo uno.

### Archivos a crear

**`bootcamp/<semana>/3-proyecto/README.md`**

Secciones obligatorias:
1. `# Proyecto Semana NN — Título`
2. `## Contexto` — situación concreta (empresa ficticia, caso técnico real), 2-3 párrafos
3. `## Estructura del proyecto` — árbol de archivos que el estudiante recibirá en `starter/`
4. `## Lo que debes construir` — entregables concretos (qué hace cada archivo)
5. `## Paso a paso` — recorre los TODOs del starter en orden. Por cada uno: qué hacer, pista de sintaxis, comando de prueba y su output literal. Se trabaja sobre `3-proyecto/starter/` (lo que corrige el autograding), con `cd` explícito al principio
6. `## Verificación` — comandos exactos al terminar, cada uno seguido de su output:
   ```bash
   cd "$(git rev-parse --show-toplevel)/bootcamp/<semana>/3-proyecto/starter"
   tmux -L kit -f "$PWD/tmux.conf" new -d -s kit; echo $?   # 0
   tmux -L kit show -gv <opción>                            # <valor>
   TMUX_SOCKET=kit bin/<script>                             # <output>
   tmux -L kit kill-server
   cd "$(git rev-parse --show-toplevel)" && ./scripts/verificar-semana.sh NN   # N/N
   ```
7. `## ✅ Requisitos verificables` — las `descripcion` de `checks.json`, literales
8. `## Calidad` — los 40 pts de calidad manual
9. `## Entrega` — instrucciones de commit y qué archivos entregar

**`bootcamp/<semana>/3-proyecto/starter/`** (el `tmux-kit` de la semana anterior)

- Copia exacta de `../week-(NN-1)-*/3-proyecto/solucion/` (ver `docs/proyecto-hilo-conductor.md`) más los TODOs de esta semana
- La config carga sin error con los TODOs sin completar; los scripts pasan `bash -n`
- Scripts que respetan `TMUX_SOCKET` (`tmux ${TMUX_SOCKET:+-L "$TMUX_SOCKET"}`)
- Cada TODO nombra el comando de tmux, las variables de formato o el lab de la semana donde se vio

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
