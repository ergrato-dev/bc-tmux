# Política de Seguridad

## Versiónes Soportadas

| Versión | Soportada |
| ------- | --------- |
| main    | Sí        |

## Reportar una vulnerabilidad

Si descubres una vulnerabilidad de seguridad en este material o en los scripts del repositorio, te pedimos que la reportes de manera responsable.

### NO hacer público el reporte

Por favor, **NO** abras un issue público para reportar vulnerabilidades de seguridad.

### Cómo reportar

1. **Abre un Security Advisory privado** en GitHub:
   - Ve a la pestaña "Security" del repositorio
   - Haz clic en "Report a vulnerability"
   - Completa el formulario con los detalles

2. **Incluye en tu reporte**:
   - Descripción detallada de la vulnerabilidad
   - Pasos para reproducir el problema
   - Impacto potencial
   - Sugerencias de solución (si las tienes)

### Tiempo de respuesta

- **Confirmación inicial**: 48 horas
- **Evaluación**: 7 días
- **Resolución**: Dependiendo de la severidad

---

## Qué se considera vulnerabilidad en este repositorio

Este es material educativo, no un servicio en producción. Cuentan como vulnerabilidad:

- **Un secreto real comiteado** en cualquier archivo del repositorio.
- **Un ejemplo que enseña un antipatrón sin marcarlo como tal** y que un alumno copiaría a su equipo: un socket de tmux con permisos para todos, `send-keys` con texto externo sin citar, un `run-shell` que ejecuta contenido descargado.
- **Un script de `bin/` o `scripts/` con inyección de comandos**, escalada de privilegios o borrado fuera de su directorio.
- **Un plugin o una imagen Docker sin versión fijada.**

## Prácticas de seguridad que enseña este bootcamp

### El socket de tmux es una puerta a tu shell

Quien puede escribir en el socket de tu servidor (`/tmp/tmux-UID/default`) puede ejecutar comandos como tú. tmux crea el directorio con permisos `0700`; no los cambies. Para compartir una sesión usa `server-access` (tmux 3.3+) y `attach -r` para invitados de solo lectura, nunca `chmod 777` del socket.

### `send-keys` escribe en una shell

```bash
# Mal: si "$cmd" viene de fuera, se ejecuta lo que traiga
tmux send-keys -t api "$cmd" Enter

# Bien: -l envía texto literal y tú decides si pulsar Enter
tmux send-keys -t api -l -- "$cmd"
```

### Los plugins son código que se ejecuta al arrancar tmux

TPM clona y ejecuta lo que pongas en `@plugin`. Fija cada plugin por tag o commit y lee su archivo `*.tmux` antes de instalarlo.

## Dependencias

Este bootcamp referencia:

- tmux >= 3.4 (ver [`docs/stack-versions.md`](docs/stack-versions.md))
- Docker con Compose v2 para el laboratorio y el autograding
- bash, jq y shellcheck para los scripts de verificación
- Python solo en la semana 11 y siempre con uv; Node.js no se usa (si hiciera falta, siempre con pnpm)

---

Gracias por ayudar a mantener este proyecto seguro.
