FROM kmarton20002/jenkins-base-agent:latest

USER root

# Ansible, OpenSSH és függőségek telepítése
RUN apk add --no-cache \
    ansible \
    openssh-client \
    sshpass \
    python3

# Megbizonyosodunk róla, hogy létezik a jenkins csoport és user (UID/GID 1000)
RUN getent group jenkins || addgroup -g 1000 jenkins && \
    getent passwd jenkins || adduser -u 1000 -G jenkins -s /bin/sh -D jenkins

USER jenkins