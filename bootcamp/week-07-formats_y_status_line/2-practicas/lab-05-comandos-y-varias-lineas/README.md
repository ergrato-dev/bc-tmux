# Lab 05 — Comandos en la barra y varias líneas

⏱ Duración estimada: ~60 min

## Objetivo

Mostrar en la barra la rama git del panel activo con `#(...)` y un script propio, entender cuándo se ejecuta, y añadir una segunda línea de barra con `status-format[1]`.

## Contexto

- `#(comando)` ejecuta un comando de shell y pone su salida en la barra. Corre en segundo plano: la barra enseña la **última** salida y la renueva cada `status-interval` segundos. Un comando lento muestra un valor viejo, pero no congela tmux.
- tmux expande los `#{...}` del comando antes de pasárselo a la shell. La ruta del panel no la eliges tú: va siempre con `q:` delante.
- `display -p` nunca ejecuta `#()`: lo que sale de un comando solo se ve en una barra dibujada, con un cliente conectado.

## Instrucciones

0. **Dónde.** Dos terminales **fuera de tmux** (`echo "$TMUX"` no imprime
   nada): la **A** para los comandos y la **B** para conectarte. En las dos,
   desde la raíz del repositorio:
   ```bash
   cd bootcamp/week-07-formats_y_status_line/2-practicas/lab-05-comandos-y-varias-lineas
   ```
   El servidor es `-L lab`. El starter no cambia el prefix: en este lab es
   **`C-b`**. Necesitas `git` y `shellcheck`
   (`sudo apt install git shellcheck` / `brew install git shellcheck`).

1. **Un repo de prueba** fuera de este repositorio (terminal A):
   ```bash
   R="$(mktemp -d)/mi-repo"; git init -q -b main "$R"; echo "$R"
   ```
   Algo como (cambia el nombre de la carpeta temporal):
   ```
   /tmp/tmp.6TorePc4Gj/mi-repo
   ```
   Un repo recién creado ya tiene rama, aunque no tenga commits.

2. **TODOs 1a y 1b de `starter/bin/lab-git-branch`.** Antes de tocarlo:
   ```bash
   ./starter/bin/lab-git-branch; echo $?
   ```
   ```
   sin implementar
   0
   ```
   1. **TODO 1a: uso.** Pista:
      `(( $# == 1 )) || { echo "uso: lab-git-branch DIR" >&2; exit 2; }`.
      ```bash
      ./starter/bin/lab-git-branch; echo $?
      ```
      ```
      uso: lab-git-branch DIR
      2
      ```
   2. **TODO 1b: la rama.** Borra la línea `echo "sin implementar"` y
      escribe `git -C "$1" symbolic-ref --short -q HEAD 2>/dev/null || true`.
      `symbolic-ref` solo lee `HEAD`: no recorre los archivos como
      `git status`, así que tarda lo mismo en un repo enorme.
      ```bash
      ./starter/bin/lab-git-branch "$R"; echo $?
      ./starter/bin/lab-git-branch /tmp; echo $?
      ./starter/bin/lab-git-branch /no/existe; echo $?
      shellcheck starter/bin/lab-git-branch; echo $?
      ```
      ```
      main
      0
      0
      0
      0
      ```
      Fuera de un repo no imprime nada y sale con 0: un error acabaría
      escrito en la barra.

3. **Arranca con el starter**, con el panel dentro del repo (terminal A):
   ```bash
   tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s api -c "$R"; echo $?
   tmux -L lab show -gv @lab-dir
   tmux -L lab display -p '[#(echo hola)]'
   ```
   Algo como (`@lab-dir` es la ruta de tu copia del repositorio):
   ```
   0
   /bc-tmux/bootcamp/week-07-formats_y_status_line/2-practicas/lab-05-comandos-y-varias-lineas/starter
   []
   ```
   `@lab-dir` lo fija el starter con `current_file`: así `#()` encuentra
   el script sin importar desde dónde arrancaste. Y `display -p` deja
   `#(echo hola)` vacío: no ejecuta comandos.

4. **TODO 2: la rama en la barra.** Pista:
   `set -g status-right '#(#{q:@lab-dir}/bin/lab-git-branch #{q:pane_current_path}) %H:%M '`.
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"; echo $?
   tmux -L lab display -p '#{E:status-right}'
   ```
   Algo como:
   ```
   0
    02:00 
   ```
   En `display -p`, el hueco del `#()` sale vacío. En la terminal B:
   ```bash
   tmux -L lab attach -t api
   ```
   La barra termina en `main 02:00`. Deja la B conectada.

5. **TODO 3: cada cuánto.** Cambia de rama en la terminal A y mira la B:
   ```bash
   git -C "$R" switch -q -c feature/login
   ```
   ```
   (sin salida)
   ```
   La B sigue en `main` hasta 15 s (`status-interval` por defecto). Pista
   del TODO: `set -g status-interval 5`.
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show -gv status-interval
   ```
   ```
   5
   ```
   Repite con `git -C "$R" switch -q main`: la B cambia en 5 s como mucho.
   Menos intervalo es más fresco pero lanza el script más veces, por cada
   cliente conectado.

6. **Un comando lento no congela.** Pruébalo en la terminal A:
   ```bash
   tmux -L lab set -g status-interval 1
   tmux -L lab set -g status-right '#(sleep 3; echo lenta) %H:%M:%S '
   ```
   ```
   (sin salida)
   ```
   En la B los segundos avanzan cada segundo; `lenta` aparece a los 3 s y
   después se queda (es la última salida). Puedes escribir en la shell todo
   el rato. Vuelve a tu config:
   `tmux -L lab source-file "$PWD/starter/tmux.conf"`.

7. **TODO 4: una segunda línea.** Pista:
   `set -g status 2` y
   `set -g 'status-format[1]' '#[align=centre]#{P:#{?pane_active,#[reverse],} #{pane_index}:#{pane_current_command} #[default]}'`.
   `#{P:...}` recorre los paneles de la ventana, como `W:` las ventanas.
   ```bash
   tmux -L lab source-file "$PWD/starter/tmux.conf"
   tmux -L lab show -gv status
   tmux -L lab display -p '#{E:status-format[1]}'
   ```
   ```
   2
   #[align=centre]#[reverse] 0:bash #[default]
   ```
   La B tiene ahora dos líneas de barra; la segunda dice ` 0:bash ` en
   inverso, en el centro (o el nombre de tu shell). Parte la ventana:
   ```bash
   tmux -L lab split-window -h -c /tmp
   ```
   ```
   (sin salida)
   ```
   La segunda línea muestra `0:bash  1:bash` con el `1` en inverso, y la
   rama desaparece de la primera: el panel activo está en `/tmp`, que no es
   un repo. Con `C-b` `←` vuelves al panel 0 y la rama reaparece en el
   siguiente redibujado.

8. **La ruta no se ejecuta.** Una carpeta con un nombre hostil (terminal A):
   ```bash
   D="$(mktemp -d)/mi repo \$(touch PWNED)"; git init -q -b main "$D"
   tmux -L lab new-window -c "$D"
   find / -name PWNED 2>/dev/null | wc -l
   ```
   ```
   0
   ```
   La B muestra `main`: `q:` escapó el espacio, el `$` y los paréntesis.
   Sin `q:`, la shell partiría la ruta en dos y ejecutaría el `$(...)`
   (no lo pruebes fuera de este contenedor o carpeta temporal).

9. **Limpia.** Sal de la B con `C-b` `d`:
   ```
   [detached (from session api)]
   ```
   En la terminal A:
   ```bash
   tmux -L lab kill-server
   ```
   ```
   (sin salida)
   ```

## Criterios de éxito

- [ ] `./starter/bin/lab-git-branch` sin argumentos sale con 2, con `"$R"` imprime `main`, con `/tmp` no imprime nada y sale con 0, y `shellcheck` sale con 0 (paso 2)
- [ ] Explicas por qué `display -p '[#(echo hola)]'` imprime `[]` (paso 3)
- [ ] La barra de la B muestra la rama del panel activo y cambia en ≤ 5 s tras un `git switch` (pasos 4 y 5)
- [ ] Explicas por qué `#(sleep 3; ...)` no bloquea la shell de la B (paso 6)
- [ ] `tmux -L lab show -gv status` imprime `2` y `display -p '#{E:status-format[1]}'` imprime el bloque del panel (paso 7)
- [ ] `find / -name PWNED 2>/dev/null | wc -l` imprime `0` con la carpeta hostil (paso 8)

## Reto extra

Haz que el script imprima el commit corto cuando `HEAD` está suelto
(`git -C "$R" switch -q --detach` tras un primer commit), con
`git rev-parse --short HEAD` como segunda opción. Mide cuánto tarda con
`time ./starter/bin/lab-git-branch "$R"`: si pasa de unos milisegundos,
piensa qué pasaría con `status-interval 1` y cinco clientes.
