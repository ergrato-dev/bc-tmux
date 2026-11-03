# Laboratorio de referencia de bc-tmux: mismo stack para todos los estudiantes,
# para el autograding y para CI. tmux 3.4 = version de Ubuntu 24.04 = minimo.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color \
    BC_TMUX_LAB=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tmux bash jq git shellcheck fzf neovim \
      openssh-client ca-certificates curl less procps \
      openssh-server mosh \
 && rm -rf /var/lib/apt/lists/*

# Semana 12: sshd para hacer ssh al propio contenedor. No arranca solo: lo
# lanza root con docker compose exec -u root lab /usr/sbin/sshd (docs/setup-entorno.md).
# /run/sshd es el directorio de privilegios separados que sshd exige.
RUN mkdir -p /run/sshd \
 && printf 'PasswordAuthentication no\nPermitRootLogin no\n' > /etc/ssh/sshd_config.d/bc-tmux.conf

# Python solo con uv (semana 11). Version fijada en docs/stack-versions.md.
COPY --from=ghcr.io/astral-sh/uv:0.12.2 /uv /uvx /usr/local/bin/

# ubuntu:24.04 ya trae el usuario "ubuntu" con UID 1000: se renombra para que
# los archivos creados en el volumen sean del estudiante en el host.
RUN usermod -l alumno -d /home/alumno -m ubuntu && groupmod -n alumno ubuntu

# Semana 12: un segundo usuario para compartir tmux, sin sudo y sin contraseña
# (useradd la deja bloqueada). El grupo pair da acceso al socket compartido.
RUN groupadd pair \
 && useradd -m -s /bin/bash -G pair invitado \
 && usermod -aG pair alumno
USER alumno
WORKDIR /bc-tmux

CMD ["bash", "-l"]
