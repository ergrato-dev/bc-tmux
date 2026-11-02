# /revisar-semana

Audita una semana generada para verificar consistencia, calidad y adherencia a los estándares del bootcamp.

## Uso

```
/revisar-semana <semana-carpeta>
```

**Ejemplo:**
```
/revisar-semana week-01-primeros_pasos_y_modelo_cliente_servidor
```

---

## Instrucciones para Claude

Lee `CLAUDE.md` y luego revisa todos los archivos de `bootcamp/<semana>/`. Reporta:

### Checklist a verificar

**Estructura**
- [ ] Existen todos los directorios: `0-assets/`, `1-teoria/`, `2-practicas/`, `3-proyecto/`, `4-recursos/`, `5-glosario/`
- [ ] `README.md` de la semana tiene todas las secciones requeridas
- [ ] `rubrica-evaluacion.md` usa 30/40/30 con 10 preguntas de Conocimiento y 70% por evidencia
- [ ] `checks.json` existe, es válido; `./scripts/verificar-semana.sh NN` falla contra el starter y `ENTREGA=solucion ./scripts/verificar-semana.sh NN` pasa N/N
- [ ] README tiene `## 🔗 Navegación` y la semana figura en `bootcamp/README.md`
- [ ] Hay 6 labs en `2-practicas/`
- [ ] Cada lab tiene `README.md`, `starter/` y `solucion/`
- [ ] El proyecto tiene `README.md`, `starter/` y `solucion/`
- [ ] `0-assets/` tiene los diagramas que pide el contenido: ninguno que sea una lista o tabla dibujada, ningún concepto de grafo/flujo/secuencia sin diagrama. Solo `.svg` (ningún `.md`), cada uno con `viewBox`, `role="img"`, `<title>`, fondo `#0d1117` y la paleta de `CLAUDE.md`, y enlazado desde `1-teoria/`

**Calidad de configs y scripts**
- [ ] Opciones globales siempre con `-g` explícito; `setw`/`set -p` solo donde el alcance lo pide
- [ ] Nada de `default-terminal xterm-256color` dentro de tmux; config en `~/.config/tmux/` (XDG)
- [ ] Toda solución carga sin errores en tmux 3.4 (laboratorio) y no usa features 3.5+ sin marcarlas
- [ ] Scripts con `#!/usr/bin/env bash` + `set -euo pipefail`, `shellcheck` limpio, idempotentes y respetando `TMUX_SOCKET`
- [ ] Ningún `send-keys` con texto externo sin `-l`; ningún `kill-server` sin `-L`

**Calidad de contenido**
- [ ] Cada archivo de `1-teoria/` tiene menos de 600 palabras de prosa
- [ ] La teoría no repite lo que los labs explican paso a paso
- [ ] Los labs tienen criterios de éxito verificables
- [ ] El proyecto toma ~3h (no más de 4, no menos de 2h)
- [ ] `./scripts/verificar-enlaces.sh` sale 0
- [ ] Idioma: prosa en español con tuteo (ningún voseo: `grep -rnwE 'vos|tenés|podés|hacé|querés|sabés|usá|mirá|probá|escribí'` vacío), código en inglés

**Progresión pedagógica**
- [ ] Lab 01 es el más sencillo, Lab 05/06 el más complejo
- [ ] El proyecto integra todos los conceptos de la semana
- [ ] No aparecen conceptos de semanas futuras sin advertencia

### Output esperado

Tabla con ✅ / ❌ / ⚠️ para cada ítem. Para los ❌ y ⚠️, describe exactamente qué falta o está mal y sugiere el fix.

Al final: resumen en 2-3 líneas del estado general de la semana.
