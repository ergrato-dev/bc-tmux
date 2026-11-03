# Videografía — Semana 08

| Título | Canal | Duración | Enlace |
|--------|-------|----------|--------|
| Solución Tmux Color Blanco en Linux (Mint, Ubuntu, +) | Rafael Nontol (español) | 3 min | https://www.youtube.com/watch?v=zyvq8fKCuvw |
| Clearing tmux terminal throws error: "'tmux-256color': unknown terminal type." | Roel Van de Paar (inglés) | 2 min | https://www.youtube.com/watch?v=LiYAMzTbcIU |
| Cannot enable TrueColor support in tmux via overriding terminfo | Roel Van de Paar (inglés) | 2 min | https://www.youtube.com/watch?v=Os7F11SFyBs |
| tmux 256-color output on 256-color terminal, 8-color output on 8-color terminal | Roel Van de Paar (inglés) | 3 min | https://www.youtube.com/watch?v=9FwVydhr22k |
| My Terminal Workflow with Ghostty and Tmux (Full Setup Guide) | Happy Coder (inglés) | 7 min | https://www.youtube.com/watch?v=ZIWXWWcx-Mk |

Míralos con ojo crítico: el de Rafael Nontol arregla los colores con
`default-terminal screen-256color` en `~/.tmux.conf`. Funciona, pero en esta
semana el TERM de dentro es `tmux-256color` y el color de 24 bits se pide con
`terminal-features`. Los de Roel Van de Paar leen preguntas de Unix & Linux
Stack Exchange: sirven para ver síntomas reales y compararlos con lo que
diagnosticas tú con `show-messages -T`.
