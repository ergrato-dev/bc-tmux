#!/usr/bin/env bash
# Verifica la integridad estructural del bootcamp:
#   1. Nombres de carpeta week-NN-slug y lab-NN-slug bien formados.
#   2. Enlaces relativos en markdown que resuelven a una ruta real.
#   3. Seccion "Navegacion" en el README de cada semana publicada.
#   4. Diagramas de 0-assets/: solo SVG (ningun .md) y cada SVG enlazado
#      desde algun .md.
#   5. checks.json valido como JSON.
#   6. Todo .sh con shebang `env bash`, `set -euo pipefail` y bit de ejecucion.
#   7. Archivos de teoria de semanas publicadas con 600 palabras o menos.
#   8. Los starter/ de semanas publicadas parsean: cada *.conf con
#      `source-file -n` en un servidor tmux aislado y cada script bash con
#      `bash -n` (salvo labs rotos a proposito: carpetas con "roto(s)",
#      "rota(s)" o "debug" en el nombre).
#
# Las comprobaciones 3, 7 y 8 solo se aplican a las semanas marcadas con ✅ en
# bootcamp/README.md: una semana todavia sin refactorizar fallaria por diseno.
#
# Uso: scripts/verificar-enlaces.sh
# Salida: lista de problemas encontrados; exit code 1 si hay al menos uno.

set -u
cd "$(dirname "$0")/.." || exit 1

fail=0
TMUX_BIN="${TMUX_BIN:-tmux}"

# Semanas ya refactorizadas, segun el indice de bootcamp/README.md.
publicadas=$(grep -oE '^\| \[[0-9]{2}\]\(([a-z0-9_-]+)/README\.md\).*\| ✅ \|$' bootcamp/README.md 2>/dev/null \
             | sed -E 's/^\| \[[0-9]{2}\]\(([a-z0-9_-]+)\/README\.md\).*/\1/')

esta_publicada() {
  # $1 = ruta que contiene el slug de la semana
  local ruta="$1" slug
  for slug in $publicadas; do
    case "$ruta" in *"$slug"*) return 0 ;; esac
  done
  return 1
}

if [ -z "$publicadas" ]; then
  echo "AVISO: ninguna semana marcada como ✅ en bootcamp/README.md."
  echo "       Se omiten las comprobaciones 3, 7 y 8."
fi

echo "== 1. Nombres de carpeta =="
while IFS= read -r d; do
  name=$(basename "$d")
  if ! [[ "$name" =~ ^week-[0-9]{2}-[a-z0-9_]+$ ]]; then
    echo "NOMBRE INVALIDO (week): $d"
    fail=1
  fi
done < <(find bootcamp -mindepth 1 -maxdepth 1 -type d -iname "week-*")
while IFS= read -r d; do
  name=$(basename "$d")
  if ! [[ "$name" =~ ^lab-[0-9]{2}-[a-z0-9-]+$ ]]; then
    echo "NOMBRE INVALIDO (lab): $d"
    fail=1
  fi
done < <(find bootcamp -path "*/2-practicas/*" -mindepth 3 -maxdepth 3 -type d -iname "lab-*")

echo "== 2. Enlaces relativos en markdown =="
# No parsea markdown de verdad: quita los bloques ``` y busca "](...)".
while IFS= read -r f; do
  content=$(awk '/^```/{c=!c; next} !c' "$f")
  while IFS= read -r link; do
    [ -z "$link" ] && continue
    clean="${link%%#*}"
    [ -z "$clean" ] && continue
    case "$clean" in http*|\<http*|ws*|mailto:*|\#*|/*) continue ;; esac
    dir=$(dirname "$f")
    resolved=$(realpath -m "$dir/$clean")
    if [ ! -e "$resolved" ]; then
      echo "ENLACE ROTO: $f -> $link"
      fail=1
    fi
  done < <(printf '%s\n' "$content" | grep -oE '\]\([^)]+\)' | sed -E 's/^\]\(//;s/\)$//')
# .claude/ y .github/ contienen plantillas con rutas de ejemplo que no resuelven
# por diseno; PLANTILLA-SEMANA.md tambien.
done < <(find . -iname "*.md" -not -path "./.git/*" -not -path "*/node_modules/*" \
           -not -path "./.claude/*" -not -path "./.github/*" \
           -not -name "PLANTILLA-SEMANA.md")

echo "== 3. Navegacion en README de cada semana publicada =="
while IFS= read -r rm; do
  esta_publicada "$rm" || continue
  if ! grep -q "Navegación" "$rm"; then
    echo "SIN NAVEGACION: $rm"
    fail=1
  fi
done < <(find bootcamp -mindepth 2 -maxdepth 2 -iname "README.md")

echo "== 4. Diagramas SVG en 0-assets/ =="
while IFS= read -r d; do
  echo "DIAGRAMA EN MARKDOWN (debe ser .svg, ver CLAUDE.md): $d"
  fail=1
done < <(find bootcamp -path "*/0-assets/*" -name "*.md" 2>/dev/null)
while IFS= read -r svg; do
  if ! grep -rqF "$(basename "$svg")" --include="*.md" bootcamp README.md README_EN.md; then
    echo "SVG HUERFANO (no enlazado desde ningun .md): $svg"
    fail=1
  fi
done < <(find bootcamp assets -iname "*.svg" 2>/dev/null)

echo "== 5. checks.json valido =="
if command -v jq >/dev/null 2>&1; then
  while IFS= read -r cj; do
    if ! jq -e . "$cj" > /dev/null 2>&1; then
      echo "JSON INVALIDO: $cj"
      fail=1
    fi
  done < <(find bootcamp -name "checks.json")
else
  echo "AVISO: jq no esta instalado, no se validan los checks.json"
fi

echo "== 6. Cabecera de los scripts bash =="
while IFS= read -r sh; do
  if [ "$(head -1 "$sh")" != "#!/usr/bin/env bash" ]; then
    echo "SHEBANG INCORRECTO (debe ser '#!/usr/bin/env bash'): $sh"
    fail=1
  fi
  if ! grep -q 'set -euo pipefail' "$sh"; then
    echo "SIN 'set -euo pipefail': $sh"
    fail=1
  fi
  if [ ! -x "$sh" ]; then
    echo "SIN BIT DE EJECUCION (chmod +x): $sh"
    fail=1
  fi
done < <(find scripts -name "*.sh" 2>/dev/null)

echo "== 7. Extension de los archivos de teoria (<= 600 palabras) =="
while IFS= read -r t; do
  esta_publicada "$t" || continue
  n=$(awk '/^```/{c=!c; next} !c' "$t" | wc -w)
  if [ "$n" -gt 600 ]; then
    echo "TEORIA DEMASIADO LARGA ($n palabras de prosa, max 600): $t"
    fail=1
  fi
done < <(find bootcamp -path "*/1-teoria/*" -name "*.md" 2>/dev/null)

echo "== 8. Los starter/ parsean =="
parse_tmux() {
  # -n: parsea sin ejecutar. Servidor propio para no tocar la sesion del usuario.
  local out
  out=$(env -u TMUX "$TMUX_BIN" -L bc-parse -f /dev/null new-session -d \; \
        source-file -n "$(realpath "$1")" 2>&1)
  local rc=$?
  env -u TMUX "$TMUX_BIN" -L bc-parse kill-server >/dev/null 2>&1
  [ "$rc" -eq 0 ] || { echo "CONFIG NO PARSEA: $1"; printf '  %s\n' "$(head -1 <<<"$out")"; return 1; }
}
while IFS= read -r f; do
  esta_publicada "$f" || continue
  case "$f" in *rot[oa]*|*debug*) continue ;; esac
  case "$f" in
    *.conf) parse_tmux "$f" || fail=1 ;;
    *)
      if head -1 "$f" | grep -q 'bash'; then
        if ! out=$(bash -n "$f" 2>&1); then
          echo "SCRIPT NO PARSEA: $f"; printf '  %s\n' "$(head -1 <<<"$out")"; fail=1
        fi
      fi ;;
  esac
done < <(find bootcamp -path "*/starter/*" -type f \( -name "*.conf" -o -path "*/bin/*" -o -name "*.sh" \) 2>/dev/null)

if [ "$fail" -eq 0 ]; then
  echo "OK: sin problemas detectados."
fi
exit "$fail"
