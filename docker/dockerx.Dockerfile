FROM jenkins/inbound-agent:alpine-jdk17

USER root

# Docker CLI, Buildx és QEMU függőségek telepítése Alpine alól
RUN apk add --no-cache \
    docker-cli \
    docker-cli-buildx \
    qemu-img \
    qemu-arm \
    bash \
    git \
    curl

# Docker Buildx plugin engedélyezése az agent felhasználónak
RUN mkdir -p /home/jenkins/.docker/cli-plugins && \
    ln -s /usr/libexec/docker/cli-plugins/docker-buildx /home/jenkins/.docker/cli-plugins/docker-buildx && \
    chown -R jenkins:jenkins /home/jenkins/.docker

USER jenkins