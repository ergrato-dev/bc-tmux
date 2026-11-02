# tmux-kit

Mi kit personal de tmux: configuración y scripts que uso a diario en Ubuntu 24.04 (WSL2). Crece una semana a la vez durante el bootcamp.

## Requisitos

- tmux 3.4 o superior. Compruébalo con:

  ```bash
  bin/check-version          # tmux 3.4 >= 3.4: ok
  ```

## Scripts

| Script | Qué hace | Ejemplo |
|---|---|---|
| `bin/check-version` | Comprueba que tmux cumple la versión mínima. Sale con 0 (cumple), 1 (vieja) o 2 (no está) | `bin/check-version 3.5` |
| `bin/kit-tree` | Dibuja servidor > sesiones > ventanas > paneles. Nunca arranca un servidor | `TMUX_SOCKET=lab bin/kit-tree` |
| `bin/kit-layout` | Crea la ventana `trabajo` (editor a la izquierda, shell y logs a la derecha) y guarda o carga layouts | `bin/kit-layout new api ~/src/api` |
| `bin/sesiones` | Lista las sesiones (la más reciente primero, `*` en la actual) y salta entre ellas, dentro o fuera de tmux | `bin/sesiones ir api` |
| `bin/kit-copiar` | Copia stdin a tu portapapeles: herramienta del sistema en local, OSC 52 por SSH. Sale con 1 si falta la herramienta, 2 si recibe argumentos | `printf año \| bin/kit-copiar` |

Todos respetan `TMUX_BIN` (qué binario de tmux usar), y los que hablan con un
servidor respetan `TMUX_SOCKET` (qué servidor, como `tmux -L`).

Para guardar un layout que te guste y recuperarlo después:

```bash
bin/kit-layout save api:trabajo ~/.config/tmux/layouts/api.layout
bin/kit-layout load api:trabajo ~/.config/tmux/layouts/api.layout
```

## Instalación

`tmux.conf` busca `bin/` a su lado, así que se enlaza el directorio entero:

```bash
ln -s ~/tmux-kit ~/.config/tmux
```

Copy mode usa teclas de vim: `v` selecciona, `C-v` hace un rectángulo e `y`
copia al portapapeles con `bin/kit-copiar` (también al soltar el ratón). En
WSL, instala `win32yank.exe` para que la ñ llegue bien; por SSH, tu terminal
tiene que soportar OSC 52.

## Bitácora

| Semana | Qué añadí |
|---|---|
| 01 | Repositorio, `bin/check-version` y `bin/kit-tree` |
| 02 | `bin/kit-layout`: ventana de trabajo de tres paneles y layouts guardados |
| 03 | `bin/sesiones`: listar, saltar, crear y agrupar sesiones |
| 04 | Primer `tmux.conf` (copy mode vi, historial, OSC 52) y `bin/kit-copiar` |
