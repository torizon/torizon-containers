# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /opt/nvidia/l4t-packages \
    && touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    nvidia-l4t-core \
    && rm -rf /usr/share/doc/nvidia-l4t-* \
    && rm -f /etc/dpkg/dpkg.cfg.d/include-docs \
    && ldconfig \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN usermod -a -G video,render torizon
