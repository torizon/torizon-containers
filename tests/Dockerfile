FROM debian:bookworm-slim
ENV REGCTL_VERSION=v0.6.0
ARG TARGETPLATFORM

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        bats \
        bc \
        procps \
        imagemagick \
        xmlstarlet \
        jq \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN case ${TARGETPLATFORM} in \
         "linux/amd64")  REGCTL_ARCH=amd64  ;; \
         "linux/arm64")  REGCTL_ARCH=arm64  ;; \
         "linux/arm/v7") REGCTL_ARCH=armhf  ;; \
    esac \
 && curl -L https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-${REGCTL_ARCH} > /usr/bin/regctl \
 && chmod +x /usr/bin/regctl

RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

COPY tests/suites /suites
COPY tests/helpers/remove-docker-image-if-outdated.sh /usr/bin

WORKDIR /suites
