# /gen-lab

Genera un lab individual (ejercicio práctico) para una semana del bootcamp.

## Uso

```
/gen-lab <semana-carpeta> <NN> "<nombre-kebab>" "<Objetivo del lab>"
```

**Ejemplo:**
```
/gen-lab week-05-configuracion_y_alcance_de_opciones 03 "herencia-de-opciones" "Predecir qué valor ve cada ventana cuando una opción se define en varios alcances"
```

---

## Instrucciones para Claude

Lee `CLAUDE.md` para convenciones. **Aplica entero `CLAUDE.md` § Estándar paso a paso**: es obligatorio, no orientativo. El lab debe:

### Archivos a crear

**`bootcamp/<semana>/2-practicas/lab-<NN>-<nombre>/README.md`**

Estructura obligatoria en este orden:
1. `# Lab NN — Título` con `⏱ ~60 min` en la misma línea o justo debajo
2. `## Objetivo` — una sola oración con verbo en infinitivo
3. `## Contexto` — máx. 3 párrafos o 5 bullets; referencia al tema de la semana sin repetir la teoría
4. `## Instrucciones` — paso 0 con `cd` a la carpeta del lab y terminal fuera de tmux; pasos numerados con comandos y teclas exactos; **cada bloque de comandos va seguido de su output literal** (o `(sin salida)`); cada TODO del starter tiene su subpaso con pista, comando de prueba y output; cada `attach` dice terminal y cómo salir
5. `## Criterios de éxito` — checklist verificable: "`tmux -L lab show -gv <opción>` imprime …", "`tmux -L lab list-keys -T prefix <tecla>` muestra …"
6. `## Reto extra` — extensión opcional para ir más lejos

**`bootcamp/<semana>/2-practicas/lab-<NN>-<nombre>/starter/`** (`tmux.conf` y/o scripts de `bin/`)

- Scaffolding real: estructura visible, comentarios de orientación
- TODOs marcados como `# TODO: ...`
- La config carga sin error con los TODOs sin completar (`source-file -n` la acepta); los scripts pasan `bash -n`
- Cabecera con cómo probarlo sin tocar la sesión del estudiante: `tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab`
- Cada TODO dice qué comando u opción de tmux usar; si hay un `echo "sin implementar"`, el TODO dice que se borra
- Excepción: los labs de config rota a propósito llevan `roto`/`rota`/`debug` en el nombre de la carpeta

**`bootcamp/<semana>/2-practicas/lab-<NN>-<nombre>/solucion/`**

- Solución completa, funcional, sin TODOs
- Código limpio con los estándares de CLAUDE.md
- Comentarios solo donde el WHY no es obvio

### Criterio de calidad del lab

- El estudiante debe poder completarlo sin salir de la carpeta del lab
- Cada paso tiene un resultado observable: algo cambia en pantalla o en la salida de `show`/`list-keys`/`display -p`
- **Ejecutado de verdad** con tmux 3.4 en el laboratorio (`docker compose run --rm lab`): cada output del README se pega de esa ejecución, no se escribe de memoria
- Todo criterio de éxito sale de un paso; ningún paso usa algo que no se creó antes
- El prefix que se nombra es el que tiene de verdad el servidor del lab (`C-b` con `-f /dev/null`)
- Progresión: cada paso del lab desbloquea el siguiente
