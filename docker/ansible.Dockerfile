FROM kmarton20002/jenkins-base-agent:latest

USER root

# Ansible és SSH kliens telepítése Alpine alapra
RUN apk add --no-cache \
    ansible \
    openssh-client \
    sshpass \
    python3

USER jenkins