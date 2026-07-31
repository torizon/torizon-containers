# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG NVIDIA_FEED_URL=https://repo.download.nvidia.com/jetson/som
ARG NVIDIA_FEED_SUITE=r39.2
ARG NVIDIA_KEY_URL=https://repo.download.nvidia.com/jetson/jetson-ota-public.asc
ARG NVIDIA_KEY_FINGERPRINT=3C6D1FF3100C8C3ABB0869C0E6543461A9996195

RUN wget -qO /tmp/nvidia-l4t.asc "${NVIDIA_KEY_URL}" \
    && gpg --show-keys --with-colons /tmp/nvidia-l4t.asc \
        | awk -F: '$1=="fpr"{print $10}' \
        | grep -qx "${NVIDIA_KEY_FINGERPRINT}" \
    && gpg --dearmor < /tmp/nvidia-l4t.asc > /usr/share/keyrings/nvidia-l4t.gpg \
    && rm -f /tmp/nvidia-l4t.asc

RUN printf 'Types: deb\nURIs: %s\nSuites: %s\nComponents: main\nArchitectures: arm64\nSigned-By: /usr/share/keyrings/nvidia-l4t.gpg\n' \
        "${NVIDIA_FEED_URL}" "${NVIDIA_FEED_SUITE}" \
        > /etc/apt/sources.list.d/nvidia-l4t.sources

# NVIDIA's preinst validates the host SoC and partition layout and aborts;
# this is their supported bypass for staging files into an image.
RUN mkdir -p /opt/nvidia/l4t-packages \
    && touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libdrm-common \
    libdrm2 \
    libegl1 \
    libgbm1 \
    libgles2 \
    nvidia-l4t-3d-core \
    nvidia-l4t-core \
    nvidia-l4t-gbm \
    # Don't need these
    && rm -f /etc/dpkg/dpkg.cfg.d/include-docs \
    && rm -rf /etc/X11 \
        /usr/bin/nvidia-xconfig \
        /usr/lib/aarch64-linux-gnu/xorg \
        /usr/share/doc/nvidia-l4t-* \
    && ldconfig \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN usermod -a -G video,render torizon

ENV NVIDIA_VISIBLE_DEVICES="all"
ENV NVIDIA_DRIVER_CAPABILITIES="all"
