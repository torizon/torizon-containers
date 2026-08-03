# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libdrm-common \
    libdrm2 \
    libegl1 \
    libgbm1 \
    libgles2 \
    libvulkan1 \
    libwayland-client0 \
    libwayland-cursor0 \
    libwayland-egl1 \
    libwayland-server0 \
    nvidia-l4t-3d-core \
    nvidia-l4t-gbm \
    # Don't need these
    && rm -rf /etc/X11 \
        /usr/bin/nvidia-xconfig \
        /usr/lib/aarch64-linux-gnu/xorg \
        /usr/share/doc/nvidia-l4t-* \
    && ldconfig \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

ENV WAYLAND_USER="torizon"
ENV XDG_RUNTIME_DIR="/tmp/1000-runtime-dir"
ENV WAYLAND_DISPLAY="wayland-0"
ENV DISPLAY=":0"
