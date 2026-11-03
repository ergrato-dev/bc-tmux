# Labs — Semana 07: Formats y status line

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-formats-y-display](lab-01-formats-y-display/) | Leer el estado de tmux con `#{...}`, `display -p` y `list-* -F` | ~60 min |
| 2 | [lab-02-condicionales-y-comparaciones](lab-02-condicionales-y-comparaciones/) | Indicadores que solo aparecen cuando toca: `#{?...}`, `==`, `m:`, `e\|>=\|`, `#,` | ~60 min |
| 3 | [lab-03-modificadores](lab-03-modificadores/) | Recortar, rellenar, sustituir, fechas, `q:`, `E:` y aritmética | ~60 min |
| 4 | [lab-04-estilos-y-ventanas](lab-04-estilos-y-ventanas/) | Colores con `*-style` y `#[...]`, lista de ventanas y bucle `W:` | ~60 min |
| 5 | [lab-05-comandos-y-varias-lineas](lab-05-comandos-y-varias-lineas/) | Rama git con `#(...)` y un script propio, `status-interval` y `status 2` | ~60 min |
| 6 | [lab-06-status-rota](lab-06-status-rota/) | Depurar una status line con cinco errores (rota a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Dos terminales fuera de tmux.** Todos los labs usan una
   **terminal A** para los comandos y una **terminal B** para conectarte al
   servidor del lab y **mirar la barra**. Ninguna de las dos puede estar
   dentro de tmux: `echo "$TMUX"` no imprime nada en ellas.
   - En tu equipo: dos pestañas o ventanas de tu terminal.
   - En el laboratorio Docker, desde la raíz del repositorio:
     ```bash
     docker compose up -d lab        # una sola vez
     docker compose exec lab bash    # en la terminal A y otra vez en la B
     ```
     Dentro del contenedor ya estás en la raíz del repositorio (`/bc-tmux`).
     Al terminar la semana: `docker compose down`.
2. **La carpeta del lab.** En las dos terminales, desde la raíz del
   repositorio, `cd` a la carpeta del lab (el paso 0 de cada lab da la ruta).
   Todos los comandos se escriben desde ahí.
3. **Un servidor aparte.** Todo va contra `tmux -L lab`: tu tmux de siempre
   no se toca. Arranca con ruta absoluta, `-f "$PWD/starter/tmux.conf"`, y
   después de cada TODO recarga con
   `tmux -L lab source-file "$PWD/starter/tmux.conf"`.
4. **Probar un format sin mirar la barra.** `tmux -L lab display -p 'FORMAT'`
   lo imprime expandido, y `tmux -L lab display -p '#{E:status-right}'`
   enseña lo que dibujaría una opción. Dos límites: `display -p` imprime los
   estilos `#[...]` como texto y **nunca** ejecuta `#(...)`. Para eso está
   la B.
5. **Conectarte y salir.** En la terminal B, `tmux -L lab attach -t api`.
   Ningún lab cambia el prefix: es `C-b`. Para salir sin cerrar nada,
   `C-b` `d`; la B imprime `[detached (from session api)]`.
6. **Al terminar cada lab:** quita cualquier zoom
   (`tmux -L lab resize-pane -Z` si `#{window_zoomed_flag}` vale `1`: tmux
   3.4 puede fallar al cerrarse con una ventana ampliada) y
   `tmux -L lab kill-server` en la terminal A. Si la B seguía conectada,
   imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
