# Glosario — Semana 06

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **binding** | Asociación de una tecla de una tabla con uno o varios comandos de tmux | `bind r source-file -F "#{@kit-dir}/tmux.conf"` |
| **tabla de teclas** | Conjunto de bindings con nombre; el cliente busca cada tecla solo en su tabla activa | `list-keys -T prefix` |
| **root** | Tabla activa por defecto: lo que está aquí funciona sin prefix y ya no llega al programa | `bind -n M-Left select-pane -L` |
| **tabla prefix** | Tabla de la tecla que sigue al prefix; es la que usa `bind` sin `-T` | `bind \| split-window -h` |
| **copy-mode-vi** | Tabla activa en copy mode con `mode-keys vi`; sus comandos se envían con `send -X` | `bind -T copy-mode-vi v send -X begin-selection` |
| **tabla propia** | Tabla con el nombre que elijas, a la que se entra con `switch-client -T` | `bind -T resize h resize-pane -L 5` |
| **client_key_table** | Format con la tabla en la que está el cliente ahora mismo | `display -p '#{client_key_table}'` |
| **repeat-time** | Milisegundos en los que una tecla con `-r` se repite sin pulsar otra vez el prefix | `set -g repeat-time 500` |
| **nota de tecla** | Texto de `bind -N` que muestran `list-keys -N` y `prefix` `?` | `bind -N "kit: recargar config" r ...` |
| **bloque de comandos** | `{ }` agrupa varios comandos en un binding sin escapar `\;` | `bind -T resize h { resize-pane -L 5; switch-client -T resize }` |
| **if -F** | Elige entre dos comandos según un format, sin lanzar una shell | `if -F '#{window_zoomed_flag}' 'display zoom' ''` |
| **pantalla alternativa** | Pantalla que piden los programas a pantalla completa; al salir vuelve lo que había antes | `less`, `watch` (no `top` de procps) |
| **alternate_on** | Format que vale 1 cuando el panel está en la pantalla alternativa | `if -F '#{alternate_on}' 'send-keys C-h' 'select-pane -L'` |
| **send-keys** | Envía teclas al programa del panel en lugar de interpretarlas tmux | `bind C-l send-keys C-l` |
