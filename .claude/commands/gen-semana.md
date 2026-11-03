# /gen-semana

Genera el contenido completo de una semana del bootcamp bc-tmux.

## Uso

```
/gen-semana <NN> <carpeta> "<Título del tema>"
```

**Ejemplo:**
```
/gen-semana 02 week-02-ventanas_y_paneles "Ventanas y paneles"
```

---

## Instrucciones para Claude

Lee `CLAUDE.md` antes de generar. Respeta todas las convenciones definidas ahí.

Genera **todos** los archivos listados abajo para la semana `$ARGUMENTS`. No omitas ninguna sección.

---

### 1. `bootcamp/<carpeta>/README.md`
- Título, descripción (2-3 oraciones), objetivos (verbos de acción), prerrequisitos
- Tabla de contenidos con tiempos: 45 min teoría / 15 min conocimiento / 6h labs (6×60 min) / 3h proyecto = 10 h
- Sección "Distribución del tiempo"
- Sección "Verificación de completitud": `./scripts/verificar-semana.sh NN`
- Sección `## 🔗 Navegación` (formato en `bootcamp/PLANTILLA-SEMANA.md`) y fila en `bootcamp/README.md`

### 2. `bootcamp/<carpeta>/rubrica-evaluacion.md`
- Formato de `../bc-curl/bootcamp/week-01-*/rubrica-evaluacion.md`: 🧠 Conocimiento 30% (10 preguntas, 3 pts c/u) / 💪 Desempeño 40% (6 labs) / 📦 Producto 30% (60 pts autograding + 40 calidad)
- Mínimo 70% en cada evidencia; bandas Sobresaliente/Notable/Aprobado

### 2b. `bootcamp/<carpeta>/checks.json`
- **Se escribe antes que labs y proyecto.** Contrato en `docs/autograding.md`: 6–18 comprobaciones sobre el proyecto con los marcadores `{tmux}` y `{proyecto}`, cada una con `pista`
- Debe fallar contra el starter (`./scripts/verificar-semana.sh NN`) y pasar contra la solución (`ENTREGA=solucion ./scripts/verificar-semana.sh NN`)

### 3. `bootcamp/<carpeta>/0-assets/` — Diagramas SVG (los que pida el contenido)

Un `.svg` escrito a mano por diagrama, con la paleta y las reglas de `CLAUDE.md` § 0-assets (procedimiento en `/gen-svg`). Nada de Mermaid ni arte ASCII. Cada SVG se enlaza desde el archivo de `1-teoria/` donde aparece el concepto.

Sin cupo fijo. Recorre la teoría y dibuja un diagrama donde el texto se queda corto; ninguno donde no. Candidatos habituales, solo si el tema los pide:
- el grafo o el flujo del concepto central
- cómo tmux lo procesa (servidor/cliente, herencia de opciones, tablas de teclas, eventos)
- una decisión o comparación entre variantes

### 4. `bootcamp/<carpeta>/1-teoria/` (1–3 archivos, 45 min en total)
- Máximo 600 palabras de prosa por archivo
- Abre con "¿Por qué importa esto?" (1 párrafo directo)
- Referencia rápida: tabla o snippet con los conceptos clave
- Ejemplo mínimo funcional (config o comandos que se pegan y funcionan en tmux 3.4 con `tmux -L demo`)
- Termina con enlace al lab-01: "Listo. Ve al [lab-01](../2-practicas/lab-01-.../README.md) y ponlo en práctica."

### 5. `bootcamp/<carpeta>/2-practicas/README.md`
- Tabla con 6 labs: número, nombre, objetivo en una línea, duración estimada (~60 min)

### 6–17. `bootcamp/<carpeta>/2-practicas/lab-0N-<nombre>/` — Los 6 labs

Para **cada** lab genera 3 archivos:

**`README.md`** con secciones en orden:
1. Título + duración estimada
2. Objetivo (verbo en infinitivo, una oración)
3. Contexto (máx. 3 párrafos/bullets)
4. Instrucciones: sigue `.claude/commands/gen-lab.md` y `CLAUDE.md` § Estándar paso a paso (paso 0, output tras cada bloque, subpaso por TODO)
5. Criterios de éxito (checklist con comando de tmux y output esperado)
6. Reto extra (opcional)

**`starter/`** (`tmux.conf` y/o `bin/`) con:
- Scaffolding real y cabecera con cómo probarlo: `tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab`
- TODOs comentados (`# TODO: ...`) donde el estudiante debe implementar
- Carga sin errores con los TODOs sin completar (salvo labs rotos a propósito)

**`solucion/`** con:
- Solución completa y funcional, sin TODOs
- Estándares de `CLAUDE.md` § Estándares de tmux (`-g` explícito, XDG, scripts estrictos e idempotentes)
- Probada con tmux 3.4 en el laboratorio

### 18. `bootcamp/<carpeta>/3-proyecto/README.md`
- Contexto de negocio/técnico concreto (no abstracto)
- Árbol de archivos del starter
- Lista de entregables numerados
- Sección `## Paso a paso` (ver `.claude/commands/gen-proyecto.md`)
- Comandos exactos de verificación con outputs esperados
- Sección `✅ Requisitos verificables`: las `descripcion` de `checks.json`, copiadas literalmente
- Criterios de calidad manual (40 pts)
- Instrucciones de entrega (mensaje de commit)

### 19. `bootcamp/<carpeta>/3-proyecto/starter/` (tmux-kit de la semana anterior + TODOs)
- Estructura definida con secciones comentadas
- TODOs en cada target a implementar
- Cada `bin/*` responde al uso incorrecto con exit 2 desde el inicio

### 20. `bootcamp/<carpeta>/3-proyecto/solucion/` (tmux-kit al terminar la semana)
- Solución completa y profesional

### 21. `bootcamp/<carpeta>/4-recursos/ebooks-free/README.md`
Tabla con libros/documentos gratuitos descargables o legibles online (mínimo 2):
```
| Título | Formato | Descripción | Enlace |
```

### 22. `bootcamp/<carpeta>/4-recursos/videografia/README.md`
Tabla con videos de YouTube u otras plataformas abiertas (mínimo 3):
```
| Título | Canal | Duración | Enlace |
```
Preferir en español; complementar con inglés si no hay suficientes de calidad.

### 23. `bootcamp/<carpeta>/4-recursos/webgrafia/README.md`
Tabla con documentación oficial y artículos de calidad (3–5 recursos):
```
| Recurso | Descripción |
```

### 24. `bootcamp/<carpeta>/5-glosario/README.md`
Tabla con 8–15 términos nuevos de la semana:
```
| Término | Definición en una línea | Ejemplo |
```

### 25. Navegación al pie de cada documento
Con todos los archivos escritos, ejecuta `./scripts/generar-navegacion.sh NN` (y el de la semana anterior, para que su glosario enlace a esta). Añade al pie de teoría, labs, proyecto, rúbrica, recursos y glosario la tabla `← Anterior | Siguiente →` en orden de lectura; `verificar-enlaces.sh` falla si falta.

---

Al terminar, confirma cuántos archivos creaste y lista sus rutas.
