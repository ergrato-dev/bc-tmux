# Glosario — Semana 07

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **format** | Texto con `#{...}` que tmux expande con datos del servidor, la sesión, la ventana, el panel o el cliente | `display -p '#{session_name}'` |
| **variable de format** | Nombre que tmux resuelve dentro de `#{}`; si no existe, se expande a vacío sin error | `#{window_zoomed_flag}` |
| **condicional** | `#{?cond,sí,no}`: elige una rama según que la condición sea no vacía y distinta de `0` | `#{?client_prefix,P,-}` |
| **comparación** | Operador que devuelve `1` o `0`; `==`, `<` y `>` comparan texto | `#{==:#{window_name},editor}` |
| **modificador** | Prefijo que transforma un valor: recorta, rellena, sustituye, cita o expande | `#{=20:session_name}` |
| **expresión `e\|`** | Aritmética y comparación numérica dentro de un format | `#{e\|<\|:10,9}` |
| **bucle** | `W:`, `S:` y `P:` repiten un format por ventana, sesión o panel | `#{W:#{window_name} }` |
| **escape** | `##`, `#,` y `#}` producen `#`, coma y llave literales dentro de un format | `#{?@x,a#,b,c}` |
| **estilo** | `#[...]` cambia color y atributos desde ese punto del texto de la barra | `#[fg=red,bold]` |
| **opción `*-style`** | Opción que fija el estilo de una zona; acepta formats y se evalúa al dibujar | `set -g status-style 'bg=#{@kit-color-bg}'` |
| **status-left / status-right** | Contenido de los extremos de la barra, cortado por su `*-length` | `set -g status-left-length 30` |
| **window-status-format** | Cómo se dibuja cada ventana de la lista; la actual usa `window-status-current-format` | `set -g window-status-format ' #I:#W '` |
| **`#(comando)`** | Inserta la primera línea de la salida de un comando lanzado en segundo plano | `#(date +%%S)` |
| **status-interval** | Segundos entre redibujos de la barra y relanzamientos de los `#()` | `set -g status-interval 5` |
| **status-format** | Array con el contenido completo de cada línea de la barra; `status 2` activa la segunda | `set -g 'status-format[1]' '#{session_name}'` |
