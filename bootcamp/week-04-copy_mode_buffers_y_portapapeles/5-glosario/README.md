# Glosario — Semana 04

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **copy mode** | Modo de un panel para recorrer, buscar y copiar su historial | `prefix` `[` |
| **mode-keys** | Opción de ventana que elige teclas de vi o emacs en copy mode | `setw -g mode-keys vi` |
| **history-limit** | Líneas de historial que guarda cada panel, fijadas al crearlo | `set -g history-limit 50000` |
| **copy-mode-vi** | Tabla de teclas de copy mode con `mode-keys vi` | `bind -T copy-mode-vi v send -X begin-selection` |
| **send -X** | Envía una orden del modo (no un comando de tmux) al panel en copy mode | `send -X copy-pipe-and-cancel` |
| **buffer** | Texto copiado que guarda el servidor, en una pila | `buffer0: 4 bytes: "hola"` |
| **buffer-limit** | Máximo de buffers automáticos; los viejos se borran, los con nombre no | `set -s buffer-limit 50` |
| **bracketed paste** | Marca que envuelve el texto pegado para que la shell no lo ejecute al llegar | `paste-buffer -p` |
| **capture-pane** | Vuelca lo que muestra un panel, o su historial, sin entrar en copy mode | `capture-pane -p -J -S -` |
| **copy-command** | Comando que recibe la selección cuando `copy-pipe` no lleva uno | `set -s copy-command 'wl-copy'` |
| **PRIMARY / CLIPBOARD** | Las dos selecciones de X11: botón central y `Ctrl+V` | `xclip -selection clipboard` |
| **OSC 52** | Secuencia de escape que pide a la terminal copiar un texto en base64 | `\033]52;c;aG9sYQ==\a` |
| **set-clipboard** | Opción que decide si tmux envía OSC 52 y si acepta el de los programas | `set -s set-clipboard on` |
| **Ms** | Capacidad de terminfo con la receta de OSC 52; sin ella tmux no lo envía | `show-messages -T \| grep ' Ms:'` |
| **load-buffer -w** | Crea un buffer y lo envía a la terminal exterior con OSC 52 | `printf hola \| tmux load-buffer -w -` |
