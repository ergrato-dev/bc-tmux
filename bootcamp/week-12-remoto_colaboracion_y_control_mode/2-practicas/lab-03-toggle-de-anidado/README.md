# Lab 03 — Toggle de anidado

⏱ Duración estimada: ~60 min

## Objetivo

Apagar y encender con `F12` el tmux de fuera para que el de dentro reciba todas las teclas, con un aviso en la barra, y probarlo sin teclado con `send-keys -K`.

## Contexto

- El prefix doble del lab 02 funciona, pero cada orden al de dentro cuesta una tecla más y un `prefix` `d` despistado desconecta al de fuera. El toggle deja al de fuera mudo hasta que vuelves a pulsar `F12`.
- Apagar es cambiar dos opciones **de la sesión**: `prefix` a `None` y `key-table` a una tabla propia, `off`, que solo conoce `F12`. Encender es `set -u`: la sesión vuelve a heredar el global.
- `send-keys -K -c CLIENTE` pulsa teclas como si las escribiera ese cliente. Solo dispara bindings: una tecla sin binding no llega al panel por este camino.

## Instrucciones

0. **Dónde.** Terminal A dentro del laboratorio (`docker compose exec lab bash`),
   fuera de tmux (`echo "$TMUX"` vacío). El paso 6 usa además `sshd` y la
   clave del [lab 01](../lab-01-ssh-y-sesion-persistente/README.md), paso 0:
   ```bash
   cd /bc-tmux/bootcamp/week-12-remoto_colaboracion_y_control_mode/2-practicas/lab-03-toggle-de-anidado
   tmux -L fuera -f "$PWD/starter/tmux.conf" new -d -s fuera; echo $?
   tmux -L fuera list-keys -T root F12; echo $?
   ```
   ```
   0
   unknown key: F12
   1
   ```
   El starter no cambia el prefix: es `C-b`.

1. **Un cliente para pulsar teclas.** Las teclas las procesa un cliente, y
   aquí no hay ninguno conectado. Un cliente de control mode (lo verás en
   el lab 05) no necesita pantalla: `sleep 600` le mantiene la entrada
   abierta diez minutos. Guarda su nombre en `c`:
   ```bash
   ( sleep 600 | tmux -L fuera -C attach -t fuera ) >/dev/null 2>&1 &
   sleep 0.5
   c=$(tmux -L fuera list-clients -F '#{client_name}'); echo "$c"
   ```
   Algo como (cambia el número; bash imprime además `[1] PID`):
   ```
   client-1112
   ```

2. **TODO 1 — apagar.** En `starter/tmux.conf`, `bind -n F12` con los dos
   `set` sin `-g`. Recarga y pulsa `F12` dos veces:
   ```bash
   tmux -L fuera source-file "$PWD/starter/tmux.conf"
   tmux -L fuera list-keys -T root F12
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera show -v prefix
   tmux -L fuera show -v key-table
   tmux -L fuera show -gv prefix
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera show -v key-table
   tmux -L fuera list-keys -T off; echo $?
   ```
   ```
   bind-key -T root F12 set-option prefix None \; set-option key-table off
   None
   off
   C-b
   off
   0
   ```
   Apagado en la sesión y el global intacto. Pero el segundo `F12` no hizo
   nada: la sesión mira ahora la tabla `off`, que está vacía (`list-keys`
   no imprime nada y sale con 0). Con un cliente real te quedarías sin
   teclas. Rescate desde la terminal A:
   ```bash
   tmux -L fuera set -u -t fuera prefix \; set -u -t fuera key-table; echo $?
   ```
   ```
   0
   ```

3. **TODO 2 — encender.** `bind -T off F12` con `set -u prefix` y
   `set -u key-table`, separados por `\;`. Recarga y haz el ciclo completo:
   ```bash
   tmux -L fuera source-file "$PWD/starter/tmux.conf"
   tmux -L fuera list-keys -T off
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera send-keys -K -c "$c" C-b
   tmux -L fuera display -p -c "$c" 'tabla=#{client_key_table} prefix=#{client_prefix}'
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera show -v prefix; echo $?
   tmux -L fuera show -v key-table
   ```
   ```
   bind-key -T off F12 set-option -u prefix \; set-option -u key-table
   tabla=off prefix=0
   0
   ```
   Apagado, `C-b` no activa el prefix (`client_prefix` sigue en 0). Tras el
   segundo `F12`, la sesión ya no tiene valor propio: `show -v` sin salida
   y con 0. Hereda otra vez el global, sea `C-b` o el que pongas mañana.

4. **TODO 3 — el aviso.** Cambia la línea `set -g status-right` por la del
   TODO 3. `#{T:status-right}` expande el format como lo pinta la barra:
   ```bash
   tmux -L fuera source-file "$PWD/starter/tmux.conf"
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera display -p '#{T:status-right}'
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera display -p '#{T:status-right}'
   ```
   Algo como (cambia la hora):
   ```
   #[bg=#e3b341] OFF #[default] 21:50
   21:50
   ```
   `#{key-table}` lee la opción de la sesión: funciona sin cliente, al
   contrario que `#{client_key_table}`.

5. **Solo esta sesión.** Crea otra sesión en el mismo servidor y apaga
   `fuera`:
   ```bash
   tmux -L fuera new -d -s otra
   tmux -L fuera send-keys -K -c "$c" F12
   tmux -L fuera display -p -t otra: 'otra=#{key-table}'
   tmux -L fuera display -p -t fuera: 'fuera=#{key-table}'
   tmux -L fuera kill-server
   ```
   ```
   otra=root
   fuera=off
   ```
   Con `set -g` habrías apagado todas. `kill-server` cierra también el
   cliente de control mode del paso 1.

6. **Con un tmux dentro (terminal B).** Arranca el de fuera con un panel
   que entra por SSH en otro tmux, sin config (prefix `C-b` también):
   ```bash
   tmux -L fuera -f "$PWD/starter/tmux.conf" new -d -s fuera "ssh -t localhost tmux -L dentro -f /dev/null new -A -s dentro"
   n() { echo "fuera=$(tmux -L fuera list-windows | wc -l) dentro=$(tmux -L dentro list-windows | wc -l)"; }
   ```
   ```
   (sin salida)
   ```
   Abre otra terminal en tu equipo (`docker compose exec lab bash`), la
   **terminal B**, y conéctate:
   ```bash
   tmux -L fuera attach -t fuera
   ```
   Pulsa `F12`: la barra verde de arriba muestra ` OFF ` en amarillo.
   Pulsa `C-b` `c` (una sola vez) y después `F12` otra vez. En A:
   ```bash
   n
   ```
   ```
   fuera=1 dentro=2
   ```
   Con el de fuera apagado, `C-b` `c` llegó entero al de dentro. Ojo:
   apagado, `C-b` `d` también le llega al de dentro y lo desconecta (se
   cierra el SSH y el panel). Para salir, primero `F12` y después `C-b`
   `d`:
   ```
   [detached (from session fuera)]
   ```

7. **Limpia** (terminal A):
   ```bash
   tmux -L fuera kill-server; sleep 0.5
   tmux -L dentro kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `tmux -L fuera list-keys -T root F12` muestra `set-option prefix None \; set-option key-table off` (paso 2)
- [ ] Explicas por qué con solo el TODO 1 el segundo `F12` no hace nada (paso 2)
- [ ] Tras el ciclo `F12` `F12`, `tmux -L fuera show -v key-table` no imprime nada (paso 3)
- [ ] Con la sesión apagada, `#{T:status-right}` empieza por `#[bg=#e3b341] OFF` (paso 4)
- [ ] `otra=root` y `fuera=off` a la vez (paso 5)
- [ ] Con `F12` pulsado, `C-b` `c` crea la ventana en el de dentro: `fuera=1 dentro=2` (paso 6)

## Reto extra

Haz que, apagado, también cambie el color de la barra entera (por ejemplo
`status-style` a gris) y que `F12` lo devuelva con `set -u`. ¿Por qué
`set -u` es mejor aquí que volver a escribir el color original? Pista:
qué pasa si mañana cambias el color en la config.

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Lab 02 — tmux anidado](../lab-02-tmux-anidado/README.md) | [Lab 04 — Socket compartido](../lab-04-socket-compartido/README.md) → |

[↑ Semana 12](../../README.md)
