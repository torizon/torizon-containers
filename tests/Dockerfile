FROM alpine:latest
ENV REGCTL_VERSION=v0.6.0
ARG TARGETPLATFORM
ARG TARGETARCH

RUN apk update && apk upgrade && \
    apk add --no-cache \
        ca-certificates \
        curl \
        git \
        bc \
        procps \
        imagemagick \
        xmlstarlet \
        jq \
        bash \
        envsubst \
        dmesg \
        docker-compose

RUN git clone https://github.com/torizon/bats-core.git /tmp/bats-core && \
    /tmp/bats-core/install.sh /usr/local && \
    rm -rf /tmp/bats-core

RUN mkdir /usr/lib/bats && \
    cd /usr/lib/bats && \
    git clone https://github.com/bats-core/bats-assert.git && \
    git clone https://github.com/bats-core/bats-support.git

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  REGCTL_ARCH=amd64  ;; \
         "linux/arm64")  REGCTL_ARCH=arm64  ;; \
         "linux/arm/v7") REGCTL_ARCH=armhf  ;; \
    esac && \
    curl -L https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-${REGCTL_ARCH} -o /usr/bin/regctl && \
    chmod +x /usr/bin/regctl

RUN case ${TARGETARCH} in \
         "amd64")   DOCKER_ARCH=x86_64   ;; \
         "arm64")   DOCKER_ARCH=aarch64  ;; \
         "arm")     DOCKER_ARCH=armhf    ;; \
    esac && \
    curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-24.0.5.tgz | \
    tar xz -C /usr/local/bin --strip=1 docker/docker && \
    chmod +x /usr/local/bin/docker

COPY tests /tests

WORKDIR /tests
