# Contexto — Copy mode y buffers

## ¿Por qué importa esto?

Dentro de tmux, la rueda del ratón y `Shift+PgUp` de tu terminal ya no sirven: la terminal solo ve lo que tmux dibuja, no el historial de cada panel. El historial lo guarda tmux, y la única forma de recorrerlo, buscar en él y copiar es **copy mode**. Lo que copias no va al portapapeles del sistema sino a un **buffer** de tmux. Entender ese camino es lo que separa "en tmux no puedo copiar" de copiar con tres teclas, local o por SSH.

## Referencia rápida

| Atajo | Comando | Qué hace |
|---|---|---|
| `prefix` `[` | `copy-mode` | Entra en copy mode |
| `prefix` `PgUp` | `copy-mode -u` | Entra y sube una página |
| `prefix` `]` | `paste-buffer -p` | Pega el buffer más reciente |
| `prefix` `=` | `choose-buffer -Z` | Elige qué buffer pegar |
| `prefix` `#` | `list-buffers` | Lista los buffers |
| `prefix` `-` | `delete-buffer` | Borra el más reciente |

Dentro de copy mode, con `mode-keys vi`:

| Tecla | Acción | Tecla | Acción |
|---|---|---|---|
| `h` `j` `k` `l` | Mover el cursor | `/` `?` | Buscar hacia abajo / arriba |
| `w` `b` `e` | Palabra siguiente / anterior / fin | `n` `N` | Siguiente / anterior resultado |
| `0` `$` | Inicio / fin de línea | `g` `G` | Principio / final del historial |
| `C-u` `C-d` | Media página | `Space` | Empezar selección |
| `H` `M` `L` | Arriba / medio / abajo de la pantalla | `Enter` | Copiar y salir |
| `o` | Saltar al otro extremo de la selección | `q` | Salir sin copiar |

## vi o emacs

`mode-keys` es una opción de **ventana**. Si no la fijas, tmux la deduce al arrancar: `vi` si `$VISUAL` o `$EDITOR` contienen "vi", `emacs` si no. Por eso la misma config funciona con `vi` en tu máquina y con `emacs` en un servidor sin `EDITOR`. Fíjala siempre:

```tmux
setw -g mode-keys vi
```

Las teclas de copy mode viven en su propia tabla, `copy-mode-vi` (o `copy-mode`), y llevan `-X` porque son órdenes del modo, no comandos de tmux:

```tmux
bind -T copy-mode-vi v send -X begin-selection     # por defecto, v es rectangle-toggle
bind -T copy-mode-vi y send -X copy-pipe-and-cancel
```

## El historial

Cada panel guarda hasta `history-limit` líneas (por defecto 2000). El límite se lee **al crear el panel**: cambiarlo no amplía los paneles que ya existen.

```tmux
set -g history-limit 50000
```

`clear-history` vacía el historial de un panel, y `capture-pane -p` lo vuelca a stdout sin entrar en copy mode: `-S -` desde el principio, `-J` une las líneas que la pantalla partió, `-e` conserva los colores.

## Buffers

Cada copia crea un buffer nuevo (`buffer0`, `buffer1`...) encima de una pila de hasta `buffer-limit` (50). `paste-buffer` pega el de arriba. Los buffers con nombre (`set-buffer -b notas`) no cuentan para el límite ni se borran solos.

```bash
tmux -L demo new -d
tmux -L demo set-buffer -b saludo 'hola desde un buffer'
tmux -L demo list-buffers               # saludo: 20 bytes: "hola desde un buffer"
tmux -L demo show-buffer -b saludo
tmux -L demo save-buffer -b saludo /tmp/saludo.txt
tmux -L demo kill-server
```

`paste-buffer -p` envuelve el texto en *bracketed paste*: la shell o el editor lo reciben como texto pegado y no ejecutan cada línea al llegar el salto.

## Qué observar

- `tmux -L demo -f /dev/null new -d \; show -gwv mode-keys` cambia con `EDITOR=vi` o `EDITOR=nano` delante.
- Con `history-limit` bajo, `seq 1 5000` y `g` en copy mode no llega a la línea 1.
- Copiar dos veces deja dos buffers; `prefix` `]` pega el último.

Del buffer al portapapeles del sistema hay un paso más: [02-portapapeles-y-osc52.md](02-portapapeles-y-osc52.md).

---
Listo. Ve al [lab-01](../2-practicas/lab-01-moverte-por-el-historial/README.md) y ponlo en práctica.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Semana 04 — Copy mode, buffers y portapapeles](../README.md) | [Teoría — Contexto — Portapapeles y OSC 52](02-portapapeles-y-osc52.md) → |

[↑ Semana 04](../README.md)
