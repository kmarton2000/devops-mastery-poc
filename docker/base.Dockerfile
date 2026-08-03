FROM alpine:3.19
RUN apk add --no-linux-headers --no-cache git bash curl openssh-client ca-certificates
WORKDIR /home/jenkins/agent