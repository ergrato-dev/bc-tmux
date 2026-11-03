# Labs — Semana 11: Plugins y ecosistema

| # | Lab | Objetivo | Tiempo |
|---|-----|----------|--------|
| 1 | [lab-01-tpm-desde-cero](lab-01-tpm-desde-cero/) | TPM fijado por tag, instalar, cargar y limpiar tmux-resurrect sin teclado, y por qué `run-shell` va al final | ~60 min |
| 2 | [lab-02-resurrect-y-continuum](lab-02-resurrect-y-continuum/) | Guardar y restaurar una sesión de tres ventanas, y el autoguardado de continuum (que necesita un cliente) | ~60 min |
| 3 | [lab-03-anatomia-de-un-plugin](lab-03-anatomia-de-un-plugin/) | Un plugin propio sin TPM: opciones con valor por defecto, una tecla y un segmento que no se duplica | ~60 min |
| 4 | [lab-04-interpolacion-en-la-status](lab-04-interpolacion-en-la-status/) | Marcadores `#{...}` propios que el plugin cambia por `#(script)` o por un valor fijo, con la ruta bien citada | ~60 min |
| 5 | [lab-05-tmuxp](lab-05-tmuxp/) | Una sesión declarada en YAML con tmuxp (`uv tool install`), `load -d`, `freeze`, y cuándo prefieres `dev-up` | ~60 min |
| 6 | [lab-06-plugins-rotos](lab-06-plugins-rotos/) | Arreglar los seis fallos de una config modular con TPM y un plugin propio (rota a propósito) | ~60 min |

**Total labs: 6 horas**

## Antes de cada lab

1. **Red y herramientas.** Los labs 01, 02 y 06 clonan plugins de GitHub
   con `git`, y el 05 instala tmuxp con `uv`. El laboratorio Docker trae
   las dos cosas (desde la raíz del repositorio):
   ```bash
   docker compose up -d lab        # una sola vez
   docker compose exec lab bash    # en cada terminal
   ```
   Al terminar la semana: `docker compose down`.
2. **Terminal A fuera de tmux.** Ahí escribes los comandos;
   `echo "$TMUX"` no imprime nada en ella. Los labs 02 y 04 piden además
   una **terminal B** para conectarte (`attach`) y ver la barra: el
   autoguardado de continuum y los `#(...)` de la status line solo
   funcionan con un cliente conectado.
3. **La carpeta del lab.** Desde la raíz del repositorio, `cd` a la
   carpeta del lab (el paso 0 de cada lab da la ruta). Todos los comandos
   se escriben desde ahí.
4. **Un HOME aislado y un servidor aparte.** TPM y los plugins leen
   `~/.config/tmux` y escriben en `~/.local/share`. Para que nada toque los
   tuyos, cada servidor del lab arranca con el HOME de la carpeta del lab:
   ```bash
   env -u XDG_CONFIG_HOME HOME="$PWD/home" tmux -L lab -f "$PWD/starter/tmux.conf" new -d -s lab
   ```
   ```
   (sin salida)
   ```
   `-L lab` no toca tu tmux de siempre y `-f` carga el starter en vez de tu
   config. En los labs con TPM, `home/.config/tmux` es un enlace a
   `starter/`: para TPM, tu config es `starter/tmux.conf` y los plugins se
   instalan en `starter/plugins/` (ignorado por git).
5. **El prefix es `C-b`**: ningún starter lo cambia. Sales de un cliente
   con `C-b` `d`, y la terminal imprime `[detached (from session lab)]`.
6. **Al terminar cada lab** (terminal A):
   ```bash
   tmux -L lab kill-server
   rm -rf home starter/plugins
   ```
   Si B seguía conectada, imprime `[server exited]`. Si arrancas otro
   servidor justo después de `kill-server`, deja un `sleep 1` entre medias:
   con plugins cargados, arrancar mientras el anterior se cierra puede dar
   `server exited unexpectedly`.

Completa los labs en orden. Después, el [Proyecto semanal](../3-proyecto/README.md).

<!-- nav -->
---

## 🔗 Navegación

| Anterior | Siguiente |
|---|---|
| ← [Teoría — Contexto — resurrect, continuum y gestores de sesiones](../1-teoria/02-resurrect-continuum-y-gestores.md) | [Lab 01 — TPM desde cero](lab-01-tpm-desde-cero/README.md) → |

[↑ Semana 11](../README.md)
