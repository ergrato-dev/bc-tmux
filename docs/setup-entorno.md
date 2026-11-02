# Preparar el entorno

Quince minutos. Al final tendrás dos cosas:

- **tmux 3.4 o superior en tu equipo**: es el que usas a diario y el que necesitan las semanas 04, 08 y 13.
- **El laboratorio Docker** (`compose.yaml`): tmux 3.4 y las herramientas del bootcamp en versiones fijas. Ahí corren el autograding y la mayoría de los labs.

Sistema mínimo: **Ubuntu 24.04 LTS** (nativo o en WSL2) o **macOS** con Homebrew.

---

## 1. Linux (Ubuntu 24.04)

```bash
sudo apt update
sudo apt install -y tmux jq git shellcheck fzf
tmux -V   # tmux 3.4
```

Ubuntu 22.04 trae tmux 3.2a y **no está soportado**: actualiza a 24.04 (`sudo do-release-upgrade`).

## 2. Windows

Trabaja **siempre dentro de WSL2** con Ubuntu 24.04 y sigue el paso 1. tmux no existe para Windows nativo.

```powershell
wsl --install -d Ubuntu-24.04
```

Usa **Windows Terminal** como emulador: soporta color de 24 bits, undercurl y OSC 52, que necesitarás en las semanas 04 y 08.

## 3. macOS

```bash
brew install tmux jq git shellcheck fzf
tmux -V
```

Homebrew instala la última versión de tmux, que cumple con el mínimo. Usa un emulador moderno (iTerm2, WezTerm, Ghostty o kitty): Terminal.app no soporta color de 24 bits.

## 4. Docker (el laboratorio)

Docker Engine 27+ con Compose v2. En Ubuntu/WSL instala Docker Engine con el repositorio oficial de Docker; en macOS, Docker Desktop u OrbStack.

```bash
git clone https://github.com/ergrato-dev/bc-tmux.git
cd bc-tmux
docker compose build          # imagen bc-tmux-lab:3.4
docker compose run --rm lab   # shell dentro del laboratorio
```

Para trabajar con varias terminales a la vez (lo piden varios labs):

```bash
docker compose up -d lab        # deja el laboratorio corriendo
docker compose exec lab bash    # en cada terminal que necesites
docker compose down             # al terminar
```

Dentro del contenedor eres el usuario `alumno`, con el repositorio montado en `/bc-tmux`. Los archivos que crees ahí aparecen en tu equipo con tu usuario.

## 5. Semanas concretas

| Semana | Necesitas | Dónde |
|---|---|---|
| 10 | fzf | Instalado en el paso 1 y en el laboratorio |
| 11 | uv (Python **siempre con uv**, nunca pip) | El laboratorio ya lo trae. En tu equipo: `brew install uv`; en Linux descarga el instalador oficial, **léelo** y luego ejecútalo (nunca `curl \| sh`) |
| 12 | ssh | El laboratorio levanta un servidor SSH propio |

```bash
curl -fsSL https://astral.sh/uv/install.sh -o /tmp/install-uv.sh
less /tmp/install-uv.sh
sh /tmp/install-uv.sh
```

## 6. Comprobar todo

```bash
./scripts/verificar-semana.sh --doctor                     # tu equipo
docker compose run --rm lab ./scripts/verificar-semana.sh --doctor   # el laboratorio
```

Si todo el bloque **Obligatorio** sale en ✅ en los dos, ya puedes empezar la semana 01.
