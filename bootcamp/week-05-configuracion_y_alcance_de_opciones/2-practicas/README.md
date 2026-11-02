# Labs — Semana 05: Configuración y alcance de opciones

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-donde-vive-la-config](lab-01-donde-vive-la-config/) | Saber qué archivos carga tmux y cuándo, encontrar errores sin conectarte e instalar tu config sin pisar nada | ~60 min |
| 2 | [lab-02-prefix-propio](lab-02-prefix-propio/) | Elegir un prefix con criterio, liberar `C-b` y mantener `send-prefix` | ~60 min |
| 3 | [lab-03-alcances-y-herencia](lab-03-alcances-y-herencia/) | Fijar opciones en servidor, sesión, ventana y panel, y averiguar de qué nivel sale un valor | ~60 min |
| 4 | [lab-04-recarga-en-caliente](lab-04-recarga-en-caliente/) | Recargar con `prefix` `r` y escribir una config que da lo mismo tras diez recargas | ~60 min |
| 5 | [lab-05-config-modular](lab-05-config-modular/) | Dividir la config en `conf.d/` con orden, rutas absolutas y `local.conf` | ~60 min |
| 6 | [lab-06-config-rota](lab-06-config-rota/) | Depurar una config modular que solo funciona en el repo de su autor (4 errores reales) | ~60 min |

**Total labs: 6 horas**

Todo va contra un servidor aparte: `tmux -L lab`. Arranca siempre con ruta
absoluta, `tmux -L lab -f "$PWD/starter/tmux.conf"`: varias configs de esta
semana guardan su propio directorio y lo necesitan absoluto. En el
laboratorio, para varias terminales: `docker compose up -d lab` y
`docker compose exec lab bash` en cada una. Al terminar cada lab:
`tmux -L lab kill-server`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).
