# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

EXPOSE 22

RUN apt-get -q -y update \
    && apt-get -q -y install --no-install-recommends \
    openssh-server \
    ssh \
    rsync \
    zip \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd && mkdir /home/build && mkdir /home/build/sysroot

# configures SSH access to the container and sets environment by default
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    #&& useradd -s /bin/bash -d /home/build -g root -G sudo,ssh -p $(echo "build" | openssl passwd -1 -stdin) build \
    && useradd -s /bin/bash -d /home/build -g root -G sudo -p $(echo "build" | openssl passwd -1 -stdin) build \
    && chown -R build /home/build

CMD ["/usr/sbin/sshd", "-D"]
