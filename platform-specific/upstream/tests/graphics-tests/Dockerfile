# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        clinfo \
        glmark2-es2-wayland \
        kmscube \
        libdrm-tests \
        imagemagick \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon
