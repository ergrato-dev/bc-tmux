# Contexto — El prefix y los comandos

## ¿Por qué importa esto?

Dentro de tmux, casi todas las teclas son para el programa del panel: tu shell, tu editor. tmux necesita una forma de saber cuándo le hablas a **él**. Esa forma es el **prefix**. Y detrás de cada atajo hay un comando con nombre, el mismo que escribirás en tus scripts. Si aprendes los comandos y no solo las teclas, puedes automatizar todo lo que haces a mano.

## El prefix

El prefix por defecto es `C-b` (**Ctrl+b**). Se pulsa, se suelta y después se pulsa la tecla del atajo. En este bootcamp se escribe así: `prefix` `d`.

En la semana 05 lo cambiarás por el que prefieras. Hasta entonces, todo usa `C-b`.

## Referencia rápida

| Atajo | Comando | Qué hace |
|---|---|---|
| `prefix` `d` | `detach-client` | Desconecta este cliente; la sesión sigue |
| `prefix` `D` | `choose-client` | Elige un cliente para desconectarlo |
| `prefix` `c` | `new-window` | Ventana nueva |
| `prefix` `,` | `rename-window` | Renombra la ventana |
| `prefix` `n` / `p` | `next-window` / `previous-window` | Ventana siguiente / anterior |
| `prefix` `0`…`9` | `select-window -t :=N` | Salta a la ventana N |
| `prefix` `%` | `split-window -h` | Divide en dos paneles lado a lado |
| `prefix` `"` | `split-window` | Divide en dos paneles uno encima del otro |
| `prefix` flechas / `o` | `select-pane` | Cambia de panel |
| `prefix` `x` | `kill-pane` | Cierra el panel (pide confirmación) |
| `prefix` `w` | `choose-tree -Zw` | Árbol de sesiones y ventanas |
| `prefix` `?` | `list-keys -N` | Lista de atajos con descripción |
| `prefix` `:` | `command-prompt` | Prompt para escribir cualquier comando |

## Tres caminos al mismo comando

```bash
# 1. Con el teclado, dentro de tmux:   prefix c
# 2. En el prompt de tmux:             prefix :  y escribes  new-window
# 3. Desde cualquier shell:
tmux new-window
```

Los tres hacen lo mismo. El tercero es el que usan los scripts: funciona desde fuera de tmux, desde `cron` o desde otro programa. Si lo ejecutas dentro de tmux sin `-t`, actúa sobre la sesión actual; desde fuera, sobre la sesión más reciente. Con `-t` eliges el objetivo: `-t api` para una sesión, `-t api:logs` para una ventana.

## Preguntarle a tmux

tmux te responde qué sabe con comandos que no cambian nada:

```bash
tmux list-keys -T prefix d                      # qué hace prefix d
tmux ls                                         # sesiones (list-sessions)
tmux list-clients                               # quién está conectado
tmux display-message -p '#{session_name}'       # una variable de formato
```

Las palabras entre `#{ }` son **formats**: variables que tmux rellena con el estado del objeto (`#{session_windows}`, `#{pane_id}`, `#{socket_path}`). Esta semana usarás unas pocas; en la semana 07 los verás a fondo.

## Ojo: comandos que arrancan un servidor

`new-session` arranca el servidor si no existe. `list-sessions`, `list-keys` y `display-message` solo preguntan: si no hay servidor fallan con `no server running` y **no crean ninguno**. Un script que solo quiere mirar debe usar estos.

---
Listo. Ve al [lab-01](../2-practicas/lab-01-primera-sesion/README.md) y ponlo en práctica.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Qué es tmux y cómo funciona por dentro](01-multiplexor-y-modelo-cliente-servidor.md) | [Índice de labs](../2-practicas/README.md) → |

[↑ Semana 01](../README.md)
