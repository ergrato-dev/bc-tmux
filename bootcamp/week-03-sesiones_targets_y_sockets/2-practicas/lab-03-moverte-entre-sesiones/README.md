# Lab 03 — Moverte entre sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Saltar entre sesiones con teclas, con filtros y con `switch-client`, y saber qué comando usar según estés dentro o fuera de tmux.

## Contexto

- Un **cliente** está conectado a una sesión, pero no para siempre: `switch-client` lo cambia a otra sin desconectarlo. Es lo que hacen `prefix` `(`, `)`, `L` y elegir en `choose-tree`.
- `attach-session` conecta un cliente **nuevo**. Dentro de tmux eso anidaría un cliente dentro de un panel, y tmux lo rechaza.
- `detach-on-destroy` decide qué pasa con tu cliente cuando su sesión se cierra: desconectarse (por defecto) o pasar a otra.

## Instrucciones

1. Crea tres sesiones y conéctate a la primera:
   ```bash
   tmux -L lab new -d -s web \; new -d -s notas \; new -d -s infra
   tmux -L lab attach -t =web
   ```

2. Salta entre ellas:

   | Teclas | Comando | Qué hace |
   |---|---|---|
   | `prefix` `(` / `)` | `switch-client -p` / `-n` | Sesión anterior / siguiente |
   | `prefix` `L` | `switch-client -l` | Última sesión en la que estuviste |
   | `prefix` `s` | `choose-tree -Zs` | Árbol de sesiones |
   | `prefix` `D` | `choose-client -Z` | Elegir qué cliente desconectar |

   `prefix` `L` es el que más usarás: alterna entre dos sesiones como `;`
   alterna entre dos paneles.

3. **Filtrar el árbol.** Con muchas sesiones, el árbol se queda largo. Desde el
   prompt (`prefix` `:`):
   ```
   choose-tree -Zs -f '#{m:*n*,#{session_name}}'
   ```
   Solo aparecen las que contienen una `n`. Dentro del árbol, `f` cambia el
   filtro y `O` el orden (`time` = actividad).

4. **Cerrar la sesión en la que estás.** En `infra`, ejecuta en el prompt
   `kill-session`. El cliente se desconecta, aunque quedan otras sesiones.
   Conéctate otra vez (`tmux -L lab attach -t =web`) y prueba con:
   ```
   set -g detach-on-destroy off
   ```
   Ahora `kill-session` en `notas` te pasa a la sesión usada más recientemente.
   Es una de las primeras opciones que pondrás en tu configuración (semana 05).

5. **Dentro de tmux, `switch-client`.** En un panel de `web`, intenta:
   ```bash
   tmux -L lab attach -t =notas
   # sessions should be nested with care, unset $TMUX to force
   tmux -L lab switch-client -t =notas
   ```
   El segundo mueve tu cliente a `notas`. `switch-client` sin `-c` mueve el
   cliente que está mirando el panel desde el que lo ejecutas.

6. Completa `starter/saltar.sh`: recibe un nombre de sesión y te lleva a ella
   con el comando correcto según estés dentro (`$TMUX` no vacío) o fuera de
   tmux. Si la sesión no existe, lo dice y sale con 1.
   ```bash
   ./starter/saltar.sh notas          # fuera de tmux: te conecta
   # dentro de web, en un panel:
   ./starter/saltar.sh notas          # te cambia de sesión, sin anidar
   ./starter/saltar.sh nada; echo $?  # no existe la sesión 'nada'  1
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Alternas entre dos sesiones con `prefix` `L`
- [ ] Filtraste el árbol con `-f` y cambiaste el orden con `O`
- [ ] Explicas la diferencia entre `detach-on-destroy on` y `off` con lo que pasó en el paso 4
- [ ] `saltar.sh` funciona dentro y fuera de tmux, y sale con 1 si la sesión no existe

## Reto extra

Con dos clientes conectados (dos terminales), usa `switch-client -c` para
mover el **otro** cliente a una sesión. Saca su nombre de
`tmux -L lab list-clients -F '#{client_name} #{session_name}'`.
