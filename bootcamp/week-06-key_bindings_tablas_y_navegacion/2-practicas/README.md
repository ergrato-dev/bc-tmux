# Labs — Semana 06: Key bindings, tablas y navegación

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-bind-unbind-y-list-keys](lab-01-bind-unbind-y-list-keys/) | Crear, pisar, quitar y documentar teclas, y comprobarlas con `list-keys` | ~60 min |
| 2 | [lab-02-repeticion-y-tabla-root](lab-02-repeticion-y-tabla-root/) | Decidir qué teclas se repiten (`-r`) y cuáles van sin prefix (`-n`), y qué le robas a la shell | ~60 min |
| 3 | [lab-03-tablas-propias](lab-03-tablas-propias/) | Construir un modo resize con una tabla de teclas propia | ~60 min |
| 4 | [lab-04-copy-mode-a-medida](lab-04-copy-mode-a-medida/) | Cambiar teclas de `copy-mode-vi` y escribir bindings con `{}` e `if -F` | ~60 min |
| 5 | [lab-05-navegacion-consciente](lab-05-navegacion-consciente/) | Moverte con `C-h/j/k/l` sin prefix sin quitar esas teclas a `less` ni a tu editor | ~60 min |
| 6 | [lab-06-teclas-rotas](lab-06-teclas-rotas/) | Depurar una config con cinco errores de bindings (rota a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Dos terminales fuera de tmux.** Casi todos los labs usan una
   **terminal A** para los comandos y una **terminal B** para conectarte al
   servidor del lab. Ninguna de las dos puede estar dentro de tmux:
   `echo "$TMUX"` no imprime nada en ellas.
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
   `tmux -L lab source-file "$PWD/starter/tmux.conf"`. Recargar no quita las
   teclas que borraste del archivo: si dudas, reinicia el servidor del lab.
4. **Conectarte y salir.** En la terminal B, `tmux -L lab attach`. Para
   salir sin cerrar nada, pulsa el prefix **de ese servidor** y `d`
   (cada lab dice cuál es: `C-b` en los labs 01-05, que no lo cambian;
   `C-a` en el 06). La terminal B imprime
   `[detached (from session NOMBRE)]`.
5. **Comprobar sin pulsar.** `tmux -L lab list-keys -T TABLA TECLA` dice
   qué hace una tecla ahora mismo, y `tmux -L lab display -p
   '#{client_key_table}'` en qué tabla está tu cliente. Cada lab los usa para
   comprobar lo que pulsas en la B.
6. **Al terminar cada lab:** `tmux -L lab kill-server` en la terminal A. Si
   la B seguía conectada, imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
