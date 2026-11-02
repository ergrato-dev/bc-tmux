# Glosario — Semana 01

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **multiplexor de terminal** | Programa que reparte una terminal en varias y las mantiene vivas aunque te desconectes | `tmux`, `screen` |
| **servidor** | Proceso de tmux en segundo plano que guarda las sesiones y es padre de sus programas | `tmux display -p '#{pid}'` |
| **cliente** | Una terminal conectada a una sesión; dibuja la sesión y envía tus teclas | `tmux list-clients` |
| **socket** | Archivo por el que clientes y comandos hablan con el servidor | `/tmp/tmux-1000/default` |
| **`-L` / `-S`** | Eligen el socket por nombre o por ruta, y con él el servidor | `tmux -L lab ls` |
| **sesión** | Conjunto de ventanas con nombre que sobrevive a los clientes | `tmux new -s api` |
| **ventana** | Pantalla completa dentro de una sesión, como una pestaña | `prefix c` |
| **panel** | Rectángulo de una ventana con su propio programa | `prefix %` |
| **id** | Identificador fijo de un objeto: `$` sesión, `@` ventana, `%` panel | `tmux kill-pane -t %3` |
| **target** | Dirección de un objeto en la forma `sesión:ventana.panel` | `tmux send-keys -t api:editor.1 ls Enter` |
| **detach / attach** | Desconectar un cliente sin cerrar la sesión / volver a conectarlo | `prefix d` / `tmux attach -t api` |
| **prefix** | Tecla que avisa a tmux de que la siguiente es para él (`C-b` por defecto) | `prefix ?` |
| **tabla de teclas** | Conjunto de atajos con nombre; `prefix` es una de ellas | `tmux list-keys -T prefix` |
| **format** | Variable entre `#{ }` que tmux rellena con el estado de un objeto | `#{session_windows}` |
| **`$TMUX`** | Variable de entorno que tmux pone en cada panel: socket, pid y sesión | `echo "$TMUX"` |
