# /gen-teoria

Genera el archivo de contexto mínimo (1-teoria) para una semana.

## Uso

```
/gen-teoria <semana-carpeta> "<tema>" "<conceptos clave separados por coma>"
```

**Ejemplo:**
```
/gen-teoria week-07-formats_y_status_line "Formats y status line" "#{}, #{?cond,a,b}, modificadores, #(), estilos"
```

---

## Instrucciones para Claude

Lee `CLAUDE.md`. La teoría es un **puente mínimo** al lab, no un tutorial completo.

### Archivo a crear

**`bootcamp/<semana>/1-teoria/01-contexto.md`**

Estructura obligatoria:

```markdown
# Contexto — <Tema>

## ¿Por qué importa esto?
<1 párrafo directo. Qué problema resuelve. Qué pasa si no lo sabes.>

## Referencia rápida

<tabla o snippets con los conceptos clave — máximo lo que cabe en una pantalla>

## Ejemplo mínimo funcional

<config o secuencia de comandos de 10-25 líneas que demuestre todos los conceptos clave juntos>
<Debe poder pegarse y funcionar en tmux 3.4 con `tmux -L demo`>

## Qué observar cuando ejecutes el ejemplo

<3-5 bullets: qué output esperar, qué comando ver, qué comportamiento notar>

---
Listo. Ve al [lab-01](../2-practicas/lab-01-.../README.md) y ponlo en práctica.
```

### Restricciones estrictas

- Máximo 600 palabras en prosa
- No explicar la historia de screen/tmux
- No listar todos los casos edge — solo el 80% que se usa siempre
- No repetir lo que los labs explican step-by-step
- El ejemplo debe ser autocontenido y no tocar la sesión del estudiante (siempre `-L demo`)
- Usar `@echo` para demostrar conceptos cuando no hay archivos reales de por medio
