# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT
ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
        imagemagick \
        libdrm-tests \
        xterm \
        libg2d-pxp \  
        libg2d-pxp-dev \  
        libg2d-pxp-utils \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

WORKDIR /home/torizon