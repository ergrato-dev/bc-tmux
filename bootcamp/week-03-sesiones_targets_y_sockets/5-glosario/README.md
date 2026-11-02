# Glosario — Semana 03

| Término | Definición en una línea | Ejemplo |
|---------|------------------------|---------|
| **target** | Lo que va tras `-t`: la sesión, ventana o panel sobre el que actúa un comando | `-t api:logs.1` |
| **coincidencia exacta** | Target con `=` delante: solo vale el nombre tal cual, sin prefijos ni patrones | `has-session -t =api` |
| **coincidencia por prefijo** | Si el nombre no existe, tmux acepta la única sesión que empieza igual | `-t api` encuentra `api-vieja` |
| **choose-tree** | Vista en árbol de sesiones, ventanas y paneles para saltar, cerrar o marcar | `prefix` `s` |
| **switch-client** | Cambia de sesión un cliente ya conectado | `switch-client -t =web` |
| **última sesión** | La sesión en la que estuvo el cliente antes de la actual | `prefix` `L` |
| **detach-on-destroy** | Opción que decide si el cliente se desconecta o cambia de sesión cuando la suya se cierra | `set -g detach-on-destroy off` |
| **grupo de sesiones** | Sesiones que comparten ventanas pero tienen cada una su ventana actual | `new-session -d -t api -s api-2` |
| **socket con nombre** | Socket en el directorio por defecto de tmux, elegido por nombre | `tmux -L lab` |
| **socket con ruta** | Socket en una ruta exacta del sistema de archivos | `tmux -S /tmp/par.sock` |
| **TMUX_TMPDIR** | Variable que cambia el directorio base donde tmux crea los sockets | `TMUX_TMPDIR=/run/user/1000` |
| **$TMUX** | Variable de cada panel con el socket, el pid del servidor y la sesión | `/tmp/tmux-1000/lab,1234,0` |
| **$TMUX_PANE** | Variable de cada panel con su id | `%3` |
| **SIGUSR1** | Señal que pide al servidor recrear su socket si lo borraron | `kill -USR1 "$pid"` |
