# Autograding

`scripts/verificar-semana.sh` te dice qué te falta antes de entregar. No sabe
nada de ninguna semana en concreto: lee `bootcamp/week-NN-*/checks.json` y
ejecuta lo que ahí ponga.

---

## Uso

```bash
./scripts/verificar-semana.sh --doctor   # comprueba tu entorno
./scripts/verificar-semana.sh 03         # comprueba la Semana 03 (en el laboratorio Docker)
./scripts/verificar-semana.sh --host 04  # comprueba la Semana 04 con el tmux de tu equipo
```

Por defecto los checks corren dentro del laboratorio (`compose.yaml`, tmux 3.4):
todos obtienen el mismo resultado sin importar qué tmux tengan instalado.
`--host` es para las semanas que dependen de tu terminal o tu portapapeles
(04, 08 y 13); su README lo indica.

Cada check usa un **servidor tmux aislado** (`-L bc-check`). El verificador lo
mata antes de cada check y al terminar: nunca toca tus sesiones.

Salida:

```
Semana 05 — Configuración y alcance de opciones

  ✅ El prefix es C-a
  ✅ base-index empieza en 1
  ❌ prefix r recarga la configuración
     pista: 2-practicas/lab-04-recarga-en-caliente/README.md, paso 2

  8/9 comprobaciones superadas.
```

Sale con 0 si pasan todas, con 1 si falla alguna. **Cada pista dice en qué lab
y en qué paso se arregla**: si una pista no lleva ahí, es un fallo del material
y merece un issue.

Para forzar otro binario de tmux con `--host`:
`TMUX_BIN=/ruta/a/tmux ./scripts/verificar-semana.sh --host 04`.

---

## Formato de `checks.json`

Un archivo por semana, en la raíz de la carpeta de la semana.

```json
{
  "semana": "05",
  "titulo": "Configuración y alcance de opciones",
  "checks": [
    {
      "id": "prefix-c-a",
      "descripcion": "El prefix es C-a",
      "cmd": "{tmux} -f {proyecto}/tmux.conf new-session -d ; {tmux} show -gv prefix",
      "assert": "stdout~^C-a$",
      "pista": "2-practicas/lab-02-prefix-propio/README.md, paso 3"
    },
    {
      "id": "recarga",
      "descripcion": "prefix r recarga la configuración",
      "cmd": "{tmux} -f {proyecto}/tmux.conf new-session -d ; {tmux} list-keys -T prefix r",
      "assert": "stdout~source-file",
      "pista": "2-practicas/lab-04-recarga-en-caliente/README.md, paso 2"
    }
  ]
}
```

### Campos

| Campo | Obligatorio | Qué es |
|---|:--:|---|
| `id` | sí | Identificador estable en kebab-case. **Nunca se renombra** |
| `descripcion` | sí | Qué se comprueba, en una línea. **Se copia literal** a `3-proyecto/README.md` |
| `cmd` | sí | Comando bash que se ejecuta desde la raíz del repositorio |
| `assert` | sí | Qué tiene que cumplirse. Ver la tabla siguiente |
| `pista` | sí | Archivo y paso donde se arregla |

### Aserciones

| `assert` | Se cumple si |
|---|---|
| `exit0` | el comando sale con código 0 |
| `exit!=0` | el comando sale distinto de 0 |
| `exit=N` | el comando sale exactamente con el código `N` |
| `stdout~RE` | la salida (stdout + stderr) casa con la expresión regular extendida `RE` |
| `stdout!~RE` | la salida **no** casa con `RE` |

La salida incluye stderr a propósito: los errores de tmux (`unknown option`,
`too few arguments`, `can't find session`) salen por ahí.

> [!IMPORTANT]
> **Las expresiones regulares no pueden llevar `\`.** El verificador lee los
> campos con `jq @tsv`, que escapa la barra invertida. Usa `.` para un carácter
> cualquiera y clases como `[*]` en lugar de `\*`.

### Marcadores

| Marcador | Se sustituye por |
|---|---|
| `{raiz}` | Ruta absoluta del repositorio |
| `{semana}` | Ruta de la carpeta de la semana, p. ej. `bootcamp/week-03-shell_y_modo_estricto` |
| `{tmux}` | `env -u TMUX tmux -L bc-check`: tmux con el servidor aislado de los checks |
| `{proyecto}` | `{semana}/3-proyecto/starter`; con `ENTREGA=solucion`, `{semana}/3-proyecto/solucion` |

Usa siempre `{tmux}`, nunca `tmux` a secas: sin `-L` el check hablaría con
el servidor del estudiante. Los scripts de `bin/` que el check ejecuta reciben
el socket con la variable `TMUX_SOCKET=bc-check` y deben respetarla
(`tmux ${TMUX_SOCKET:+-L "$TMUX_SOCKET"}`). Así se prueban sin tocar sesiones reales.

Un check que necesita varios comandos de tmux arranca el servidor en el primero
(`new-session -d`) y los siguientes hablan con él por el mismo socket.

Apunta al proyecto siempre con `{proyecto}`, nunca con `3-proyecto/starter` literal:
así la misma comprobación valida la solución de referencia con
`ENTREGA=solucion ./scripts/verificar-semana.sh NN`.

---

## Reglas de diseño

1. **El `checks.json` se escribe antes que el contenido.** Define qué es
   entregable y, por tanto, qué tienen que enseñar los labs.
2. **Entre 6 y 18 comprobaciones**, creciendo con la complejidad de la semana.
3. **Una comprobación, un hecho.** Si la descripción necesita una "y", son dos.
4. **`descripcion` se copia palabra por palabra** a
   `3-proyecto/README.md § ✅ Requisitos verificables`.
5. **Cero lógica de la semana en `verificar-semana.sh`.** Si una comprobación
   necesita código imperativo, va a la rúbrica manual.
6. **La comprobación no puede pasar por accidente.** `test -f tmux.conf` se
   cumple con un archivo vacío. Comprueba comportamiento: carga la config y
   pregúntale a tmux qué quedó.
7. **Ninguna comprobación toca la red ni necesita privilegios.**
8. **Ninguna comprobación habla con el servidor por defecto.** Siempre `{tmux}`.

---

## Lo que sí se puede comprobar

tmux responde preguntas sobre su estado con `show-options`, `list-keys`,
`display -p` y `list-* -F`, así que casi todo es verificable:

```json
{ "id": "config-parsea",
  "descripcion": "tmux.conf carga sin errores",
  "cmd": "{tmux} -f /dev/null new-session -d ; {tmux} source-file {proyecto}/tmux.conf",
  "assert": "exit0",
  "pista": "1-teoria/01-contexto.md" }
```

```json
{ "id": "dev-up-idempotente",
  "descripcion": "Ejecutar bin/dev-up dos veces deja una sola sesión api",
  "cmd": "export TMUX_SOCKET=bc-check; {proyecto}/bin/dev-up api -d && {proyecto}/bin/dev-up api -d && {tmux} list-sessions -F '#{session_name}' | grep -cx api",
  "assert": "stdout~^1$",
  "pista": "2-practicas/lab-03-has-session/README.md, paso 4" }
```

```json
{ "id": "layout-tres-paneles",
  "descripcion": "La ventana editor tiene tres paneles",
  "cmd": "export TMUX_SOCKET=bc-check; {proyecto}/bin/dev-up api -d && {tmux} display -p -t api:editor '#{window_panes}'",
  "assert": "stdout~^3$",
  "pista": "3-proyecto/README.md, paso 2" }
```

```json
{ "id": "sin-default-terminal-xterm",
  "descripcion": "La config no fuerza TERM=xterm-256color dentro de tmux",
  "cmd": "grep -rnE 'default-terminal.*xterm' {proyecto}/tmux.conf {proyecto}/conf.d",
  "assert": "exit!=0",
  "pista": "1-teoria/01-term-y-terminfo.md" }
```

## Lo que no se puede comprobar

- Que la config sea **legible** y esté comentada. Eso es rúbrica manual.
- Lo que depende de tu terminal (colores reales, portapapeles del sistema): lo
  revisas tú en `--host` con la lista de la rúbrica.
- Que entiendas lo que escribiste. Eso son las preguntas de Conocimiento.
- Que la elección de diseño sea **la buena**.

Por eso el Producto vale 30% y solo 60 de sus 100 puntos son automáticos.

---

## Escribir una comprobación nueva

1. Ejecuta el comando **a mano**, con un caso que pasa y otro que falla. Si no
   distingue los dos, la comprobación no vale.
2. Comprueba el código de salida con `echo $?`.
3. Añádela al `checks.json` con su `pista`.
4. Copia la `descripcion` al `3-proyecto/README.md`.
5. Corre `./scripts/verificar-semana.sh NN`: tiene que **fallar** contra el
   starter y **pasar** contra la solución. Una comprobación que nunca ha estado
   en rojo no se ha probado.
