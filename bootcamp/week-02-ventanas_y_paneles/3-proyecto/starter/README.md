# tmux-kit

Mi kit personal de tmux: scripts y, más adelante, configuración que uso a
diario en Ubuntu 24.04 (WSL2). Crece una semana a la vez durante el bootcamp.

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
| `bin/kit-layout` | <!-- TODO --> | <!-- TODO --> |

Todos respetan `TMUX_BIN` (qué binario de tmux usar), y los que hablan con un
servidor respetan `TMUX_SOCKET` (qué servidor, como `tmux -L`).

## Bitácora

| Semana | Qué añadí |
|---|---|
| 01 | Repositorio, `bin/check-version` y `bin/kit-tree` |
| 02 | <!-- TODO --> |
