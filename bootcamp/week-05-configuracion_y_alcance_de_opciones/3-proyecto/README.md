# Proyecto Semana 05 — tmux-kit: config modular y recarga en caliente

⏱ Duración estimada: ~3 h

## Contexto

Tu `tmux.conf` de la semana 04 tiene veinte líneas. Dentro de tres semanas tendrá ciento cincuenta: status line, teclas de navegación, terminal. Si todo sigue en un archivo, cada cambio es buscar entre líneas que no recuerdas por qué están, y cada `prefix` `r` es rezar para no duplicar nada. Además, te has dado cuenta de que no sabes de dónde sale el valor de una opción cuando un panel se comporta distinto que los demás.

Esta semana tu kit pasa a ser **modular**: un `tmux.conf` que solo carga `conf.d/`, opciones agrupadas por alcance, un prefix elegido por ti, una recarga que no duplica nada y **`bin/kit-opcion`**, que te dice qué valor tiene una opción y de qué nivel sale.

```bash
$ kit-opcion remain-on-exit api:editor.1
on (panel)
$ kit-opcion escape-time
10 (servidor)
```

## Estructura del proyecto

```
starter/                 ← tu tmux-kit de la semana 04 + lo nuevo
├── README.md            ← añade la estructura, tu prefix, kit-opcion y la bitácora
├── .gitignore           ← local.conf
├── tmux.conf            ← hoy, la config de la semana 04; al terminar, solo el punto de entrada
├── conf.d/
│   ├── 10-opciones.conf ← TODOs
│   └── 20-bindings.conf ← TODOs
└── bin/
    ├── check-version, kit-tree, kit-layout, sesiones, kit-copiar   (semanas 01-04)
    └── kit-opcion       ← TODOs (nuevo)
```

Pruébalo siempre con ruta absoluta (`@kit-dir` sale de ella):

```bash
tmux -L kit -f "$PWD/starter/tmux.conf"
```

## Lo que debes construir

### `tmux.conf`

1. Solo el punto de entrada: guarda su directorio en `@kit-dir` (`set -gF @kit-dir "#{d:current_file}"`), carga `conf.d/*.conf` con `source-file -F` y, si existe, `local.conf` con `source-file -qF`. Ningún otro `set` ni `bind`: la config carga entera arranques tmux desde donde arranques.

### `conf.d/10-opciones.conf`

2. Todas las opciones, agrupadas por alcance y con su flag explícito (`-s`, `-g`, `setw -g`): `escape-time` de 20 ms o menos; `base-index`, `pane-base-index` y `renumber-windows`; lo que traías de la semana 04 (`mode-keys`, `history-limit`, `mouse`, `set-clipboard` y `copy-command`, ahora con `#{@kit-dir}/bin/kit-copiar`); y `WAYLAND_DISPLAY` en `update-environment` sin que recargar lo duplique.

### `conf.d/20-bindings.conf`

3. Tu prefix (no `C-b`), con un comentario que explique por qué lo elegiste; `C-b` liberada; tu prefix dos veces llega al programa del panel. `prefix` `r` recarga `#{@kit-dir}/tmux.conf` con `source-file -F` y muestra `config recargada`. Las teclas de copy mode de la semana 04.

### Recarga

4. Recargar dos veces deja exactamente las mismas opciones y teclas. Compruébalo con el `comparar-recarga.sh` del lab 04 antes de entregar.

### `bin/kit-opcion OPCION [TARGET]`

5. Imprime `VALOR (NIVEL)`, con `NIVEL` en `panel`, `ventana`, `sesión`, `global` o `servidor`: el primer nivel, del más concreto al más general, en el que la opción está fijada. Las de servidor se reconocen como tales. `TARGET` es un panel; dentro de tmux, por defecto el actual (`$TMUX_PANE`). Sale con **1** si el target o la opción no existen y con **2** si el uso es incorrecto.

### Kit

6. README con la nueva estructura, cómo probar el kit sin instalarlo, tu prefix y por qué, `kit-opcion` en la tabla y la bitácora de la semana.

## Verificación

```bash
cd starter
tmux -L kit -f "$PWD/tmux.conf" new -d -s api
tmux -L kit show -gv prefix                    # tu prefix
TMUX_SOCKET=kit bin/kit-opcion escape-time api # 10 (servidor)
TMUX_SOCKET=kit bin/kit-opcion base-index api  # 1 (global)
tmux -L kit set -t api base-index 3
TMUX_SOCKET=kit bin/kit-opcion base-index api  # 3 (sesión)
TMUX_SOCKET=kit ../../2-practicas/lab-04-recarga-en-caliente/solucion/comparar-recarga.sh "$PWD/tmux.conf"
tmux -L kit kill-server; cd ..

./scripts/verificar-semana.sh 05               # desde la raíz del repositorio
```

## ✅ Requisitos verificables

Los comprueba `./scripts/verificar-semana.sh 05` desde la raíz del repositorio
(60 de los 100 puntos del Producto). Los otros 40 son de calidad: ver la
[rúbrica](../rubrica-evaluacion.md#-producto-30).

- [ ] tmux.conf carga sin errores
- [ ] tmux.conf no define opciones ni teclas: carga conf.d/
- [ ] Las opciones viven en conf.d/10-opciones.conf
- [ ] Las teclas viven en conf.d/20-bindings.conf
- [ ] La config carga entera aunque arranques tmux desde otro directorio
- [ ] El prefix ya no es C-b
- [ ] El prefix pulsado dos veces llega al programa del panel
- [ ] C-b ya no tiene ninguna función en la tabla prefix
- [ ] escape-time es de 20 ms o menos
- [ ] prefix r recarga la config del kit desde cualquier directorio
- [ ] Recargar la config dos veces no cambia ninguna opción ni tecla
- [ ] update-environment incluye WAYLAND_DISPLAY
- [ ] copy-command sigue apuntando a bin/kit-copiar
- [ ] kit-opcion dice que un valor viene del panel
- [ ] kit-opcion dice que un valor viene de la ventana
- [ ] kit-opcion dice que un valor heredado viene de global
- [ ] kit-opcion reconoce las opciones de servidor
- [ ] tmux.conf, conf.d/ y bin/ no tienen TODOs y bin/ pasa shellcheck

## Calidad

Además de los checks, se revisa (40 pts, ver la rúbrica):

- Cada opción con su flag de alcance explícito y en el bloque de su alcance.
- Comentarios del porqué: `@kit-dir` y `-F`, el orden de `conf.d/`, `escape-time`, `-gu` antes de `-ga`, tu prefix.
- `kit-opcion` explica en un comentario por qué lista los niveles sin nombre de opción; mensajes de error por stderr con los códigos documentados.
- `shellcheck bin/*` sin avisos y ningún `TODO` pendiente.
- `local.conf` en `.gitignore` y ninguna ruta a tu home dentro del kit.

## Entrega

Commit con el mensaje:
```
feat(week-05): tmux.conf modular con conf.d/, recarga idempotente y kit-opcion
```
