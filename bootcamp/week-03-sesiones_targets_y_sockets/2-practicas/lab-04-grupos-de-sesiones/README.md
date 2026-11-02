# Lab 04 — Grupos de sesiones

⏱ Duración estimada: ~60 min

## Objetivo

Crear dos sesiones que comparten ventanas pero tienen cada una su ventana actual, y saber cuándo conviene frente a conectar dos clientes a la misma sesión.

## Contexto

- Dos clientes en la **misma sesión** ven siempre la misma ventana: si uno cambia, el otro también.
- Una sesión **agrupada** (`new-session -t BASE`) comparte las ventanas de `BASE`, pero tiene su propia ventana actual. Crear o cerrar una ventana afecta a todo el grupo.
- Sirve para tener la misma sesión en dos monitores mirando ventanas distintas, o para que dos personas trabajen en el mismo proyecto sin pelearse por la ventana activa.

## Instrucciones

1. **Dos clientes, una sesión.** En dos terminales:
   ```bash
   tmux -L lab new -s base -n codigo          # terminal 1
   tmux -L lab new-window -t base: -n logs    # desde cualquier otra
   tmux -L lab attach -t =base                # terminal 2
   ```
   En la terminal 2 pulsa `prefix` `0` y después `prefix` `1`: la terminal 1
   cambia a la vez. Desconecta la terminal 2 con `prefix` `d`.

2. **Un grupo.** Crea una sesión en el grupo de `base` y conéctate a ella en la
   terminal 2:
   ```bash
   tmux -L lab new -d -t base -s copia
   tmux -L lab attach -t =copia
   ```
   Ahora cada terminal cambia de ventana por su cuenta. Crea una ventana en
   cualquiera de las dos (`prefix` `c`): aparece en las dos.

3. Pregunta a tmux por el grupo:
   ```bash
   tmux -L lab ls -F '#{session_name} grupo=#{session_group} miembros=#{session_group_list}'
   tmux -L lab list-windows -t copia: -F '#{window_index} #{window_name} #{window_id}'
   tmux -L lab list-windows -t base: -F '#{window_index} #{window_name} #{window_id}'
   ```
   Los ids de ventana (`@N`) son los mismos: no son copias, son las mismas
   ventanas.

4. **Lo que se comparte y lo que no.** Cierra una ventana desde `copia`
   (`prefix` `&`): desaparece también de `base`. Cierra la sesión `copia`
   (`tmux -L lab kill-session -t =copia`): `base` sigue entera.

5. **Tamaño.** Con las dos terminales de tamaños distintos mirando **la misma
   ventana**, el tamaño lo decide la última que se usó (`window-size latest`,
   semana 01). Mirando ventanas distintas, cada una se ve a su tamaño.

6. Completa `starter/espejo.sh`: crea, si no existe, una sesión `BASE-espejo`
   en el grupo de `BASE`, y muestra los miembros del grupo. Ejecutarlo dos
   veces no crea nada nuevo.
   ```bash
   tmux -L lab kill-server; tmux -L lab new -d -s base
   ./starter/espejo.sh base
   ./starter/espejo.sh base
   ```
   ```
   creada: base-espejo
   grupo base: base,base-espejo
   ya existe: base-espejo
   grupo base: base,base-espejo
   ```

7. Limpia: `tmux -L lab kill-server`.

## Criterios de éxito

- [ ] Con dos clientes en la misma sesión, cambiar de ventana en uno cambia el otro
- [ ] Con un grupo, cada cliente mira su ventana y las ventanas nuevas aparecen en las dos sesiones
- [ ] Muestras con `#{window_id}` que las ventanas son las mismas
- [ ] `espejo.sh base` dos veces imprime las cuatro líneas del paso 6

## Reto extra

¿Qué pasa con el grupo si cierras `base` y dejas `copia`? Compruébalo con
`#{session_group}` y `#{session_group_list}`.
