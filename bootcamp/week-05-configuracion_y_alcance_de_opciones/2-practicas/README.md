# Labs — Semana 05: Configuración y alcance de opciones

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-donde-vive-la-config](lab-01-donde-vive-la-config/) | Saber qué archivos carga tmux y cuándo, encontrar errores sin conectarte e instalar tu config sin pisar nada | ~60 min |
| 2 | [lab-02-prefix-propio](lab-02-prefix-propio/) | Elegir un prefix con criterio, liberar `C-b` y mantener `send-prefix` | ~60 min |
| 3 | [lab-03-alcances-y-herencia](lab-03-alcances-y-herencia/) | Fijar opciones en servidor, sesión, ventana y panel, y averiguar de qué nivel sale un valor | ~60 min |
| 4 | [lab-04-recarga-en-caliente](lab-04-recarga-en-caliente/) | Recargar con una tecla y escribir una config que da lo mismo tras diez recargas | ~60 min |
| 5 | [lab-05-config-modular](lab-05-config-modular/) | Dividir la config en `conf.d/` con orden, rutas absolutas y `local.conf` | ~60 min |
| 6 | [lab-06-config-rota](lab-06-config-rota/) | Depurar una config modular que solo funciona en el repo de su autor (4 errores reales) | ~60 min |

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
   no se toca. Arranca con ruta absoluta, `-f "$PWD/starter/tmux.conf"`:
   varias configs de esta semana guardan su propio directorio y lo necesitan
   absoluto.
4. **Conectarte y salir.** En la terminal B, `tmux -L lab attach`. Para
   salir sin cerrar nada, pulsa el prefix **de ese servidor** y `d`
   (cada lab dice cuál es: `C-b` si arranca con `-f /dev/null` o con un
   starter que no fija otro). La terminal B imprime
   `[detached (from session NOMBRE)]`.
5. **Al terminar cada lab:** `tmux -L lab kill-server` en la terminal A. Si
   la B seguía conectada, imprime `[server exited]`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — Alcances de las opciones](../1-teoria/02-alcances-de-opciones.md) | [Lab 01 — Dónde vive la config](lab-01-donde-vive-la-config/README.md) → |

[↑ Semana 05](../README.md)
